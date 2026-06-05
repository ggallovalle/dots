local M = {}

function M.setup()
  require("kbinit.keymap.global").register()
  require("kbinit.keymap.leader").register()
end

---@param bufnr        integer
---@param client       vim.lsp.Client
---@param capabilities lsp.ServerCapabilities
function M.on_lsp_attach(bufnr, client, capabilities)
  require("kbinit.keymap.leader").on_lsp_attach(bufnr, client, capabilities)
end

return M
