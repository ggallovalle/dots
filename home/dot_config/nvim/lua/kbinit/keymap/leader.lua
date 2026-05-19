local wk = require("which-key")
local snacks = require("snacks")
local opencode = require("opencode")

local M = {}

local function search_file()
  local cwd = vim.fn.getcwd()
  local git_root = snacks.git.get_root()

  if git_root then
    snacks.picker.git_files({
      untracked = true,
      cwd = cwd,
      filter = { cwd = cwd }
    })
  else
    snacks.picker.files({
      cwd = cwd,
      filter = { cwd = cwd }
    })
  end
end

local function search_buffer()
  snacks.picker.buffers({
    confirm = function(picker, item)
      picker:close()
      if item then
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_buf(win) == item.buf then
            vim.api.nvim_set_current_win(win)
            return
          end
        end
        vim.cmd.buffer({ bang = true, count = item.buf })
      end
    end,
    win = {
      list = {
        keys = {
          ["dd"] = "bufdelete"
        }
      }
    }
  })
end

function M.register()
  wk.add({ "gr", group = "[G]o to LSP" })
  wk.add({ "<leader>c", group = "[C]ode" })

  wk.add({ "<leader>i", group = "[I]nsert" })
  wk.add({ "<leader>it", group = "[T]ime", icon = "󰥔" })

  vim.keymap.set("n", "<leader>iu", function()
    local uuid

    if vim.fn.executable("uuidgen") == 1 then
      uuid = (vim.fn.system("uuidgen") or ""):gsub("%s+$", "")
    end

    if not uuid or uuid == "" then
      math.randomseed(vim.loop.hrtime())
      local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
      uuid = template:gsub("[xy]", function(c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
        return string.format("%x", v)
      end)
    end

    vim.api.nvim_put({ uuid }, "c", false, true)
  end, { desc = "[U]UID" })

  vim.keymap.set("n", "<leader>itd", function()
    vim.api.nvim_put({ os.date("%Y-%m-%d") }, "c", false, true)
  end, { desc = "[D]ay" })

  vim.keymap.set("n", "<leader>itt", function()
    vim.api.nvim_put({ os.date("%H:%M") }, "c", false, true)
  end, { desc = "[T]ime" })

  vim.keymap.set("n", "<leader>itn", function()
    vim.api.nvim_put({ os.date("%Y-%m-%d %H:%M:%S") }, "c", false, true)
  end, { desc = "[N]ow" })

  vim.keymap.set("n", "<leader>itu", function()
    vim.api.nvim_put({ os.date("!%Y-%m-%dT%H:%M:%SZ") }, "c", false, true)
  end, { desc = "[U]TC" })

  vim.keymap.set("n", "<leader>ith", function()
    local ts = os.date("%Y-%m-%dT%H:%M:%S%z"):gsub("([+-]%d%d)(%d%d)$", "%1:%2")
    vim.api.nvim_put({ ts }, "c", false, true)
  end, { desc = "[H]ere RFC 3339" })

  vim.keymap.set("x", "<leader>itc", function()
    require("kbinit.keymap.time").convert_visual()
  end, { desc = "[C]onvert Time" })

  wk.add({ "<leader>f", group = "[F]ile" })
  vim.keymap.set("n", "<leader>fe", snacks.explorer.open, { desc = "[E]xplorer" })
  vim.keymap.set("n", "<leader>fo", "<cmd>Yazi<cr>", { desc = "[O]pen Yazi" })

  wk.add({ "<leader>g", group = "[G]it" })
  vim.keymap.set("n", "<leader>gl", snacks.lazygit.open, { desc = "[L]azygit" })

  wk.add({ "<leader>a", group = "[A]I" })
  vim.g.opencode_opts = {}
  vim.o.autoread = true

  vim.keymap.set({ "n", "x" }, "<leader>aa", function()
    opencode.ask("@this: ", { submit = true })
  end, { desc = "[A]sk" })
  vim.keymap.set({ "n", "x" }, "<leader>ax", function()
    opencode.select()
  end, { desc = "E[X]ecute" })
  vim.keymap.set({ "n", "t" }, "<leader>ao", function()
    opencode.toggle()
  end, { desc = "[O]pen" })

  vim.keymap.set({ "n", "x" }, "<leader>ar", function()
    return opencode.operator("@this ")
  end, { desc = "[R]ange", expr = true })
  vim.keymap.set("n", "<leader>al", function()
    return opencode.operator("@this ") .. "_"
  end, { desc = "[L]ine", expr = true })

  vim.keymap.set("n", "<S-C-u>", function()
    opencode.command("session.half.page.up")
  end, { desc = "Scroll Opencode Up" })
  vim.keymap.set("n", "<S-C-d>", function()
    opencode.command("session.half.page.down")
  end, { desc = "Scroll Opencode Down" })

  wk.add({ "<leader>s", group = "[S]earch" })
  vim.keymap.set("n", "<leader>s:", snacks.picker.command_history, { desc = "[C]ommand History" })
  vim.keymap.set("n", "<leader>sk", snacks.picker.keymaps, { desc = "[K]eymaps" })
  vim.keymap.set("n", "<leader>sg", snacks.picker.grep, { desc = "[G]rep" })
  vim.keymap.set("n", "<leader>sb", search_buffer, { desc = "[B]uffers" })
  vim.keymap.set("n", "<leader>sf", search_file, { desc = "[F]iles (Git)" })

  wk.add({ "<leader>d", group = "[D]ocument" })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "typst",
    callback = function(args)
      local opts = { buffer = args.buf, silent = true }
      vim.keymap.set("n", "<leader>dp", "<cmd>TypstPreview<cr>", vim.tbl_extend("force", opts, {
        desc = "[P]review"
      }))
      vim.keymap.set("n", "<leader>dP", "<cmd>TypstPreviewStop<cr>", vim.tbl_extend("force", opts, {
        desc = "Stop [P]review"
      }))
    end
  })
