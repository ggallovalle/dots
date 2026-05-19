---@type LazyPluginSpec
local Surround = {
  url = "https://github.com/kylechui/nvim-surround.git",
  opts = function()
    ---@type table<string, any>
    local opts = {}
    return opts
  end,
}

---@type LazyPluginSpec
local AutoPairs = {
  url = "https://github.com/windwp/nvim-autopairs.git",
  opts = function()
    ---@type table<string, any>
    local opts = {}
    return opts
  end,
}

return {
  Surround,
  AutoPairs,
}
