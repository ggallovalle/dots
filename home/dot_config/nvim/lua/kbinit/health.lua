local M = {}

local function executable(bin)
    local where = vim.fn.exepath(bin)
    if where == "" then
        vim.health.error(bin .. "executable is missing")
    else
        vim.health.ok(bin .. " : " .. where)
    end
end

local function version_is(program, expected, actual)
    ---@type vim.Version
    local v_expected = expected
    if type(expected) == "string" then
        ---@diagnostic disable-next-line: assign-type-mismatch
        v_expected = vim.version.parse(expected)
    end

    ---@type vim.Version
    local v_actual = actual
    if type(actual) == "string" then
        ---@diagnostic disable-next-line: assign-type-mismatch
        v_actual = vim.version.parse(actual)
    end

    local ok = v_actual >= v_expected
    if ok then
        vim.health.ok(string.format("%s is version %s", program, v_actual))
    else
        vim.health.error(string.format(
            "%s %s+ required, current: %s", v_expected, v_actual
        ))
    end
end

function M.check()
    vim.health.start("kbinit")

    for _, cmd in ipairs {
        "tree-sitter", "rg", "mise", "rustc", "cargo", "bun", "fzf", "lazygit",
        "yazi"
    } do
        executable(cmd)
    end

    ---@diagnostic disable-next-line: call-non-callable
    version_is("nvim", "0.12", vim.version())
end

return M
