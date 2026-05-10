local M = {}

function M.doctor()
    for _, cmd in ipairs {
        "tree-sitter", "rg", "mise", "rustc", "cargo", "bun", "fzf", "lazygit", "yazi"
    } do
        assert(vim.fn.exepath(cmd) ~= "", string.format("command `%s` MUST be installed", cmd))
    end

    local min_version = "0.12"
    ---@diagnostic disable-next-line: call-non-callable
    local current = vim.version()
    local min = vim.version.parse(min_version)
    assert(current >= min, string.format("Neovim %s+ required, current: %s", min_version, current))
end

return M
