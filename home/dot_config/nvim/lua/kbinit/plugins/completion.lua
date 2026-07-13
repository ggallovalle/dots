---@type LazyPluginSpec
local BlinkLib = { url = "https://github.com/saghen/blink.lib.git" }

local HBlink = {}
function HBlink.select_and_accept()
  local cmp = require("blink.cmp")
  return cmp.select_and_accept({
    callback = function ()
      cmp.show_signature()
      cmp.show_documentation()
    end
  })
end

function HBlink.tab()
  local cmp = require("blink.cmp")
  if cmp.snippet_active() then
    return cmp.accept()
  end
  return HBlink.select_and_accept()
end

---@type LazyPluginSpec
local FileMention = {
  url = "https://github.com/not-manu/filemention.nvim",
  event = "InsertEnter",
  opts = {
    finder = "fff",
    filetypes = { "markdown", "text", "gitcommit", "typst" } -- or "*" if you live dangerously
  }
}

---@type LazyPluginSpec
local BlinkCmp = {
  url = "https://github.com/saghen/blink.cmp.git",
  dependencies = {
    BlinkLib
  },
  build = function ()
    require("blink.cmp")
      .build()
      :pwait()
  end,
  ---@diagnostic disable-next-line: missing-fields
  ---@type blink.cmp.ConfigStrict
  opts = {
    ---@diagnostic disable-next-line: missing-fields
    sources = {
      default = { "filemention", "lsp", "path", "snippets", "buffer" },
      providers = {
        filemention = {
          name = "filemention",
          module = "filemention.sources.blink"
        }
      }
    },
    keymap = {
      preset = "default",
      ["<C-y>"] = { HBlink.select_and_accept, "fallback" },
      ["<CR>"] = { HBlink.select_and_accept, "fallback" },
      ["<Tab>"] = { HBlink.tab, "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },
      ["<C-j>"] = { "select_next", "fallback_to_mappings" },
      ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
      ["<C-d>"] = { "scroll_documentation_down" },
      ["<C-u>"] = { "scroll_documentation_up" },
      ["<C-h>"] = { "show_signature", "hide_signature", "fallback" }
    }
  }
}

return { BlinkCmp, FileMention }
