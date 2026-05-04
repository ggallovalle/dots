local M = {}
local H = {}

function H.restart()
    local target = "Session-restart-xxx.vim"
    local instance = {
        setup = function()
            vim.cmd.mksession({ target, bang = true })
            vim.cmd.restart("source " .. target)
        end,
        cleanup = function()
            vim.fs.rm(target, { force = true })
        end
    }
    return instance
end

function M.setup()
    local wk = require("which-key")
    local snacks = require("snacks")

    local restart = H.restart()
    vim.schedule(restart.cleanup)
    vim.keymap.set("n", "<leader>R", restart.setup, { desc = "[R]estart" })
    vim.keymap.set("n", "<leader>r", function()
        vim.cmd.edit({ bang = true })
    end, { desc = "[R]eload buffer" }
    )
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
    vim.keymap.set("n", "<leader>sb", snacks.picker.buffers, { desc = "[S]earch [B]uffer" })
    vim.keymap.set("n", "<leader>sf", function()
        local cwd = vim.fn.getcwd()
        snacks.picker.git_files({
            untracked = true,
            cwd = cwd,
            filter = { cwd = cwd },
        })
    end, { desc = "[S]earch [F]ile (git)" })
end

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