end

---@param bufnr integer
---@param _client vim.lsp.Client
---@param capabilities lsp.ServerCapabilities
function M.on_lsp_attach(bufnr, _client, capabilities)
  wk.add({
    ---@diagnostic disable-next-line: assign-type-mismatch
    { "grn", desc = "Re[n]ame" },
    ---@diagnostic disable-next-line: assign-type-mismatch
    { "gra", desc = "Code [A]ction" },
    ---@diagnostic disable-next-line: assign-type-mismatch
    { "grx", desc = "Code [X]Lens" },
    ---@diagnostic disable-next-line: assign-type-mismatch
    { "grr", desc = "[R]eferences" },
    ---@diagnostic disable-next-line: assign-type-mismatch
    { "gri", desc = "[I]mplementation" },
    ---@diagnostic disable-next-line: assign-type-mismatch
    { "grt", desc = "[T]ype Definition" },
  })

  if capabilities.definitionProvider then
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
      buffer = bufnr,
      desc = "[D]efinition"
    })

    vim.keymap.set("n", "grd", vim.lsp.buf.definition, {
      buffer = bufnr,
      desc = "[D]efinition"
    })

    vim.keymap.set("n", "grs", snacks.picker.lsp_symbols, { desc = "[S]ymbols" })
  end

  vim.keymap.set("n", "gs", snacks.picker.lsp_symbols, { desc = "[S]ymbols" })

  vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, {
    buffer = bufnr,
    desc = "[F]ormat Buffer"
  })

  vim.keymap.set("n", "<leader>cd", function()
    vim.diagnostic.setqflist({ open = true })
  end, {
    buffer = bufnr,
    desc = "[D]iagnostics to Quickfix"
  })

  if capabilities.hoverProvider then
    vim.keymap.set("n", "K", vim.lsp.buf.hover, {
      buffer = bufnr,
      desc = "[LSP] Hover Documentation"
    })
  end
end

return M
