const Cli = struct {
    allocator: std.mem.Allocator,
    io: std.Io,
    args: std.process.Args.Iterator,
    environ_map: *std.process.Environ.Map,
    stdout_buf: [1024]u8,
    file_writer: Io.File.Writer,
    stdout: *Io.Writer,

    const SubCommands = enum { homepath };

    const main_parsers = .{ .command = clap.parsers.enumeration(SubCommands) };
    const main_params = clap.parseParamsComptime(
        \\-h, --help        Display this help text and exit
        \\--usage-spec      Show the kbsh usage spec and exit
        \\<command>
        \\
    );
    const MainArgs = clap.ResultEx(clap.Help, &main_params, main_parsers);

    const homepath_params = clap.parseParamsComptime(
        \\-h, --help    Display this help text and exit
        \\<file>...
        \\
    );
    const homepath_parsers = .{ .file = clap.parsers.string };
    const HomePathArgs = clap.ResultEx(clap.Help, &homepath_params, homepath_parsers);

    fn parseMain(self: *Cli) !MainArgs {
        var diag = clap.Diagnostic{};
        const res = clap.parseEx(clap.Help, &main_params, main_parsers, &self.args, .{ .diagnostic = &diag, .allocator = self.allocator, .terminating_positional = 0 }) catch |err| {
            try diag.reportToFile(self.io, .stderr(), err);
            return err;
        };
        return res;
    }

    fn parseHomePath(self: *Cli) !HomePathArgs {
        var diag = clap.Diagnostic{};
        const res = clap.parseEx(clap.Help, &homepath_params, homepath_parsers, &self.args, .{ .diagnostic = &diag, .allocator = self.allocator }) catch |err| {
            try diag.reportToFile(self.io, .stderr(), err);
            return err;
        };
        return res;
    }

    pub fn init(self: *Cli, process: std.process.Init) !void {
        self.allocator = process.gpa;
        self.io = process.io;
        self.args = try process.minimal.args.iterateAllocator(process.gpa);
        _ = self.args.next();
        self.environ_map = process.environ_map;
        self.stdout_buf = undefined;
        self.file_writer = Io.File.Writer.init(.stdout(), self.io, &self.stdout_buf);
        self.stdout = &self.file_writer.interface;
    }

    pub fn deinit(self: *Cli) void {
        self.args.deinit();
    }

    pub fn run(process: std.process.Init, comptime Commands: type) !void {
        var cli: Cli = undefined;
        try cli.init(process);
        defer cli.deinit();
        const argsMain = try cli.parseMain();
        if (argsMain.args.help != 0) {
            var help_buf: [1024]u8 = undefined;
            var stderr_w = std.Io.File.stderr().writer(process.io, &help_buf);
            try stderr_w.interface.writeAll(assets.help);
            try stderr_w.interface.flush();
            return;
        }
        if (argsMain.args.@"usage-spec" != 0) {
            try cli.stdout.writeAll(assets.usage_spec);
            try cli.stdout.flush();
            return;
        }
        const command = argsMain.positionals[0] orelse {
            try cli.stdout.writeAll(assets.help);
            try cli.stdout.flush();
            return;
        };
        var argsHomePath = try cli.parseHomePath();
        defer argsHomePath.deinit();
        if (argsHomePath.args.help != 0) {
            var help_buf: [1024]u8 = undefined;
            var stderr_w = std.Io.File.stderr().writer(process.io, &help_buf);
            try stderr_w.interface.writeAll(assets.homepath_help);
            try stderr_w.interface.flush();
            return;
        }
        switch (command) {
            .homepath => try Commands.homepath(&cli, argsMain, argsHomePath),
        }
    }
};

