-- Enable Treesitter highlighting for Mermaid diagrams
vim.treesitter.start()
vim.defer_fn(function()
  local h = vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()]
  if h then
    h:_on_start()
  end
end, 50)