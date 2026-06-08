local M = {}

local H = {}

function H.lazy_plugins()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=stable",
      lazyrepo,
      lazypath
    })
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
  require("lazy").setup({
    spec = { import = "kbinit.plugins" }
  })
end

function H.kb_plugins()
  require("kbplugin.chezmoi").setup({
    auto_apply_after_add = false,
    log_level = "info"
  })
  require("kbplugin.restart").setup({
    providers = { "kbplugin.chezmoi" },
    log_level = "info"
  })
  require("kbplugin.luarocks").setup({
    dependencies = { "kbstd == dev-1" }
  })
end

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
      ["%.yml$"] = "yaml"
    }
  })
end

function M.setup()
  require("vim._core.ui2").enable({})
  H.options()
  H.lazy_plugins()
  H.kb_plugins()

  require("kbinit.keymap").setup()
  require("kbinit.lsp").setup()

  vim.cmd.colorscheme("catppuccin-nvim")
end

return M
