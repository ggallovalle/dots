local wk = require("which-key")
local snacks = require("snacks")
local opencode = require("opencode")

local M = {}
local Keymap = {}

---@class kbinit.keymaps.LeaderEntry
---@field [1] string
---@field group string
---@field setup? fun(master: string): void
---@field lsp_on_attach? fun(master: string, bufnr: integer, client: vim.lsp.Client, capabilities: lsp.ServerCapabilities): void

---@type kbinit.keymaps.LeaderEntry[]
local Leader = {
  {
    "gr",
    group = "[G]o to [L]sp",
    lsp_on_attach = function(_master, bufnr, _client, capabilities)
      -- defaults builtins
      wk.add({
        ---@diagnostic disable-next-line: assign-type-mismatch
        { "grn", desc = "Re[n]me" },
        ---@diagnostic disable-next-line: assign-type-mismatch
        { "gra", desc = "Code [A]ction" },
        ---@diagnostic disable-next-line: assign-type-mismatch
        { "grx", desc = "Code[X]lens" },
        ---@diagnostic disable-next-line: assign-type-mismatch
        { "grr", desc = "[R]eferences" },
        ---@diagnostic disable-next-line: assign-type-mismatch
        { "gri", desc = "[I]mplementation" },
        ---@diagnostic disable-next-line: assign-type-mismatch
        { "grt", desc = "[T]ype" },
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

        -- vim.keymap.set("n", "gO", snacks.picker.lsp_symbols, { desc = "lsp.symbols" })
        vim.keymap.set("n", "grs", snacks.picker.lsp_symbols, { desc = "[S]ymbols" })
      end
      vim.keymap.set("n", "gs", snacks.picker.lsp_symbols, { desc = "[S]ymbols" })
    end
  },

  {
    "<leader>c",
    group = "[C]ode",
    lsp_on_attach = function(master, bufnr, _client, _capabilities)
      vim.keymap.set("n", master .. "f", vim.lsp.buf.format, {
        buffer = bufnr,
        desc = "[F]ormat buffer"
      })
      vim.keymap.set("n", master .. "d", function()
        vim.diagnostic.setqflist({ open = true })
      end, { buffer = bufnr, desc = "Diagnostics to quickfix" }
      )
    end
  },
  {
    "<leader>i",
    group = "[I]nsert",
    setup = function(master)
      wk.add({ { master .. "t", group = "[T]ime", icon = "󰥔" } })

      vim.keymap.set("n", master .. "u", function()
        local uuid

        if vim.fn.executable("uuidgen") == 1 then
          uuid = (vim.fn.system("uuidgen") or ""):gsub("%s+$", "")
        end

        if not uuid or uuid == "" then
          -- Fallback: not RFC-perfect, but good enough for local IDs.
          math.randomseed(vim.loop.hrtime())
          local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
          uuid = template:gsub("[xy]", function(c)
            local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
            return string.format("%x", v)
          end)
        end

        vim.api.nvim_put({ uuid }, "c", false, true)
      end, { desc = "[U]UID" })

      vim.keymap.set("n", master .. "td", function()
        vim.api.nvim_put({ os.date("%Y-%m-%d") }, "c", false, true)
      end, { desc = "[D]ay" })

      vim.keymap.set("n", master .. "tt", function()
        -- Local system time (not UTC)
        vim.api.nvim_put({ os.date("%H:%M") }, "c", false, true)
      end, { desc = "[T]ime" })

      vim.keymap.set("n", master .. "tn", function()
        vim.api.nvim_put({ os.date("%Y-%m-%d %H:%M:%S") }, "c", false, true)
      end, { desc = "[N]ow" })

      vim.keymap.set("n", master .. "tu", function()
        -- RFC 3339 in UTC ("Z")
        vim.api.nvim_put({ os.date("!%Y-%m-%dT%H:%M:%SZ") }, "c", false, true)
      end, { desc = "[U]TC" })

      vim.keymap.set("n", master .. "th", function()
        -- RFC 3339 in local timezone (e.g. -06:00)
        local ts = os.date("%Y-%m-%dT%H:%M:%S%z"):gsub("([+-]%d%d)(%d%d)$", "%1:%2")
        vim.api.nvim_put({ ts }, "c", false, true)
      end, { desc = "[H]ere RFC 3339" })

      vim.keymap.set("x", master .. "tc", function()
        require("kbinit.keymap.time").convert_visual()
      end, { desc = "Time [C]onvert" })
    end
  },
  {
    "<leader>f",
    group = "[F]ile",
    setup = function(master)
      vim.keymap.set("n", master .. "e", snacks.explorer.open, { desc = "[F]ile [E]xplorer" })
      vim.keymap.set("n", master .. "o", "<cmd>Yazi<cr>", { desc = "[File] [Y]azy" })
    end
  },
  {
    "<leader>g",
    group = "[G]it",
    setup = function(master)
      vim.keymap.set("n", master .. "l", snacks.lazygit.open, { desc = "Lazygit" })
    end
  },
  {
    "<leader>a",
    group = "[A]I",
    setup = function(master)
      vim.g.opencode_opts = {
        -- Your configuration, if any; goto definition on the type or field for details
      }

      vim.o.autoread = true -- Required for `opts.events.reload`

      -- Recommended/example keymaps
      vim.keymap.set({ "n", "x" }, master .. "a", function() opencode.ask("@this: ", { submit = true }) end,
        { desc = "[A]sk" })
      vim.keymap.set({ "n", "x" }, master .. "x", function() opencode.select() end,
        { desc = "E[X]ecute" })
      vim.keymap.set({ "n", "t" }, master .. "o", function() opencode.toggle() end, { desc = "[O]pen" })

      vim.keymap.set({ "n", "x" }, master .. "r", function() return opencode.operator("@this ") end,
        { desc = "Add [R]ange", expr = true })
      vim.keymap.set("n", master .. "l", function() return opencode.operator("@this ") .. "_" end,
        { desc = "Add [L]ine", expr = true })

      vim.keymap.set("n", "<S-C-u>", function() opencode.command("session.half.page.up") end,
        { desc = "Scroll opencode up" })
      vim.keymap.set("n", "<S-C-d>", function() opencode.command("session.half.page.down") end,
        { desc = "Scroll opencode down" })
    end
  },
  {
    "<leader>s",
    group = "[S]earch",
    setup = function(master)
      vim.keymap.set("n", master .. ":", snacks.picker.command_history, {
        desc = "[S]earch [C]command History"
      })
      vim.keymap.set("n", master .. "k", snacks.picker.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", master .. "g", snacks.picker.grep, { desc = "[S]earch by rip[G]rep" })
      -- vim.keymap.set("n", master .. "b", Keymap.search_buffer(), { desc = "[S]earch [B]uffer" })
      vim.keymap.set("n", master .. "b", snacks.picker.buffers, { desc = "[S]earch [B]uffer" })
      vim.keymap.set("n", master .. "f", Keymap.search_file(), { desc = "[S]earch [F]ile (git)" })
    end
  },
  {
    "<leader>d",
    group = "[D]ocument",
    setup = function(master)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function(args)
          local opts = { buffer = args.buf, silent = true }
          vim.keymap.set("n", master .. "p", "<cmd>TypstPreview<cr>", vim.tbl_extend("force", opts, {
            desc = "[P]review"
          }))
          vim.keymap.set("n", master .. "P", "<cmd>TypstPreviewStop<cr>", vim.tbl_extend("force", opts, {
            desc = "Sto[P] preview"
          }))
        end
      })
    end
  }
}

function Keymap.restart()
  return function()
    require("kbplugin.restart").restart()
  end
end

function Keymap.search_buffer()
  return function()
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
end

function Keymap.search_file()
  return function()
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
end

function Keymap.reload_buffer()
  return function()
    vim.cmd.edit({ bang = true })
  end
end

function M.setup()
  vim.keymap.set("n", "<ESC>", "<CMD>nohlsearch<CR>")
  vim.keymap.set("t", "<ESC><ESC>", "<C-\\><C-n>", { desc = "Exit terminal mode" })


  vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
  vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
  vim.keymap.set("n", "<leader><leader>", snacks.picker.smart, { desc = "[F]" })
  vim.keymap.set("n", "<leader>R", Keymap.restart(), { desc = "[R]estart" })
  vim.keymap.set("n", "<leader>r", Keymap.reload_buffer(), { desc = "[R]eload buffer" })



  for _, v in ipairs(Leader) do
    local master = v[1]
    wk.add({ master, group = v.group })
    if v.setup ~= nil then
      v.setup(master)
    end
  end

  -- wk.add({ "<leader>w", group = "[W]orkspace" })
end

---@param bufnr        integer
---@param client       vim.lsp.Client
---@param capabilities lsp.ServerCapabilities
function M.lsp_on_attach(bufnr, client, capabilities)
  for _, v in ipairs(Leader) do
    if v.lsp_on_attach ~= nil then
      v.lsp_on_attach(v[1], bufnr, client, capabilities)
    end
  end

  if capabilities.hoverProvider then
    vim.keymap.set("n", "K", vim.lsp.buf.hover, {
      buffer = bufnr,
      desc = "[LSP] Hover Documentation"
    })
  end
end

return M
