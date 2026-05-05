# What's New in Neovim 0.11

> Released March 2025

---

## LSP

### New Configuration APIs

Neovim 0.11 introduced the foundational LSP configuration APIs that became the primary approach in 0.12.

- **`vim.lsp.config(name, cfg)`** — Define default configurations for servers
  [`:help vim.lsp.config()`](https://neovim.io/doc/user/lsp/#vim.lsp.config())
- **`vim.lsp.enable(name)`** — Enable/start LSP servers
  [`:help vim.lsp.enable()`](https://neovim.io/doc/user/lsp/#vim.lsp.enable())
- Server configs can be specified in `lsp/<name>.lua` files
  [`:help lsp-config`](https://neovim.io/doc/user/lsp/#lsp-config)

### LSP Improvements

- **Improved hover docs rendering** — Markdown tree-sitter highlighting in hover
  [`:help K-lsp-default`](https://neovim.io/doc/user/lsp/#K-lsp-default)
- **`vim.lsp.completion.enable()`** — Builtin LSP-powered auto-completion
  [`:help vim.lsp.completion.enable()`](https://neovim.io/doc/user/lsp/#vim.lsp.completion.enable())
  - Gained `convert` callback for customizing CompletionItem → complete-items transformation
- **Completion side effects** — Snippet expansion, command execution, additional text edits built-in
- **`vim.lsp.buf.format()`** — Supports passing a list of ranges via `range` parameter (`textDocument/rangesFormatting`)
  [`:help vim.lsp.buf.format()`](https://neovim.io/doc/user/lsp/#vim.lsp.buf.format())
- **`vim.lsp.buf.code_action()`** — Shows client name when multiple clients; resolves `command` property via `codeAction/resolve`
  [`:help vim.lsp.buf.code_action()`](https://neovim.io/doc/user/lsp/#vim.lsp.buf.code_action())
- **`vim.lsp.buf.signature_help()`** — Can cycle through signatures with `<C-s>`, supports multiple clients
  [`:help vim.lsp.buf.signature_help()`](https://neovim.io/doc/user/lsp/#vim.lsp.buf.signature_help())
- **`vim.lsp.buf.hover()`** — Highlights hover ranges with `hl-LspReferenceTarget`
  [`:help vim.lsp.buf.hover()`](https://neovim.io/doc/user/lsp/#vim.lsp.buf.hover())
- **`vim.lsp.foldexpr()`** — Implemented LSP folding
  [`:help vim.lsp.foldexpr()`](https://neovim.io/doc/user/lsp/#vim.lsp.foldexpr())
- **`vim.lsp.diagnostic.from()`** — Convert `vim.Diagnostic` objects to LSP diagnostic representation
  [`:help vim.lsp.diagnostic.from()`](https://neovim.io/doc/user/lsp/#vim.lsp.diagnostic.from())
- **Position encodings** — Client now supports `'utf-8'` and `'utf-32'`
- **`vim.lsp.Client`** — Functions can now be called as methods
  [`:help vim.lsp.Client`](https://neovim.io/doc/user/lsp/#vim.lsp.Client)
- **`:checkhealth vim.lsp`** — Displays server version
  [`:help :checkhealth`](https://neovim.io/doc/user/lsp/#:checkhealth)
- **`vim.lsp.util.locations_to_items()`** / **`vim.lsp.util.symbols_to_items()`** — Now sets `end_col` and `end_lnum` fields
  [`:help vim.lsp.util.locations_to_items()`](https://neovim.io/doc/user/lsp/#vim.lsp.util.locations_to_items())

### Default LSP Mappings

| Mapping | Mode | Action | Help |
|---|---|---|---|
| `grn` | Normal | `vim.lsp.buf.rename()` | [`:help grn`](https://neovim.io/doc/user/lsp/#grn) |
| `grr` | Normal | `vim.lsp.buf.references()` | [`:help grr`](https://neovim.io/doc/user/lsp/#grr) |
| `gri` | Normal | `vim.lsp.buf.implementation()` | [`:help gri`](https://neovim.io/doc/user/lsp/#gri) |
| `gO` | Normal | `vim.lsp.buf.document_symbol()` | [`:help gO`](https://neovim.io/doc/user/lsp/#gO) |
| `gra` | Normal, Visual | `vim.lsp.buf.code_action()` | [`:help gra`](https://neovim.io/doc/user/lsp/#gra) |
| `CTRL-S` | Insert, Select | `vim.lsp.buf.signature_help()` | [`:help i_CTRL-S`](https://neovim.io/doc/user/lsp/#i_CTRL-S) |

### LSP Breaking Changes

- **Multi-client results** — `vim.lsp.buf.references()`, `declaration()`, `definition()`, `type_definition()`, `implementation()`, `hover()` now merge results from multiple clients but no longer trigger global handlers from `vim.lsp.handlers`
  [`:help vim.lsp.buf.references()`](https://neovim.io/doc/user/lsp/#vim.lsp.buf.references())
- **`vim.lsp.handlers.signature_help()`** — No longer used
  [`:help vim.lsp.handlers`](https://neovim.io/doc/user/lsp/#vim.lsp.handlers)
- **Diagnostic handlers** — `vim.lsp.diagnostic.on_publish_diagnostics()` and `on_diagnostic()` no longer accept config parameter; use `vim.diagnostic.config(config, vim.lsp.diagnostic.get_namespace(client_id))` instead
  [`:help vim.lsp.diagnostic`](https://neovim.io/doc/user/lsp/#vim.lsp.diagnostic)
- **`vim.lsp.util.make_position_params()`** / **`make_range_params()`** / **`make_given_range_params()`** — Now require `position_encoding` parameter
  [`:help vim.lsp.util.make_position_params()`](https://neovim.io/doc/user/lsp/#vim.lsp.util.make_position_params())
- **Removed** — `severity_limit` option for `vim.lsp.diagnostic` (use `min=severity` instead)
  [`:help vim.diagnostic.severity`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.severity)

---

## Diagnostics

- **`vim.diagnostic.config()`** — Accepts "jump" table for `vim.diagnostic.jump()` defaults
  [`:help vim.diagnostic.config()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.config())
- **"virtual_lines" handler** — Renders diagnostics as virtual lines below code (upstreamed from lsp_lines.nvim)
  [`:help diagnostic-virtual_lines`](https://neovim.io/doc/user/diagnostic/#diagnostic-virtual_lines)
- **"virtual_text" handler** — Now **opt-in** instead of opt-out; enable with `vim.diagnostic.config({ virtual_text = true })`
  [`:help diagnostic-virtual_text`](https://neovim.io/doc/user/diagnostic/#diagnostic-virtual_text)
  - Accepts `current_line` option to only show at cursor's line
- **`vim.diagnostic.setqflist()`** — Updates existing quickfix list with given title if found
  [`:help vim.diagnostic.setqflist()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.setqflist())
- **Severity sorting** — "underline" handler sorts diagnostics by severity when using `severity_sort`
  [`:help diagnostic-handlers`](https://neovim.io/doc/user/diagnostic/#diagnostic-handlers)
- **Severity filtering** — Diagnostics filtered by severity before passing to handler

---

## Treesitter

### Performance

- **Async highlighting** — Treesitter highlighting is now asynchronous
  [`:help treesitter-highlight`](https://neovim.io/doc/user/treesitter/#treesitter-highlight)
  - Force synchronous: `vim.g._ts_force_sync_parsing = true`
- **Async folding** — Treesitter folding calculated asynchronously
- **Async injection** — Injection query iteration now asynchronous
- **10x foldexpr speedup** — When no parser exists for buffer
  [`:help vim.treesitter.foldexpr()`](https://neovim.io/doc/user/treesitter/#vim.treesitter.foldexpr())
- **Query caching** — Strong caching makes repeat `query.get()` and `query.parse()` significantly faster
- **Range-limited parsing** — `LanguageTree:parse()` only runs injection query on provided range

### New APIs

- **`LanguageTree:node_for_range()`** — Gets anonymous and named nodes for a range
  [`:help LanguageTree:node_for_range()`](https://neovim.io/doc/user/treesitter#LanguageTree:node_for_range())
- **`vim.treesitter.get_node()`** — Takes `include_anonymous` option (default false)
  [`:help vim.treesitter.get_node()`](https://neovim.io/doc/user/treesitter#vim.treesitter.get_node())
- **`TSNode:child_with_descendant()`** — Efficiently gets node's child containing given node as descendant
  [`:help TSNode:child_with_descendant()`](https://neovim.io/doc/user/treesitter#TSNode:child_with_descendant())
- **`LanguageTree:parse()`** — Optionally supports async invocation via `on_parse` callback
  [`:help LanguageTree:parse()`](https://neovim.io/doc/user/treesitter#LanguageTree:parse())
- **`vim.treesitter.query.set()`** — Can inherit/extend runtime file queries in addition to overriding
  [`:help vim.treesitter.query.set()`](https://neovim.io/doc/user/treesitter#vim.treesitter.query.set())
- **`LanguageTree:is_valid()`** — Accepts range parameter to narrow validity check scope
  [`:help LanguageTree:is_valid()`](https://neovim.io/doc/user/treesitter#LanguageTree:is_valid())
- **`vim.treesitter.language.inspect()`** — Shows additional info including parser version for ABI 15 parsers
  [`:help vim.treesitter.language.inspect()`](https://neovim.io/doc/user/treesitter#vim.treesitter.language.inspect())
- **`TSQuery:disable_pattern()`** / **`TSQuery:disable_capture()`** — Turn off specific pattern or capture
  [`:help TSQuery:disable_pattern()`](https://neovim.io/doc/user/treesitter#TSQuery:disable_pattern())
- **`Query:iter_captures()`** — Accepts `opts` parameter similar to `Query:iter_matches()`
  [`:help Query:iter_captures()`](https://neovim.io/doc/user/treesitter#Query:iter_captures())
- **`vim.treesitter.get_captures_at_pos()`** — Returns `id` and `pattern_id` of each capture
  [`:help vim.treesitter.get_captures_at_pos()`](https://neovim.io/doc/user/treesitter#vim.treesitter.get_captures_at_pos())

### Treesitter Breaking Changes

- **`Query:iter_matches()`** — Now correctly returns all matching nodes; table maps capture IDs to list of nodes
  - Backwards compatibility: `all=false` option (will be removed in future)
  [`:help Query:iter_matches()`](https://neovim.io/doc/user/treesitter#Query:iter_matches())
- **`vim.treesitter.get_parser()`** / **`vim.treesitter.start()`** — No longer parse tree before returning; must call `LanguageTree:parse()` explicitly
  [`:help vim.treesitter.get_parser()`](https://neovim.io/doc/user/treesitter#vim.treesitter.get_parser())
- **`vim.treesitter.get_parser()`** — Expects buffer to be loaded
- **`vim.treesitter.language.get_filetypes()`** — Always includes `{language}` argument
  [`:help vim.treesitter.language.get_filetypes()`](https://neovim.io/doc/user/treesitter#vim.treesitter.language.get_filetypes())
- **`vim.treesitter.language.get_lang()`** — Falls back to `{filetype}` argument if no languages registered
  [`:help vim.treesitter.language.get_lang()`](https://neovim.io/doc/user/treesitter#vim.treesitter.language.get_lang())
- **`vim.treesitter.language.add()`** — Returns `true`/`nil,errmsg` instead of throwing error
  [`:help vim.treesitter.language.add()`](https://neovim.io/doc/user/treesitter#vim.treesitter.language.add())

---

## Editor

### New Default Mappings

| Mapping | Mode | Action | Help |
|---|---|---|---|
| `<Tab>` | Insert, Select | `vim.snippet.jump({ direction = 1 })` | [`:help i_CTRL-I`](https://neovim.io/doc/user/index#i_CTRL-I) |
| `<S-Tab>` | Insert, Select | `vim.snippet.jump({ direction = -1 })` | [`:help i_CTRL-I`](https://neovim.io/doc/user/index#i_CTRL-I) |
| `[d` / `]d` | Normal | Jump to prev/next diagnostic (accepts count) | [`:help ]d-default`](https://neovim.io/doc/user/diagnostic/#]d-default) |
| `[D` / `]D` | Normal | Jump to first/last diagnostic in buffer | [`:help ]D-default`](https://neovim.io/doc/user/diagnostic/#]D-default) |
| `[q` / `]q` | Normal | Navigate quickfix list (vim-unimpaired style) | [`:help ]q`](https://neovim.io/doc/user/quickfix#]q) |
| `[l` / `]l` | Normal | Navigate location list | [`:help ]l`](https://neovim.io/doc/user/quickfix#]l) |
| `[b` / `]b` | Normal | Navigate buffer list | [`:help ]b`](https://neovim.io/doc/user/windows#]b) |
| `[<Space>` / `]<Space>` | Normal | Add empty line above/below cursor | [`:help ]<Space>`](https://neovim.io/doc/user/motion#]<Space>) |
| `[[` / `]]` | Normal | Jump between sections in help/checkhealth; shell prompts with OSC 133 | [`:help [[`](https://neovim.io/doc/user/motion#[[) |

### Editor Improvements

- **Improved paste handling** — Redoing large paste is faster, ignores `'autoindent'`; macros replay pasted text
  [`:help paste`](https://neovim.io/doc/user/intro#paste)
- **`gO`** — Works in `help`, `checkhealth`, and `markdown` buffers
  [`:help gO`](https://neovim.io/doc/user/motion#gO)
- **`hl-ComplMatchIns`** — Shows matched text of currently inserted completion
  [`:help hl-ComplMatchIns`](https://neovim.io/doc/user/syntax#hl-ComplMatchIns)
- **`hl-PmenuMatch`** / **`hl-PmenuMatchSel`** — Show matched text in completion popup
  [`:help hl-PmenuMatch`](https://neovim.io/doc/user/syntax#hl-PmenuMatch)
- **Mouse popup menu** — "Open in web browser" for URLs, "Go to definition" for LSP, "Show Diagnostics" items
  [`:help popup-menu`](https://neovim.io/doc/user/popup-menu#popup-menu)

---

## Lua APIs

### New APIs

| API | Description | Help |
|---|---|---|
| `vim.fs.rm()` | Delete files and directories | [`:help vim.fs.rm()`](https://neovim.io/doc/user/lua#vim.fs.rm()) |
| `vim.fs.abspath()` | Convert paths to absolute | [`:help vim.fs.abspath()`](https://neovim.io/doc/user/lua#vim.fs.abspath()) |
| `vim.fs.relpath()` | Get relative path compared to base | [`:help vim.fs.relpath()`](https://neovim.io/doc/user/lua#vim.fs.relpath()) |
| `vim.fs.dir()` / `vim.fs.find()` | Can follow symbolic links via `follow` option | [`:help vim.fs.dir()`](https://neovim.io/doc/user/lua#vim.fs.dir()) |
| `vim.text.indent()` | Indent/dedent text | [`:help vim.text.indent()`](https://neovim.io/doc/user/lua#vim.text.indent()) |
| `vim.validate()` | New signature, less tables, more performant | [`:help vim.validate()`](https://neovim.io/doc/user/lua#vim.validate()) |
| `vim.str_byteindex()` / `vim.str_utfindex()` | New overload signatures with `encoding` and `strict_indexing` | [`:help vim.str_byteindex()`](https://neovim.io/doc/user/lua#vim.str_byteindex()) |
| `vim.json.encode()` | Option to enable forward slash escaping | [`:help vim.json.encode()`](https://neovim.io/doc/user/lua#vim.json.encode()) |
| `vim.hl.range()` | Optional `timeout` field for timed highlights | [`:help vim.hl.range()`](https://neovim.io/doc/user/lua#vim.hl.range()) |
| `vim.ui.open()` | Open path/URL, accepts `opt.cmd` parameter (bound to `gx` by default) | [`:help vim.ui.open()`](https://neovim.io/doc/user/lua#vim.ui.open()) |
| `nvim__ns_set()` | Set properties for a namespace | [`:help nvim__ns_set()`](https://neovim.io/doc/user/api#nvim__ns_set()) |
| `nvim_open_win()` | `mouse` field for configuring mouse interaction; `relative` can be "laststatus"/"tabline" | [`:help nvim_open_win()`](https://neovim.io/doc/user/api#nvim_open_win()) |
| `nvim_buf_set_extmark()` | `conceal_lines` field; `hl_group` as array of layered groups; `virt_text_pos` "eol_right_align"; `virt_lines_overflow` "scroll" | [`:help nvim_buf_set_extmark()`](https://neovim.io/doc/user/api#nvim_buf_set_extmark()) |
| `nvim_echo()` | `err` field for error messages; `chunks` accepts highlight group IDs | [`:help nvim_echo()`](https://neovim.io/doc/user/api#nvim_echo()) |

### Lua Improvements

- **Command-line completions** for `vim.g`, `vim.t`, `vim.w`, `vim.b`, `vim.v`, `vim.o`, `vim.wo`, `vim.bo`, `vim.opt`, `vim.opt_local`, `vim.opt_global`, `vim.fn`
- **`gf` in Lua buffers** — Can go to module in same repo, runtime-search-path, and package.path
  [`:help gf`](https://neovim.io/doc/user/motion#gf)
- **API returns** — Consistently return empty dictionary as `vim.empty_dict()` instead of `lua-special-tbl`
  [`:help vim.empty_dict()`](https://neovim.io/doc/user/lua#vim.empty_dict())
- **`vim.json.encode()`** — No longer escapes forward slashes "/" by default

---

## Terminal

- **OSC 52** — Clipboard copy sequence supported; used as fallback when no other clipboard tool found
  [`:help clipboard-osc52`](https://neovim.io/doc/user/provider#clipboard-osc52)
- **OSC 8** — Hyperlinks displayed in supporting host terminals
- **Reflow** — Wrapped lines adapt when buffer resized horizontally
- **Cursor** — Terminal uses actual cursor (escape codes can change shape/visibility); `TermCursorNC` highlight group removed
  [`:help TermCursorNC`](https://neovim.io/doc/user/syntax#TermCursorNC)
- **Kitty keyboard protocol** — Experimental support for "Disambiguate escape codes" mode
- **Theme notifications** — Sends theme update notifications when `'background'` changed (DEC mode 2031)
- **`jobstart()`** — Gained "term" flag
  [`:help jobstart()`](https://neovim.io/doc/user/lua#jobstart())
- **`TermRequest`** — Emitted when child process sends APC control sequence; has "cursor" field in event-data
  [`:help TermRequest`](https://neovim.io/doc/user/autocmd#TermRequest)
- **`hl-StatusLineTerm`** / **`hl-StatusLineTermNC`** — Highlights for status line in terminal windows
  [`:help hl-StatusLineTerm`](https://neovim.io/doc/user/syntax#hl-StatusLineTerm)
- **Terminal bells** — Silent by default unless `'belloff'` doesn't contain "term" or "all"
  [`:help 'belloff'`](https://neovim.io/doc/user/options#'belloff')

---

## UI

- **`:detach`** — Detach current UI, let Nvim server continue as background process
  [`:help :detach`](https://neovim.io/doc/user/starting#:detach)
- **`vim.ui.open()`** — Supports lemonade for opening URLs/files over SSH
  [`:help vim.ui.open()`](https://neovim.io/doc/user/lua#vim.ui.open())
- **`:checkhealth`** — Can display in floating window (controlled by `g:health`)
  [`:help :checkhealth`](https://neovim.io/doc/user/health#:checkhealth)
- **Ins-completion-menu** — Supports cascading highlight styles (`hl-PmenuSel` inherits from `hl-Pmenu`, etc.)
  [`:help ins-completion-menu`](https://neovim.io/doc/user/cmdline#ins-completion-menu)
- **`ui-messages`** — Content chunks contain highlight group ID
  [`:help ui-messages`](https://neovim.io/doc/user/ui/#ui-messages)
- **`vim.on_key()`** — Callbacks can consume key by returning empty string; won't be invoked recursively
  [`:help vim.on_key()`](https://neovim.io/doc/user/lua#vim.on_key())

---

## Options

| Option | Description | Help |
|---|---|---|
| `'completeopt'` | New flags: `fuzzy` (fuzzy matching), `preinsert` (highlight text to insert) | [`:help 'completeopt'`](https://neovim.io/doc/user/options#'completeopt') |
| `'wildmode'` | New flag `noselect` (shows wildmenu without selecting entry) | [`:help 'wildmode'`](https://neovim.io/doc/user/options#'wildmode') |
| `'messagesopt'` | Configures `:messages` and hit-enter prompt | [`:help 'messagesopt'`](https://neovim.io/doc/user/options#'messagesopt') |
| `'tabclose'` | Controls which tab page to focus when closing | [`:help 'tabclose'`](https://neovim.io/doc/user/options#'tabclose') |
| `'eventignorewin'` | Persistently ignore events in a window | [`:help 'eventignorewin'`](https://neovim.io/doc/user/options#'eventignorewin') |
| `'winborder'` | Sets default border for floating windows | [`:help 'winborder'`](https://neovim.io/doc/user/options#'winborder') |
| `'diffopt'` | Default includes `linematch:40` | [`:help 'diffopt'`](https://neovim.io/doc/user/options#'diffopt') |
| `'statuscolumn'` | `%l` item now handles number column segment properly; `%r` no longer treated specially | [`:help 'statuscolumn'`](https://neovim.io/doc/user/options#'statuscolumn') |

---

## Performance

| Improvement | Details |
|---|---|
| **LSP de-duplication** | Diagnostics and inlay hints de-duplicated; new requests cancel inflight requests |
| **10x foldexpr speedup** | `vim.treesitter.foldexpr()` when no parser exists |
| **Query caching** | Strong caching for `query.get()` and `query.parse()` |
| **Async treesitter** | Highlighting, folding, injection queries all asynchronous |
| **10x less blocking** | When attaching LSP to large buffer |
| **Range-limited parsing** | `LanguageTree:parse()` only runs injection query on provided range |
| **Redo paste speedup** | Significantly faster, ignores `'autoindent'` |

---

## Breaking Changes

| Change | Details | Help |
|---|---|---|
| `vim.rpcnotify(0)` | Broadcasts to ALL channels (was multicast to subscribed) | [`:help vim.rpcnotify()`](https://neovim.io/doc/user/lua#vim.rpcnotify()) |
| "Dictionary" → "Dict" | Renamed internally and in RPC api-metadata | [`:help api-metadata`](https://neovim.io/doc/user/api#api-metadata) |
| `nvim__id_dictionary` | Renamed to `nvim__id_dict` | [`:help nvim__id_dict()`](https://neovim.io/doc/user/api#nvim__id_dict()) |
| Diagnostic signs order | Higher priority signs now appear left of lower priority | [`:help sign-place`](https://neovim.io/doc/user/sign#sign-place) |
| `hl-CurSearch` | No longer updates on every cursor movement | [`:help hl-CurSearch`](https://neovim.io/doc/user/syntax#hl-CurSearch) |
| `:bnext` behavior | Skips help buffers from non-help buffers | [`:help :bnext`](https://neovim.io/doc/user/windows#:bnext) |
| `vim.on_key()` | Won't be invoked recursively when callback consumes input | [`:help vim.on_key()`](https://neovim.io/doc/user/lua#vim.on_key()) |
| `TermRequest` / `TermResponse` | Event-data is now a table with "sequence" field | [`:help TermRequest`](https://neovim.io/doc/user/autocmd#TermRequest) |
| `TermCursorNC` | Removed; unfocused terminals have no cursor | [`:help TermCursorNC`](https://neovim.io/doc/user/syntax#TermCursorNC) |
| `v:msgpack_types` | "binary" type removed | [`:help v:msgpack_types`](https://neovim.io/doc/user/eval#v:msgpack_types) |
| `:set {option}<` | Removes local value for all global-local options | [`:help :set<`](https://neovim.io/doc/user/options#:set<) |
| `:setlocal {option}<` | Copies global value to local for number/boolean global-local | [`:help :setlocal`](https://neovim.io/doc/user/options#:setlocal) |
| Hidden options | Setting gives error; `noshellslash` only allowed on Windows | [`:help hidden-options`](https://neovim.io/doc/user/options#hidden-options) |
| `msgpackparse()` | BIN, STR, FIXSTR all returned as string or blob | [`:help msgpackparse()`](https://neovim.io/doc/user/lua#msgpackparse()) |

---

## Defaults

### Terminal Buffers

- `'number'`, `'relativenumber'`, `'signcolumn'`, `'foldcolumn'` disabled in terminal buffers
  [`:help terminal-config`](https://neovim.io/doc/user/terminal#terminal-config)

### Lua Buffers

- `'omnifunc'` set to `v:lua.vim.lua_omnifunc`
- `'foldexpr'` set to `v:lua.vim.treesitter.foldexpr()`

### Highlighting

- Improved styling of `:checkhealth` and `:help` buffers

---

## Startup

- **`-es`** ("script mode") — Disables shada by default
  [`:help -es`](https://neovim.io/doc/user/starting#-es)
- **`--listen`** / **`$NVIM_LISTEN_ADDRESS`** — Nvim fails if address is invalid (was silently skipped)
  [`:help --listen`](https://neovim.io/doc/user/starting#--listen)

---

## Plugins

- **EditorConfig** — `spelling_language` property now supported
  [`:help editorconfig`](https://neovim.io/doc/user/editorconfig#editorconfig)
- **`'inccommand'`** — Incremental preview can run on `'nomodifiable'` buffers
  [`:help 'inccommand'`](https://neovim.io/doc/user/options#'inccommand')
- **Commenting** — `'commentstring'` values can be specified in Treesitter capture's `bo.commentstring` metadata (finer grained support for JSX, etc.)
  [`:help 'commentstring'`](https://neovim.io/doc/user/options#'commentstring')

---

## Community Resources

### YouTube Videos

| Video | Channel | Date | Description |
|---|---|---|---|
| [Neovim 0.11: What's New?](https://www.youtube.com/watch?v=ZiH59zg59kg) | DevOnDuty | Mar 29, 2025 | Concise overview of major features and changes |
| [How to Setup Neovim LSP Like A Pro in 2025 (v0.11+)](https://www.youtube.com/watch?v=9C565FDD53C52E11D37A) | Josean Martinez | ~Nov 2024 | Comprehensive tutorial on new `vim.lsp.config()` and `vim.lsp.enable()` APIs |
| [Neovim Setup For Coding V0.11+](https://www.youtube.com/watch?v=pN2sum5Anm0) | Jonkero | — | Coding-focused setup targeting 0.11+ |
| [State of Neovim 2024](https://www.youtube.com/watch?v=TUzB_PFJA) | Justin M. Keyes | Feb 2025 | Official keynote at VimconfLive Tokyo covering project direction and roadmap |

### Blog Posts

| Post | Author | Date | Description |
|---|---|---|---|
| [What's New in Neovim 0.11](https://gpanders.com/blog/whats-new-in-neovim-0-11/) | Gregory Anders (gpanders) | Mar 26, 2025 | Official Neovim 0.11 newsletter; definitive community overview |
| [Official Release Notes](https://neovim.io/doc/user/news-0.11.html) | Neovim Core Team | Mar 2025 | Complete authoritative changelog (`:h news-0.11`) |
| [Neovim's Future Could Have AI and Brain-Computer Interfaces](https://thenewstack.io/neovims-future-could-have-ai-and-brain-computer-interfaces/) | David Cassel | Mar 2, 2025 | Coverage of Justin Keyes' keynote; broader vision for Neovim |

---

## Key Significance

Neovim 0.11 was the **foundational release** that introduced:

1. **`vim.lsp.config()` / `vim.lsp.enable()`** — The API that made nvim-lspconfig optional and became the standard in 0.12
2. **Builtin auto-completion** — `vim.lsp.completion.enable()` opened the door to replacing completion plugins
3. **Async Treesitter** — Massive performance improvements for highlighting and folding
4. **Virtual lines diagnostics** — Upstreamed from lsp_lines.nvim, changed how diagnostics are displayed
5. **Default LSP mappings** — Made Neovim usable out-of-the-box for LSP workflows
