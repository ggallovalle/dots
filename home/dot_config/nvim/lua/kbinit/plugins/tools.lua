---@type LazyPluginSpec
local Opencode = { url = "https://github.com/nickjvandyke/opencode.nvim.git" }

---@type LazyPluginSpec
local Yazi = {
    url = "https://github.com/mikavilpas/yazi.nvim.git",
    init = function()
        vim.g.loaded_netrwPlugin = 1
    end,
    ---@type YaziConfig
    opts = {
        open_for_directories = true
    }
}

return { Opencode, Yazi }
