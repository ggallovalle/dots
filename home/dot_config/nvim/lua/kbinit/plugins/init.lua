local M = {}

---@type LazyPluginSpec[][]
M.specs = {
    require("kbinit.plugins.core"), require("kbinit.plugins.ui"), require("kbinit.plugins.editor"),
    require("kbinit.plugins.lsp"), require("kbinit.plugins.tools")
}

function M.setup()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.uv.fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim
            .fn
            .system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_echo({
                { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                { out, "WarningMsg" },
                { "\nPress any key to exit..." }
            }, true, {})
            vim.fn.getchar()
            os.exit(1)
        end
    end
    vim.opt.rtp:prepend(lazypath)

    ---@diagnostic disable-next-line: undefined-field
    require("lazy").setup(M.specs)
end

return M
