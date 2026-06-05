---@type LazyPluginSpec
local CodeDiff = {
  url = "https://github.com/esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  keys = {
    { "<leader>gd", "<cmd>CodeDiff<cr>", desc = "[N]eogit" }
  }
}

---@type LazyPluginSpec
local Neogit = {
  url = "https://github.com/neogitorg/neogit",
  cmd = "Neogit",
  dependencies = { CodeDiff },
  keys = {
    { "<leader>gn", "<cmd>Neogit<cr>", desc = "[N]eogit" }
  }
}

return { Neogit, CodeDiff }