const KbshCli = struct {
    pub fn homepath(cli: *Cli, argsMain: Cli.MainArgs, argsHomePath: Cli.HomePathArgs) !void {
        _ = argsMain;
        const allocator = cli.allocator;

        const file_args = argsHomePath.positionals[0];

        var input_list: std.ArrayList([]const u8) = .empty;
        defer {
            for (input_list.items) |item| allocator.free(item);
            input_list.deinit(allocator);
        }

        if (file_args.len == 0) {
            const cwd_z = try std.process.currentPathAlloc(cli.io, allocator);
            const cwd = try allocator.dupe(u8, cwd_z);
            allocator.free(cwd_z);
            try input_list.append(allocator, cwd);
        } else if (file_args.len == 1 and std.mem.eql(u8, file_args[0], "-")) {
            var stdin_buf: [4096]u8 = undefined;
            var stdin_reader = Io.File.stdin().readerStreaming(cli.io, &stdin_buf);
            var r = &stdin_reader.interface;
            while (try r.takeDelimiter('\n')) |line| {
                const t = std.mem.trimEnd(u8, line, "\r");
                if (t.len > 0) try input_list.append(allocator, try allocator.dupe(u8, t));
            }
        } else {
            for (file_args) |arg| try input_list.append(allocator, try allocator.dupe(u8, arg));
        }

        for (input_list.items) |p| {
            const smart = try resolveSmartPath(cli.io, cli.environ_map, allocator, p);
            defer allocator.free(smart);
            try cli.stdout.print("{s}\n", .{smart});
        }
        try cli.stdout.flush();
    }
};

fn getEnv(env: *std.process.Environ.Map, key: []const u8) ?[]const u8 {
    return env.get(key);
}

fn resolveSmartPath(io: std.Io, env: *std.process.Environ.Map, allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    const cwd = try std.process.currentPathAlloc(io, allocator);
    defer allocator.free(cwd);

    const abs_path = if (std.fs.path.isAbsolute(path))
        try allocator.dupe(u8, path)
    else
        try std.fs.path.join(allocator, &.{ cwd, path });
    defer allocator.free(abs_path);

    const home = getEnv(env, "HOME") orelse return try allocator.dupe(u8, abs_path);

    const EnvFallback = struct { value: []const u8, owned: bool };
    var fallbacks: [7]EnvFallback = undefined;
    defer for (&fallbacks) |*fb| if (fb.owned) allocator.free(fb.value);

    fallbacks[0] = if (getEnv(env, "XDG_CONFIG_HOME")) |v|
        EnvFallback{ .value = v, .owned = false }
    else
        EnvFallback{ .value = try std.fs.path.join(allocator, &.{ home, ".config" }), .owned = true };

    fallbacks[1] = if (getEnv(env, "XDG_CACHE_HOME")) |v|
        EnvFallback{ .value = v, .owned = false }
    else
        EnvFallback{ .value = try std.fs.path.join(allocator, &.{ home, ".cache" }), .owned = true };

    fallbacks[2] = if (getEnv(env, "XDG_DATA_HOME")) |v|
        EnvFallback{ .value = v, .owned = false }
    else
        EnvFallback{ .value = try std.fs.path.join(allocator, &.{ home, ".local", "share" }), .owned = true };

    fallbacks[3] = if (getEnv(env, "XDG_STATE_HOME")) |v|
        EnvFallback{ .value = v, .owned = false }
    else
        EnvFallback{ .value = try std.fs.path.join(allocator, &.{ home, ".local", "state" }), .owned = true };

    fallbacks[4] = if (getEnv(env, "XDG_BIN_HOME")) |v|
        EnvFallback{ .value = v, .owned = false }
    else
        EnvFallback{ .value = try std.fs.path.join(allocator, &.{ home, ".local", "bin" }), .owned = true };

    fallbacks[5] = if (getEnv(env, "GHQ_ROOT")) |v|
        EnvFallback{ .value = v, .owned = false }
    else
        EnvFallback{ .value = try std.fs.path.join(allocator, &.{ home, "ghq" }), .owned = true };

    fallbacks[6] = if (getEnv(env, "DOTFILES")) |v|
        EnvFallback{ .value = v, .owned = false }
    else
        EnvFallback{ .value = try std.fs.path.join(allocator, &.{ home, "dots" }), .owned = true };

    const Named = struct { name: []const u8, value: []const u8 };
    const entries = [_]Named{
        .{ .name = "$XDG_CONFIG_HOME", .value = fallbacks[0].value },
        .{ .name = "$XDG_CACHE_HOME", .value = fallbacks[1].value },
        .{ .name = "$XDG_DATA_HOME", .value = fallbacks[2].value },
        .{ .name = "$XDG_STATE_HOME", .value = fallbacks[3].value },
        .{ .name = "$XDG_BIN_HOME", .value = fallbacks[4].value },
        .{ .name = "$GHQ_ROOT", .value = fallbacks[5].value },
        .{ .name = "$DOTFILES", .value = fallbacks[6].value },
        .{ .name = "$HOME", .value = home },
    };

    var best_name: []const u8 = "";
    var best_len: usize = 0;

    for (entries) |e| {
        if (std.mem.startsWith(u8, abs_path, e.value) and
            (abs_path.len == e.value.len or abs_path[e.value.len] == '/') and
            e.value.len > best_len)
        {
            best_name = e.name;
            best_len = e.value.len;
        }
    }

    if (best_len > 0) {
        if (abs_path.len == best_len) return try allocator.dupe(u8, best_name);
        return try std.fmt.allocPrint(allocator, "{s}/{s}", .{ best_name, abs_path[best_len + 1 ..] });
    }

    return try allocator.dupe(u8, abs_path);
}

