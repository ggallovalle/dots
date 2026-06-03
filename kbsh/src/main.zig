const Cli = struct {
    allocator: std.mem.Allocator,
    io: std.Io,
    args: std.process.Args.Iterator,
    stdout_buf: [1024]u8,
    file_writer: Io.File.Writer,
    stdout: *Io.Writer,

    const SubCommands = enum { homepath };

    const main_parsers = .{ .command = clap.parsers.enumeration(SubCommands) };
    const main_params = clap.parseParamsComptime(
        \\-h, --help    Display this help text and exit
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
        const command = argsMain.positionals[0] orelse return error.MissingCommand;
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
        _ = argsHomePath;
        try cli.stdout.print("homepath\n", .{});
        try cli.stdout.flush();
    }
};

pub fn main(init: std.process.Init) !void {
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
const assets = @import("assets");
