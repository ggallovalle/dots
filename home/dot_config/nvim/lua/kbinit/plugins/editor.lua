---@type LazyPluginSpec
local Surround = {
    url = "https://github.com/kylechui/nvim-surround.git",
    ---@type kbinit.surround.Config
    opts = {}
}

---@type LazyPluginSpec
local AutoPairs = {
    url = "https://github.com/windwp/nvim-autopairs.git",
    ---@type kbinit.autopairs.Config
    opts = {}
}

return { Surround, AutoPairs }
