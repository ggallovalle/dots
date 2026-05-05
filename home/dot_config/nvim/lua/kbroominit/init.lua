local M = {}

local H = {}

function H.options()
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "

    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.cursorline = true
    vim.opt.cursorlineopt = "number" -- > line, screenline, both (i.e., "number,line")
    vim.opt.cursorcolumn = true

    vim.opt.softtabstop = 0   -- > How many chracters the /cursor moves/ with <TAB> and <BS> -- 0 to disable
    vim.opt.expandtab = true  -- > Use space instead of tab
    vim.opt.shiftwidth = 2    -- > Number of spaces to use for auto-indentation, <<, >>, etc.
    vim.opt.shiftround = true -- > Make the indentation to a multiple of shiftwidth when using < or >

    -- Update time
    vim.opt.updatetime = 250
    vim.opt.timeoutlen = 300

    -- Window size
    vim.opt.winminwidth = 3

    -- Others
    vim.opt.mouse = "a"
    vim.opt.confirm = true -- > Confirm before exiting with unsaved bufffer(s)

    -- Case insensitive searching
    vim.o.ignorecase = true
    vim.o.smartcase = true

    -- Enable yaml filetype detection for .yml files
    vim.filetype.add({
        pattern = {
            ["%.yml$"] = "yaml",
        },
    })
end

function M.setup()
    require("vim._core.ui2").enable({})


    H.options()
    require("kbroominit.lsp").setup()
    require("kbroominit.plugins").setup()
    require("kbroominit.keymaps").setup()
end

return M
