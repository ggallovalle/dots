local Xdg = require("std.xdg")
local M = {}

local H = {}

function H.autocd()
  vim.api.nvim_create_autocmd("BufEnter", {
    once = true,
    callback = function ()
      ---@diagnostic disable-next-line: assign-type-mismatch
      ---@type string
      local arg = vim.fn.argv(0)

      if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
        vim.cmd.cd(vim.fn.fnameescape(arg))
      end
    end
  })
end

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
    spec = { import = "kbinit.plugins" },
    change_detection = {
      enabled = false
    }
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

  -- Scrollof
  local scrollof = math.floor(vim.o.lines / 2) - 3
  vim.opt.scrolloff = scrollof

  -- Better highlighting
  vim.opt.hlsearch = false
  vim.opt.incsearch = true

  -- No wrap
  vim.opt.autoindent = true

  -- Line numbers
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.cursorline = true
  vim.opt.cursorlineopt = "number" -- > line, screenline, both (i.e., "number,line")
  vim.opt.cursorcolumn = true

  -- Tabs
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


  -- Enable yaml, mermaid and typst filetype detection
  vim.filetype.add({
    pattern = {
      ["%.yml$"] = "yaml",
      ["%.typ$"] = "typst",
      ["%.mmd$"] = "mermaid",
    }
  })
end

function M.setup()
  require("vim._core.ui2").enable({})

  H.options()
  H.autocd()
  H.lazy_plugins()
  H.kb_plugins()

  require("kbinit.keymap").setup()
  require("kbinit.lsp").setup()

  vim.cmd.colorscheme("catppuccin-nvim")
end

return M
