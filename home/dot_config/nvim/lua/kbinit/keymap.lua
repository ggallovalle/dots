local M = {}
local H = {}

local function open_diagnostic_qf(title, diagnostics)
  if #diagnostics == 0 then
    return
  end

  local items = vim.tbl_map(function (diagnostic)
    local source = diagnostic.source
    local text = diagnostic.message

    if source and source ~= "" then
      text = string.format("[%s] %s", source, text)
    end

    return {
      bufnr = diagnostic.bufnr,
      lnum = diagnostic.lnum + 1,
      col = diagnostic.col + 1,
      end_lnum = diagnostic.end_lnum and (diagnostic.end_lnum + 1) or nil,
      end_col = diagnostic.end_col and (diagnostic.end_col + 1) or nil,
      severity = diagnostic.severity,
      text = text
    }
  end, diagnostics)

  vim.fn.setqflist({}, " ", {
    title = title,
    items = items
  })
  vim.cmd.copen()
end

function H.file_type()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function (args)
      vim.keymap.set("n", "<Esc>", "<cmd>cclose<cr>", {
        buffer = args.buf,
        silent = true,
        nowait = true
      })
      vim.keymap.set(
        "n", "<CR>",
        function ()
          local win = vim.api.nvim_get_current_win()
          vim.cmd.cc({ count = vim.fn.line(".") })
          vim.schedule(function ()
            pcall(vim.api.nvim_win_close, win, true)
          end)
        end,
        {
          buffer = args.buf,
          silent = true,
          nowait = true
        }
      )
    end
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "typst",
    callback = function (args)
      local opts = { buffer = args.buf, silent = true }
      vim.keymap.set(
        "n", "<leader>dp", "<cmd>TypstPreview<cr>",
        vim.tbl_extend("force", opts, {
          desc = "[P]review"
        })
      )
      vim.keymap.set(
        "n", "<leader>dP", "<cmd>TypstPreviewStop<cr>",
        vim.tbl_extend("force", opts, {
          desc = "Stop [P]review"
        })
      )
    end
  })
end

function M.setup()
  H.file_type()

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
  vim.keymap.set("n", "<leader>R", function ()
    require("kbplugin.restart").restart()
  end, { desc = "Restart" }
  )
  vim.keymap.set("n", "<leader>r", function ()
    vim.cmd.edit({ bang = true })
  end, { desc = "Reload Buffer" }
  )
  vim.keymap.set("n", "<leader>iu", function ()
    local uuid

    if vim.fn.executable("uuidgen") == 1 then
      uuid = (vim.fn.system("uuidgen") or ""):gsub("%s+$", "")
    end

    if not uuid or uuid == "" then
      math.randomseed(vim.uv.hrtime())
      local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
      uuid = template:gsub("[xy]", function (c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
        return string.format("%x", v)
      end)
    end

    vim.api.nvim_put({ uuid }, "c", false, true)
  end, { desc = "[U]UID" }
  )

  vim.keymap.set("n", "<leader>itd", function ()
    vim.api.nvim_put({ os.date("%Y-%m-%d") }, "c", false, true)
  end, { desc = "[D]ay" }
  )

  vim.keymap.set("n", "<leader>itt", function ()
    vim.api.nvim_put({ os.date("%H:%M") }, "c", false, true)
  end, { desc = "[T]ime" }
  )

  vim.keymap.set("n", "<leader>itn", function ()
    vim.api.nvim_put({ os.date("%Y-%m-%d %H:%M:%S") }, "c", false, true)
  end, { desc = "[N]ow" }
  )

  vim.keymap.set("n", "<leader>itu", function ()
    vim.api.nvim_put({ os.date("!%Y-%m-%dT%H:%M:%SZ") }, "c", false, true)
  end, { desc = "[U]TC" }
  )

  vim.keymap.set("n", "<leader>ith", function ()
    local ts = os.date("%Y-%m-%dT%H:%M:%S%z"):gsub("([+-]%d%d)(%d%d)$", "%1:%2")
    vim.api.nvim_put({ ts }, "c", false, true)
  end, { desc = "[H]ere RFC 3339" }
  )

  vim.keymap.set("x", "<leader>itc", function ()
    require("kbinit.keymap.time").convert_visual()
  end, { desc = "[C]onvert Time" }
  )
end

---@param bufnr        integer
---@param client       vim.lsp.Client
---@param capabilities lsp.ServerCapabilities
function M.on_lsp_attach(bufnr, client, capabilities)
  if capabilities.definitionProvider then
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
      buffer = bufnr,
      desc = "[D]efinition"
    })

    vim.keymap.set("n", "grd", vim.lsp.buf.definition, {
      buffer = bufnr,
      desc = "[D]efinition"
    })
  end

  vim.keymap.set(
    "n", "<leader>dd",
    function ()
      open_diagnostic_qf(
        string.format(
          "Diagnostics for %s",
          vim
            .api
            .nvim_buf_get_name(bufnr)
        ),
        vim
          .diagnostic
          .get(0)
      )
    end,
    {
      buffer = bufnr,
      desc = "[D]ocument [D]iagnostics"
    }
  )

  vim.keymap.set(
    "n", "<leader>wd",
    function ()
      open_diagnostic_qf("Workspace Diagnostics", vim.diagnostic.get())
    end,
    {
      buffer = bufnr,
      desc = "[W]orkspace [D]iagnostics"
    }
  )

  if capabilities.hoverProvider then
    vim.keymap.set("n", "K", vim.lsp.buf.hover, {
      buffer = bufnr,
      desc = "[LSP] Hover Documentation"
    })
  end
end

return M
