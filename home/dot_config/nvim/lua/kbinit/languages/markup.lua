--- Snippet knobs. Edit `cols` / `rows` / `headers` here to reshape the snippet.
--- `headers` seeds the table.header cells; missing entries become empty.
local config = {
  cols = 3,
  headers = { "H1", "H2", "H3" },
  rows = 2,
}

--- Build LuaSnip snippet nodes for a typst `#table(...)` block.
--- Header row -> N editable inserts, then `rows` rows x `cols` body cells.
--- Each cell content is wrapped in `[ ]` per typst markup mode.
local function build_typst_table(luasnip)
  local s, i, t, f = luasnip.s, luasnip.i, luasnip.t, luasnip.f

  local cols = config.cols
  local rows = config.rows
  local headers = config.headers

  local nodes = {}
  local ins = 1

  nodes[#nodes + 1] = t("#table(\n  columns: (")
  nodes[#nodes + 1] = f(function ()
    return tostring(cols)
  end)
  nodes[#nodes + 1] = t(" * (auto,)),\n")

  nodes[#nodes + 1] = t("  table.header(")
  for c = 1, cols do
    if c > 1 then nodes[#nodes + 1] = t(", ") end
    nodes[#nodes + 1] = t("[")
    nodes[#nodes + 1] = i(ins, headers[c] or "")
    nodes[#nodes + 1] = t("]")
    ins = ins + 1
  end
  nodes[#nodes + 1] = t("),\n")

  for r = 1, rows do
    for c = 1, cols do
      if c == 1 then
        nodes[#nodes + 1] = r == 1 and t("  ") or t(",\n  ")
      else
        nodes[#nodes + 1] = t(", ")
      end
      nodes[#nodes + 1] = t("[")
      nodes[#nodes + 1] = i(ins, "")
      nodes[#nodes + 1] = t("]")
      ins = ins + 1
    end
  end

  nodes[#nodes + 1] = t("\n)")

  luasnip.add_snippets("typst", {
    s("table", nodes)
  })
end

return {
  lsp = {
    tinymist = {
      cmd = { "tinymist" },
      filetypes = { "typst" },
      root_markers = { ".git" }
    }
  },
  mason = { "tinymist" },
  treesitter = {
    "typst",
    "markdown",
    "markdown_inline"
  },
  snippets = {
    typst = build_typst_table,
  },
}
