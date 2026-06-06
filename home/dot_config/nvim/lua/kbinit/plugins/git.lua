---@type LazyPluginSpec
local CodeDiff = {
  url = "https://github.com/esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  keys = {
    { "<leader>gd", "<cmd>CodeDiff<cr>", desc = "[D]iff" }
  }
}

---@type LazyPluginSpec
local Neogit = {
  url = "https://github.com/neogitorg/neogit",
  cmd = "Neogit",
  dependencies = { CodeDiff },
  keys = {
    { "<leader>gn", "<cmd>Neogit<cr>", desc = "[N]eogit" },
    {
      "<leader>gc",
      function ()
        local a = require("neogit.lib.async")
        local git = require("neogit.lib.git")
        a.void(function ()
          git.repo:dispatch_refresh {
            source = "action",
            callback = function ()
              a.void(function ()
                require("neogit.popups.commit.actions").commit {
                  close = function () end,
                  state = { env = {} },
                  get_arguments = function () return { "--verbose" } end,
                  get_internal_arguments = function () return {} end
                }
              end)()
            end
          }
        end)()
      end,
      desc = "[C]ommit"
    }
  }
}

return { Neogit, CodeDiff }
