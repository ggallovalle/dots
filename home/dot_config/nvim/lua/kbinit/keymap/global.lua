local snacks = require("snacks")

local M = {}

function M.register()
    vim.keymap.set("n", "<ESC>", "<CMD>nohlsearch<CR>")
    vim.keymap.set("t", "<ESC><ESC>", "<C-\\><C-n>", {
        desc = "Exit Terminal Mode"
    })

    vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', {
        desc = "Copy to System Clipboard"
    })
    vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', {
        desc = "Paste from System Clipboard"
    })
    vim.keymap.set("n", "<leader><leader>", snacks.picker.smart, {
        desc = "Find"
    })
    vim.keymap.set("n", "<leader>R",
        function()
            require("kbplugin.restart").restart()
        end
        , { desc = "Restart" })
    vim.keymap.set("n", "<leader>r",
        function()
            vim.cmd.edit({ bang = true })
        end
        , { desc = "Reload Buffer" })
end

return M
