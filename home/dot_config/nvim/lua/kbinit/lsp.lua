local M = {}

local H = {}

function H.diagnostic()
  vim.diagnostic.config({
    severity_sort = true,
    update_in_insert = false,
    float = { source = "if_many" }
  })
end

function H.lsp_config()
  require("kbinit.languages").setup_lsp()
end

function H.lsp_keymaps()
  ---@type string
  local completion = vim.g.completion_mode or "blink"
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function (args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client == nil then
        return
      end
      if client.server_capabilities == nil then
        return
      end

      if completion == "native"
        and client:supports_method("textDocument/completion") then
        vim.lsp.completion.enable(true, client.id, bufnr, {
          autotrigger = true
        })
      end

      if client:supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end

      if client:supports_method("textDocument/documentColor") then
        vim.lsp.document_color.enable(true, { bufnr = bufnr }, {
          style = "virtual"
        })
      end

      local keymap = require("kbinit.keymap")
      keymap.on_lsp_attach(bufnr, client, client.server_capabilities)
    end
  })
end

function M.setup()
  H.diagnostic()
  H.lsp_config()
  H.lsp_keymaps()
end

return M
