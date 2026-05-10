local M = {}
local Keymap = {}

function Keymap.restart()
    local target = "Session-restart-xxx.vim"

    vim.schedule(function()
        vim.fs.rm(target, { force = true })
    end)

    return function()
        vim.cmd.mksession({ target, bang = true })
        vim.cmd.restart("source " .. target)
    end
end

function Keymap.search_buffer()
    local snacks = require("snacks")

    return function()
        snacks.picker.buffers({
            confirm = function(picker, item)
                picker:close()
                if item then
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        if vim.api.nvim_win_get_buf(win) == item.buf then
                            vim.api.nvim_set_current_win(win)
                            return
                        end
                    end
                    vim.cmd.buffer({ bang = true, count = item.buf })
                end
            end,
            win = {
                list = {
                    keys = {
                        ["dd"] = "bufdelete"
                    }
                }
            }
        })
    end
end

function Keymap.search_file()
    local snacks = require("snacks")

    return function()
        local cwd = vim.fn.getcwd()
        local git_root = snacks.git.get_root()

        if git_root then
            snacks.picker.git_files({
                untracked = true,
                cwd = cwd,
                filter = { cwd = cwd }
            })
        else
            snacks.picker.files({
                cwd = cwd,
                filter = { cwd = cwd }
            })
        end
    end
end

function Keymap.reload_buffer()
    return function()
        vim.cmd.edit({ bang = true })
    end
end

function M.setup()
    local wk = require("which-key")
    local snacks = require("snacks")

    vim.keymap.set("n", "<leader>R", Keymap.restart(), { desc = "[R]estart" })
    vim.keymap.set("n", "<leader>r", Keymap.reload_buffer(), { desc = "[R]eload buffer" })
    vim.keymap.set("n", "<ESC>", "<CMD>nohlsearch<CR>")
    vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
    vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })

    wk.add({ "<leader>c", group = "[C]ode" })
    wk.add({ "<leader>d", group = "[D]ocument" })
    wk.add({ "<leader>f", group = "[F]ile" })
    wk.add({ "<leader>g", group = "[G]it" })
    wk.add({ "gr", group = "[G]o to [L]sp" })
    wk.add({ "<leader>s", group = "[S]earch" })
    wk.add({ "<leader>w", group = "[W]orkspace" })
    wk.add({ "<leader>t", group = "[T]oggle / [T]erminal" })

    vim.keymap.set("n", "<leader><leader>", snacks.picker.smart, { desc = "[F]" })

    vim.keymap.set("n", "<leader>gl", snacks.lazygit.open, { desc = "Lazygit" })

    vim.keymap.set("n", "<leader>fe", snacks.explorer.open, { desc = "[F]ile [E]xplorer" })
    vim.keymap.set("n", "<leader>fo", "<cmd>Yazi<cr>", { desc = "[File] [Y]azy" })

    vim.keymap.set("n", "<leader>s:", snacks.picker.command_history, {
        desc = "[S]earch [C]command History"
    })
    vim.keymap.set("n", "<leader>sk", snacks.picker.keymaps, { desc = "[S]earch [K]eymaps" })
    vim.keymap.set("n", "<leader>sg", snacks.picker.grep, { desc = "[S]earch by rip[G]rep" })
    vim.keymap.set("n", "<leader>sb", Keymap.search_buffer(), { desc = "[S]earch [B]uffer" })
    vim.keymap.set("n", "<leader>sf", Keymap.search_file(), { desc = "[S]earch [F]ile (git)" })
end

---@diagnostic disable-next-line: unused
---@param bufnr        integer
---@param client       vim.lsp.Client
---@param capabilities lsp.ServerCapabilities
function M.lsp_on_attach(bufnr, client, capabilities)
    local snacks = require("snacks")

    if capabilities.hoverProvider then
        vim.keymap.set("n", "K", vim.lsp.buf.hover, {
            buffer = bufnr,
            desc = "[LSP] Hover Documentation"
        })
    end

    --- default: grn - vim.lsp.buf.rename
    --- default: gra - vim.lsp.buf.code_action
    --- default: grx - vim.lsp.codelens.run
    --- default: grr - vim.lsp.buf.references
    --- default: gri - vim.lsp.buf.implementation
    --- default: grt - vim.lsp.buf.type_definition
    if capabilities.definitionProvider then
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
            buffer = bufnr,
            desc = "vim.lsp.buf.definition()"
        })

        vim.keymap.set("n", "grd", vim.lsp.buf.definition, {
            buffer = bufnr,
            desc = "vim.lsp.buf.definition()"
        })

        vim.keymap.set("n", "gO", snacks.picker.lsp_symbols, { desc = "lsp.symbols" })
    end

    vim.keymap.set("n", "gs", snacks.picker.lsp_symbols, { desc = "lsp.symbols" })

    vim.keymap.set("n", "<leader>cd", function()
        vim.diagnostic.setqflist({ open = true })
    end, { buffer = bufnr, desc = "Diagnostics to quickfix" }
    )
    vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, {
        buffer = bufnr,
        desc = "[F]ormat buffer"
    })
end

return M
