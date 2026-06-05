local snacks = require("snacks")

local M = {}

local function restart()
  require("kbplugin.restart").restart()
end

local function reload_buffer()
  vim.cmd.edit({ bang = true })
end

-- Add buffer-local "go" keymap to codediff explorer to open file in new tab
vim.api.nvim_create_autocmd("User", {
  pattern = "CodeDiffOpen",
  callback = function ()
    local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
    if not ok then
      return
    end
    local tabpage = vim.api.nvim_get_current_tabpage()
    local explorer = lifecycle.get_explorer(tabpage)
    if not explorer or not explorer.bufnr then
      return
    end

    vim.keymap.set(
      "n", "go",
      function ()
        local node = explorer.tree:get_node()
        if not node or not node.data or not node.data.path then
          vim.notify("Not on a file", vim.log.levels.WARN)
          return
        end
        vim.cmd("tabedit "
          .. vim.fn.fnameescape(explorer.git_root .. "/" .. node.data.path))
      end,
      {
        buffer = explorer.bufnr,
        desc = "Open file in new tab"
      }
    )
  end
})

function M.register()
  vim.keymap.set("n", "<ESC>", "<CMD>nohlsearch<CR>")
  vim.keymap.set("t", "<ESC><ESC>", "<C-\\><C-n>", {
    desc = "Exit Terminal Mode"
  })

  vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', {
    desc = "Copy to System Clipboard"
  })
  vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', {
    desc = "Paste from System Clipboard"
  })
  vim.keymap.set("n", "<leader><leader>", snacks.picker.smart, {
    desc = "Find"
  })
  vim.keymap.set("n", "<leader>R", restart, { desc = "Restart" })
  vim.keymap.set("n", "<leader>r", reload_buffer, { desc = "Reload Buffer" })
end

return M
