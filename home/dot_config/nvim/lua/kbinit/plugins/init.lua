local M = {}

---@type LazyPluginSpec[]
M.specs = {
  require("kbinit.plugins.core"),
  require("kbinit.plugins.ui"),
  require("kbinit.plugins.editor"),
  require("kbinit.plugins.lsp"),
  require("kbinit.plugins.tools"),
}

function M.setup()
  require("lazy").setup(M.specs)
end

return M