pub fn main(init: std.process.Init) !void {
    _ = kbstd.add(1, 2);
    try Cli.run(init, KbshCli);
    // // Prints to stderr, unbuffered, ignoring potential errors.
    // std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    //
    // // This is appropriate for anything that lives as long as the process.
    // const arena: std.mem.Allocator = init.arena.allocator();
    //
    // // Accessing command line arguments:
    // const args = try init.minimal.args.toSlice(arena);
    // for (args) |arg| {
    //     std.log.info("arg: {s}", .{arg});
    // }
    //
    // // In order to do I/O operations need an `Io` instance.
    // const io = init.io;
    //
    // // Stdout is for the actual output of your application, for example if you
    // // are implementing gzip, then only the compressed bytes should be sent to
    // // stdout, not any debugging messages.
    // var stdout_buffer: [1024]u8 = undefined;
    // var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    // const stdout_writer = &stdout_file_writer.interface;
    //
    // try kbsh.printAnotherMessage(stdout_writer);
    //
    // try stdout_writer.flush(); // Don't forget to flush!
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    try std.testing.fuzz({}, testOne, .{});
}

fn testOne(context: void, smith: *std.testing.Smith) !void {
    _ = context;
    // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!

    const gpa = std.testing.allocator;
    var list: std.ArrayList(u8) = .empty;
    defer list.deinit(gpa);
    while (!smith.eos()) switch (smith.value(enum { add_data, dup_data })) {
        .add_data => {
            const slice = try list.addManyAsSlice(gpa, smith.value(u4));
            smith.bytes(slice);
        },
        .dup_data => {
            if (list.items.len == 0) continue;
            if (list.items.len > std.math.maxInt(u32)) return error.SkipZigTest;
            const len = smith.valueRangeAtMost(u32, 1, @min(32, list.items.len));
            const off = smith.valueRangeAtMost(u32, 0, @intCast(list.items.len - len));
            try list.appendSlice(gpa, list.items[off..][0..len]);
            try std.testing.expectEqualSlices(
                u8,
                list.items[off..][0..len],
                list.items[list.items.len - len ..],
            );
        },
    };
}

const std = @import("std");
const clap = @import("clap");
const Io = std.Io;
const kbsh = @import("kbsh");
const kbstd = @import("kbstd");
const assets = @import("assets");
