--- Buffer-local keymap help for fyler via which-key (g?).

local M = {}

---@param buf integer
function M.register(buf)
  local ok, wk = pcall(require, "which-key")
  if not ok then
    return
  end

  wk.add({
    {
      buffer = buf,
      { "<CR>", desc = "Select / expand compact chain" },
      { "<2-LeftMouse>", desc = "Select / expand compact chain" },
      { ".", desc = "Visit cursor directory (compact leaf)" },
      { "-", desc = "Visit parent directory" },
      { "=", desc = "Visit root directory" },
      { "<BS>", desc = "Shrink parent directory" },
      { "<C-R>", desc = "Refresh tree" },
      { "<C-S>", desc = "Open in split" },
      { "<C-V>", desc = "Open in vertical split" },
      { "<C-T>", desc = "Open in new tab" },
      { "g.", desc = "Toggle gitignored files" },
      { "gi", desc = "Toggle indent guides" },
      { "g?", desc = "Show buffer keymaps" },
      { "q", desc = "Close fyler" },
    },
  })
end

function M.show()
  local ok, wk = pcall(require, "which-key")
  if not ok then
    vim.notify("which-key is not available", vim.log.levels.WARN, { title = "Fyler" })
    return
  end
  wk.show({ global = false })
end

function M.install()
  if vim.g._kb_fyler_help then
    return
  end
  vim.g._kb_fyler_help = true

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "fyler_finder",
    desc = "Register fyler buffer keymap descriptions for which-key",
    callback = function(ev)
      M.register(ev.buf)
    end,
  })
end

return M
