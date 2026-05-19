local snacks = require("snacks")

local M = {}

local function restart()
    require("kbplugin.restart").restart()
end

local function reload_buffer()
    vim.cmd.edit({ bang = true })
end

function M.register()
    vim.keymap.set("n", "<ESC>", "<CMD>nohlsearch<CR>")
    vim.keymap.set("t", "<ESC><ESC>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

    vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to System Clipboard" })
    vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from System Clipboard" })
    vim.keymap.set("n", "<leader><leader>", snacks.picker.smart, { desc = "Find" })
    vim.keymap.set("n", "<leader>R", restart, { desc = "Restart" })
    vim.keymap.set("n", "<leader>r", reload_buffer, { desc = "Reload Buffer" })
end

return M
