---@type LazyPluginSpec
local Screenkey = {
    url = "https://github.com/NStefan002/screenkey.nvim.git",
    ---@type screenkey.config
  ---@diagnostic disable-next-line: missing-fields
    opts = {
        keys = {
            ["<TAB>"] = "Tab",
            ["<CR>"] = "Enter",
            ["<ESC>"] = "Esc",
            ["<SPACE>"] = "Space",
            ["<BS>"] = "Backspace",
            ["<DEL>"] = "Del",
            ["<LEFT>"] = "Left",
            ["<RIGHT>"] = "Right",
            ["<UP>"] = "Up",
            ["<DOWN>"] = "Down",
            ["<HOME>"] = "Home",
            ["<END>"] = "End",
            ["<PAGEUP>"] = "PgUp",
            ["<PAGEDOWN>"] = "PgDn",
            ["<INSERT>"] = "Ins",
            ["<F1>"] = "F1",
            ["<F2>"] = "F2",
            ["<F3>"] = "F3",
            ["<F4>"] = "F4",
            ["<F5>"] = "F5",
            ["<F6>"] = "F6",
            ["<F7>"] = "F7",
            ["<F8>"] = "F8",
            ["<F9>"] = "F9",
            ["<F10>"] = "F10",
            ["<F11>"] = "F11",
            ["<F12>"] = "F12",
            ["CTRL"] = "Ctrl",
            ["ALT"] = "Alt",
            ["SUPER"] = "Super",
            ["<leader>"] = "Spc"
        }
    }
}

---@type LazyPluginSpec
local Devicons = {
    url = "https://github.com/nvim-tree/nvim-web-devicons.git",
    opts = {
        variant = "dark"
    }
}

---@type LazyPluginSpec
local Catppuccin = {
    url = "https://github.com/catppuccin/nvim.git",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    ---@type CatppuccinOptions
    opts = {
        flavour = "mocha"
    }
}

---@type LazyPluginSpec
local WhichKey = { url = "https://github.com/folke/which-key.nvim.git", config = true }

---@type LazyPluginSpec
local Snacks = {
    url = "https://github.com/folke/snacks.nvim.git",
    ---@type snacks.Config
    opts = {
        input = {},
        picker = {
            actions = {
                opencode_send = function(...)
                    return require("opencode").snacks_picker_send(...)
                end
            },
            win = {
                input = {
                    keys = {
                        ["<a-a>"] = { "opencode_send", mode = { "n", "i" } }
                    }
                }
            }
        }
    }
}

---@type LazyPluginSpec
local RenderMarkdown = {
    url = "https://github.com/MeanderingProgrammer/render-markdown.nvim.git",
    config = true
}

---@type LazyPluginSpec
local TypstPreview = {
    url = "https://github.com/chomosuke/typst-preview.nvim.git",
    ---@type kbinit.typst.Config
    opts = {
        dependencies_bin = {
            tinymist = "tinymist",
            websocat = "websocat"
        },
        open_cmd = "firefox %s"
    }
}

return { Screenkey, Devicons, Catppuccin, WhichKey, Snacks, RenderMarkdown, TypstPreview }
