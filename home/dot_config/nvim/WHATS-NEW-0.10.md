# What's New in Neovim 0.10

> Released May 16, 2024

---

## LSP

### New Features

- **LSP inlay hints** — Native inline type annotations from language servers
  [`:help lsp-inlay_hint`](https://neovim.io/doc/user/lsp/#lsp-inlay_hint)
- **Pull diagnostics** — `textDocument/diagnostic` method support via `vim.lsp.diagnostic.on_diagnostic()`
  [`:help vim.lsp.diagnostic.on_diagnostic()`](https://neovim.io/doc/user/lsp/#vim.lsp.diagnostic.on_diagnostic())
- **LSP type hierarchy** — `vim.lsp.buf.typehierarchy()` for type navigation
  [`:help vim.lsp.buf.typehierarchy()`](https://neovim.io/doc/user/lsp/#vim.lsp.buf.typehierarchy())
- **Dynamic registration** — LSP capabilities can be registered dynamically; use `client.supports_method()` instead of checking `server_capabilities`
  [`:help lsp-dynamic-registration`](https://neovim.io/doc/user/lsp/#lsp-dynamic-registration)
- **`positionEncoding` support** — Client automatically sets `offset_encoding` from server capability
  [`:help lsp-client`](https://neovim.io/doc/user/lsp/#lsp-client)
- **Named pipe / Unix domain socket** — Connect to servers via `vim.lsp.rpc.connect()`
  [`:help vim.lsp.rpc.connect()`](https://neovim.io/doc/user/lsp/#vim.lsp.rpc.connect())
- **`completionList.itemDefaults`** — Reduces overhead when completion items share properties
  [`:help lsp-completion`](https://neovim.io/doc/user/lsp/#lsp-completion)
- **`vim.lsp.start()`** — Accepts `silent` option to suppress error messages
  [`:help vim.lsp.start()`](https://neovim.io/doc/user/lsp/#vim.lsp.start())
- **`vim.lsp.status()`** — Consumes last progress messages as string
  [`:help vim.lsp.status()`](https://neovim.io/doc/user/lsp/#vim.lsp.status())
- **Method names** — Available in `vim.lsp.protocol.Methods`
  [`:help vim.lsp.protocol.Methods`](https://neovim.io/doc/user/lsp/#vim.lsp.protocol.Methods)
- **Buffer marks** — Client saves/restores named buffer marks when applying text edits
- **`loclist` support** — `definition()`, `declaration()`, `type_definition()`, `implementation()` support `loclist` field of `vim.lsp.ListOpts`
  [`:help vim.lsp.ListOpts`](https://neovim.io/doc/user/lsp/#vim.lsp.ListOpts)
- **`anchor_bias`** — Option to `lsp-handlers` for positioning floating windows
  [`:help lsp-handlers`](https://neovim.io/doc/user/lsp/#lsp-handlers)
- **`vim.lsp.util.locations_to_items()`** — Sets `user_data` to original LSP `Location` or `LocationLink`
  [`:help vim.lsp.util.locations_to_items()`](https://neovim.io/doc/user/lsp/#vim.lsp.util.locations_to_items())

### Default LSP Mappings

| Mapping | Mode | Action | Help |
|---|---|---|---|
| `K` | Normal | `vim.lsp.buf.hover()` (unless `'keywordprg'` customized) | [`:help K-lsp-default`](https://neovim.io/doc/user/lsp/#K-lsp-default) |

### LSP Breaking Changes

- **Multi-client merging** — `references()`, `declaration()`, `definition()`, `type_definition()`, `implementation()`, `hover()` merge results from multiple clients but no longer trigger global handlers from `vim.lsp.handlers`
  [`:help vim.lsp.buf.references()`](https://neovim.io/doc/user/lsp/#vim.lsp.buf.references())
- **`vim.lsp.util.parse_snippet()`** — Strictly follows LSP snippet grammar; previously valid snippets may now be invalid
  [`:help vim.lsp.util.parse_snippet()`](https://neovim.io/doc/user/lsp/#vim.lsp.util.parse_snippet())
- **`vim.lsp.codelens.refresh()`** — Takes `opts` argument; default behavior changed from current buffer to all buffers
  [`:help vim.lsp.codelens.refresh()`](https://neovim.io/doc/user/lsp/#vim.lsp.codelens.refresh())
- **`vim.lsp.util.extract_completion_items()`** — No longer returns reliable results with `itemDefaults`
  [`:help vim.lsp.util.extract_completion_items()`](https://neovim.io/doc/user/lsp/#vim.lsp.util.extract_completion_items())
- **`LspRequest`** / **`LspProgress`** — Promoted from `User` autocmds to first-class citizens
  [`:help LspRequest`](https://neovim.io/doc/user/lsp/#LspRequest), [`:help LspProgress`](https://neovim.io/doc/user/lsp/#LspProgress)

### LSP Changed Behavior

- **Hover/signature help** — Uses Treesitter for Markdown highlighting; code examples require matching parser
  [`:help lsp-hover`](https://neovim.io/doc/user/lsp/#lsp-hover)
- **`LspRequest` callbacks** — Contain more information about request status update
  [`:help LspRequest`](https://neovim.io/doc/user/lsp/#LspRequest)

---

## Diagnostics

- **Default mappings** — `]d` / `[d` for next/prev diagnostic; `<C-W>d` for diagnostic float
  [`:help ]d-default`](https://neovim.io/doc/user/diagnostic/#]d-default), [`:help CTRL-W_d-default`](https://neovim.io/doc/user/diagnostic/#CTRL-W_d-default)
- **`vim.diagnostic.count()`** — Returns number of diagnostics by severity (faster than `get()` when only count needed)
  [`:help vim.diagnostic.count()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.count())
- **`vim.diagnostic.is_enabled()`** — Check if diagnostics are enabled
  [`:help vim.diagnostic.is_enabled()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.is_enabled())
- **`vim.diagnostic.config()`** — Accepts virtual text options from `nvim_buf_set_extmark()` (`virt_text_pos`, `hl_mode`); `virtual_text.prefix` accepts a function
  [`:help vim.diagnostic.config()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.config())
- **`vim.diagnostic.get()`** / **`vim.diagnostic.count()`** — Accept multiple namespaces
  [`:help vim.diagnostic.get()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.get())
- **`vim.diagnostic.enable()`** — Gained new parameters; old signature deprecated
  [`:help vim.diagnostic.enable()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.enable())
- **Severity parameter** — Functions accepting severity now also accept list of severities
  [`:help vim.diagnostic.severity`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.severity)
- **`workspace/didChangeWatchedFiles`** — Enabled by default on Mac/Windows; disabled on Linux (no scalable backend)
  [`:help lsp-client-capabilities`](https://neovim.io/doc/user/lsp/#lsp-client-capabilities)

---

## Treesitter

### New Features

- **Bundled parsers** — Markdown, Python, and Bash parsers and queries (highlight, folds) included
- **`:InspectTree`** — Shows root nodes, supports folding, uses 0-based indexing
  [`:help :InspectTree`](https://neovim.io/doc/user/treesitter#:InspectTree)
- **`vim.treesitter.foldexpr()`** — Recognizes folds captured using quantified query patterns
  [`:help vim.treesitter.foldexpr()`](https://neovim.io/doc/user/treesitter#vim.treesitter.foldexpr())
- **`vim.treesitter.query.omnifunc()`** — Completion in treesitter query files (set by default)
  [`:help vim.treesitter.query.omnifunc()`](https://neovim.io/doc/user/treesitter#vim.treesitter.query.omnifunc())
- **`vim.treesitter.query.edit()`** — Live editing of treesitter queries
  [`:help vim.treesitter.query.edit()`](https://neovim.io/doc/user/treesitter#vim.treesitter.query.edit())
- **`Query:iter_matches()`** — Can set maximum start depth for matches
  [`:help Query:iter_matches()`](https://neovim.io/doc/user/treesitter#Query:iter_matches())
- **`@injection.language`** — Smarter resolution with language aliases and lowercase fallback
  [`:help @injection.language`](https://neovim.io/doc/user/treesitter#@injection.language)
- **`@injection.filename`** — Matches node text via `vim.filetype.match()`
  [`:help @injection.filename`](https://neovim.io/doc/user/treesitter#@injection.filename)
- **`#set!` directive** — Supports `injection.self` and `injection.parent`
  [`:help treesitter-directive-set!`](https://neovim.io/doc/user/treesitter#treesitter-directive-set!)
- **Hyperlinks in queries** — `#set!` can set "url" property on nodes
  [`:help treesitter-directive-set!`](https://neovim.io/doc/user/treesitter#treesitter-directive-set!)
- **Improved error messages** — For query parsing

### Treesitter Breaking Changes

- **Highlight groups renamed** — Aligned with upstream tree-sitter and Helix for easier query sharing
  [`:help treesitter-highlight-groups`](https://neovim.io/doc/user/treesitter#treesitter-highlight-groups)
- **`LanguageTree:parse()`** — No longer parses injections by default; requires explicit range argument
  [`:help LanguageTree:parse()`](https://neovim.io/doc/user/treesitter#LanguageTree:parse())
- **Legacy injection queries** — Support removed
- **`vim.treesitter.playground`** — Renamed to `vim.treesitter.dev`
  [`:help vim.treesitter.dev`](https://neovim.io/doc/user/treesitter#vim.treesitter.dev)
- **`Query:iter_matches()`** / **`vim.treesitter.query.add_predicate()`** / **`vim.treesitter.query.add_directive()`** — Accept `all` option; `all=false` is backwards compat (will be removed after 0.10)
  [`:help Query:iter_matches()`](https://neovim.io/doc/user/treesitter#Query:iter_matches())
- **`add_predicate()`** / **`add_directive()`** — Accept options table instead of boolean `force` argument
  [`:help vim.treesitter.query.add_predicate()`](https://neovim.io/doc/user/treesitter#vim.treesitter.query.add_predicate())

### Treesitter Changed Behavior

- **Incremental injection parsing** — Parses injections incrementally during screen redraws for rendered line range only; significant performance improvement in large files
  [`:help treesitter-highlight`](https://neovim.io/doc/user/treesitter#treesitter-highlight)

---

## Editor

### New Features

- **Builtin commenting** — Treesitter-aware commenting built into core (replaces vim-commentary)
  [`:help commenting`](https://neovim.io/doc/user/commenting#commenting)
- **Better cmdline completion** — For string option values (try `:set listchars=<Tab>`)
  [`:help complete-set-option`](https://neovim.io/doc/user/cmdline#complete-set-option)
- **Swapfile dialog** — Skipped if swapfile owned by running Nvim process; delete `autocmd! nvim_swapfile` to always show
  [`:help default-autocmds`](https://neovim.io/doc/user/default-autocmds)
- **Jumplist** — Better behavior when deleting buffers; avoids "invalid buffer" cases
  [`:help jumplist`](https://neovim.io/doc/user/motion#jumplist)
- **`:fclose`** — Close file command
  [`:help :fclose`](https://neovim.io/doc/user/editing#:fclose)
- **`v_Q-default`** / **`v_@-default`** — Repeat register for each line of linewise visual selection
  [`:help v_Q-default`](https://neovim.io/doc/user/index#v_Q-default)
- **Middle mouse button** — Clicking tabpage in tabline closes it
- **`:checkhealth`** — Can be opened in split window using modifiers (`:vertical`, `:horizontal`, `:botright`)
  [`:help :checkhealth`](https://neovim.io/doc/user/health#:checkhealth)
- **Automatic query linting** — Treesitter query files linted automatically; disable via `vim.g.query_lint_on = {}`
  [`:help ft-query-plugin`](https://neovim.io/doc/user/treesitter#ft-query-plugin)

### Default Mappings

| Mapping | Mode | Action | Help |
|---|---|---|---|
| `]d` / `[d` | Normal | Next/prev diagnostic | [`:help ]d-default`](https://neovim.io/doc/user/diagnostic/#]d-default) |
| `<C-W>d` / `<C-W><C-D>` | Normal | Open diagnostic float | [`:help CTRL-W_d-default`](https://neovim.io/doc/user/diagnostic/#CTRL-W_d-default) |
| `gx` | Normal | `vim.ui.open()` (replaces netrw) | [`:help gx`](https://neovim.io/doc/user/motion#gx) |

### Editor Breaking Changes

- **`CursorMoved`** — Triggers when Nvim is back on main loop rather than immediately (more Vim-compatible)
  [`:help CursorMoved`](https://neovim.io/doc/user/autocmd#CursorMoved)
- **`#` followed by digit** — No longer stands for function key at start of mapping lhs
- **`shm-q`** — Fully hides macro recording message instead of shortening
  [`:help shm-q`](https://neovim.io/doc/user/options#shm-q)
- **Legacy signs** — Stored and displayed as extmarks internally; sign behavior changed
  [`:help sign-commands`](https://neovim.io/doc/user/sign#sign-commands)
- **`:behave`** — Removed; use equivalent `set` commands
  [`:help :behave`](https://neovim.io/doc/user/various#:behave)

### Editor Changed Behavior

- **`gx`** — Uses `vim.ui.open()` instead of netrw
  [`:help vim.ui.open()`](https://neovim.io/doc/user/lua#vim.ui.open())

---

## Lua APIs

### New APIs

| API | Description | Help |
|---|---|---|
| `vim.system()` | Run commands / start processes (async) | [`:help vim.system()`](https://neovim.io/doc/user/lua#vim.system()) |
| `vim.iter()` | Generic interface for all iterable objects | [`:help vim.iter()`](https://neovim.io/doc/user/lua#vim.iter()) |
| `vim.snippet` | Expand and navigate snippets | [`:help vim.snippet`](https://neovim.io/doc/user/lua#vim.snippet) |
| `vim.ringbuf()` | Generic ring buffer data structure | [`:help vim.ringbuf()`](https://neovim.io/doc/user/lua#vim.ringbuf()) |
| `vim.keycode()` | Translate keycodes in a string | [`:help vim.keycode()`](https://neovim.io/doc/user/lua#vim.keycode()) |
| `vim.lpeg` / `vim.re` | Bundled LPeg expression grammar parser and regex interface | [`:help vim.lpeg`](https://neovim.io/doc/user/lua#vim.lpeg) |
| `vim.base64.encode()` / `vim.base64.decode()` | Base64 encoding/decoding | [`:help vim.base64.encode()`](https://neovim.io/doc/user/lua#vim.base64.encode()) |
| `vim.text.hexencode()` / `vim.text.hexdecode()` | Hex encoding/decoding | [`:help vim.text.hexencode()`](https://neovim.io/doc/user/lua#vim.text.hexencode()) |
| `vim.ui.open()` | Open URIs with system default handler (`open`, `explorer`, `xdg-open`) | [`:help vim.ui.open()`](https://neovim.io/doc/user/lua#vim.ui.open()) |
| `vim.fs.root()` | Find project root directories from root markers | [`:help vim.fs.root()`](https://neovim.io/doc/user/lua#vim.fs.root()) |
| `vim.version.le()` / `vim.version.ge()` | Version comparison | [`:help vim.version.le()`](https://neovim.io/doc/user/lua#vim.version.le()) |
| `vim.isarray()` | Check for integer keys (allowing gaps) | [`:help vim.isarray()`](https://neovim.io/doc/user/lua#vim.isarray()) |
| `vim.deepcopy()` | Gained `noref` argument to avoid hashing | [`:help vim.deepcopy()`](https://neovim.io/doc/user/lua#vim.deepcopy()) |
| `vim.tbl_contains()` | Works for general tables; accepts predicate function | [`:help vim.tbl_contains()`](https://neovim.io/doc/user/lua#vim.tbl_contains()) |
| `vim.list_contains()` | Check list-like tables for literal values | [`:help vim.list_contains()`](https://neovim.io/doc/user/lua#vim.list_contains()) |
| `vim.region()` | Can use string accepted by `getpos()` as position | [`:help vim.region()`](https://neovim.io/doc/user/lua#vim.region()) |
| `vim.wo` | Double-indexed for `:setlocal` behavior (`vim.wo[0]`) | [`:help vim.wo`](https://neovim.io/doc/user/lua#vim.wo) |
| `nvim_win_text_height()` | Compute screen lines occupied by text range | [`:help nvim_win_text_height()`](https://neovim.io/doc/user/api#nvim_win_text_height()) |
| `nvim_tabpage_set_win()` | Set current window of a tabpage | [`:help nvim_tabpage_set_win()`](https://neovim.io/doc/user/api#nvim_tabpage_set_win()) |
| `nvim__win_add_ns()` | Bind namespace to window-local scope | [`:help nvim__win_add_ns()`](https://neovim.io/doc/user/api#nvim__win_add_ns()) |

### Lua Improvements

- **`:lua` with range** — Execute range as Lua code in any buffer
  [`:help :lua`](https://neovim.io/doc/user/lua#:lua)
- **`:source` without arguments** — Treats Lua filetype buffer as Lua code regardless of extension
  [`:help :source`](https://neovim.io/doc/user/lua#:source)
- **`exists()`** — Supports checking `v:lua` functions
  [`:help exists()`](https://neovim.io/doc/user/builtin#exists())
- **Type annotations** — For `vim.*`, `vim.fn.*`, `vim.api.*`, `vim.v.*`
- **API error messages** — Improved messages for type errors (including `opts` params)
- **`nvim_buf_call()`** / **`nvim_win_call()`** — Preserve return value
  [`:help nvim_buf_call()`](https://neovim.io/doc/user/api#nvim_buf_call())
- **`nvim_get_chan_info(0)`** — Gets info about current channel
  [`:help nvim_get_chan_info()`](https://neovim.io/doc/user/api#nvim_get_chan_info())
- **`nvim_input_mouse()`** — Supports mouse buttons "x1" and "x2"
  [`:help nvim_input_mouse()`](https://neovim.io/doc/user/api#nvim_input_mouse())
- **Mapping APIs** — Support abbreviations when mode short-name has suffix "a"
  [`:help nvim_set_keymap()`](https://neovim.io/doc/user/api#nvim_set_keymap())

### Lua Breaking Changes

- **`-l`** — Ensures output ends with newline if script prints messages
  [`:help -l`](https://neovim.io/doc/user/starting#-l)
- **`vim.json`** — Removed undocumented functions, `vim.json.null` (redundant with `vim.NIL`), `vim.json.array_mt` (redundant with `vim.empty_dict()`)
  [`:help vim.json`](https://neovim.io/doc/user/lua#vim.json)
- **`vim.islist()`** — Now checks for list-like tables (integer keys without gaps, starting from 1); use `vim.isarray()` for previous behavior
  [`:help vim.islist()`](https://neovim.io/doc/user/lua#vim.islist())
- **`vim.wait()`** — Cannot be called in `api-fast` context
  [`:help vim.wait()`](https://neovim.io/doc/user/lua#vim.wait())

---

## Terminal

- **OSC 52 clipboard** — Bundled by default; automatically enabled under certain conditions; syncs system clipboard over SSH
  [`:help clipboard-osc52`](https://neovim.io/doc/user/provider#clipboard-osc52)
- **OSC 8 hyperlinks** — Clickable links in supporting terminals
  [`:help hl-Underlined`](https://neovim.io/doc/user/syntax#hl-Underlined)
- **`'termsync'`** — Synchronized terminal output to reduce flickering; requires host terminal support
  [`:help 'termsync'`](https://neovim.io/doc/user/options#'termsync')
- **`:terminal`** — Accepts command modifiers (`:horizontal`, window-splitting modifiers)
  [`:help :terminal`](https://neovim.io/doc/user/terminal#:terminal)
- **`TermRequest`** — Emitted when child process sends OSC or DCS control sequence
  [`:help TermRequest`](https://neovim.io/doc/user/autocmd#TermRequest)
- **OSC background/foreground** — Terminal buffers respond to background and foreground requests
  [`:help default-autocmds`](https://neovim.io/doc/user/default-autocmds)
- **Auto-close** — Terminal buffers started with no arguments close automatically if job exited without error
  [`:help default-autocmds`](https://neovim.io/doc/user/default-autocmds)
- **`nvim_open_term()`** — Gained `force_crlf` option field
  [`:help nvim_open_term()`](https://neovim.io/doc/user/api#nvim_open_term())

---

## UI

- **Enhanced multibyte rendering** — Maximum limit increased from 1+6 codepoints to 31 bytes
  [`:help mbyte-combining`](https://neovim.io/doc/user/mbyte#mbyte-combining)
- **Extmark URLs** — Extmarks can set "url" highlight attribute; TUI renders via OSC 8
  [`:help nvim_buf_set_extmark()`](https://neovim.io/doc/user/api#nvim_buf_set_extmark())
- **Floating window footer** — `footer` and `footer_pos` config fields; uses `hl-FloatFooter`
  [`:help nvim_open_win()`](https://neovim.io/doc/user/api#nvim_open_win())
- **Floating window hide** — Can be hidden via `hide` in `nvim_open_win()` or `nvim_win_set_config()`
  [`:help nvim_open_win()`](https://neovim.io/doc/user/api#nvim_open_win())
- **Split windows** — `nvim_open_win()` and `nvim_win_set_config()` support opening/moving split windows
  [`:help nvim_open_win()`](https://neovim.io/doc/user/api#nvim_open_win())
- **Extmark flags** — `undo_restore`, `invalidate`, `virt_text_repeat_linebreak`
  [`:help nvim_buf_set_extmark()`](https://neovim.io/doc/user/api#nvim_buf_set_extmark())
- **Multi-line extmarks** — Fully supported; signs apply to every line in range; `nvim_buf_get_extmarks()` gained `overlap` option
  [`:help nvim_buf_set_extmark()`](https://neovim.io/doc/user/api#nvim_buf_set_extmark())
- **Inline virtual text** — Supported via `nvim_buf_set_extmark()`
  [`:help nvim_buf_set_extmark()`](https://neovim.io/doc/user/api#nvim_buf_set_extmark())
- **`vim.on_key()`** — Callbacks receive second argument for keys typed before mappings applied
  [`:help vim.on_key()`](https://neovim.io/doc/user/lua#vim.on_key())

---

## Options

| Option | Description | Help |
|---|---|---|
| `'winfixbuf'` | Keep window focused on specific buffer | [`:help 'winfixbuf'`](https://neovim.io/doc/user/options#'winfixbuf') |
| `'smoothscroll'` | Scroll by screen line rather than text line when `'wrap'` set | [`:help 'smoothscroll'`](https://neovim.io/doc/user/options#'smoothscroll') |
| `'foldtext'` | Supports virtual text format; empty string disables and renders line normally | [`:help 'foldtext'`](https://neovim.io/doc/user/options#'foldtext') |
| `'complete'` | New "f" flag for completing buffer names | [`:help 'complete'`](https://neovim.io/doc/user/options#'complete') |
| `'completeopt'` | New "popup" flag to show extra info in floating window | [`:help 'completeopt'`](https://neovim.io/doc/user/options#'completeopt') |
| `'errorfile'` | Accepts `-` as alias for stdin | [`:help 'errorfile'`](https://neovim.io/doc/user/options#'errorfile') |
| `'termguicolors'` | Enabled by default when terminal supports 24-bit color | [`:help 'termguicolors'`](https://neovim.io/doc/user/options#'termguicolors') |

### Options Breaking Changes

- **`'backspace'`** — No longer supports number values; use string values instead
  [`:help 'backspace'`](https://neovim.io/doc/user/options#'backspace')
- **`'backupdir'`** / **`'directory'`** — No longer remove `>` at start of option
  [`:help 'backupdir'`](https://neovim.io/doc/user/options#'backupdir')
- **`OptionSet`** — `v:option_new`, `v:option_old`, `v:option_oldlocal`, `v:option_oldglobal` now have option type instead of always strings
  [`:help v:option_new`](https://neovim.io/doc/user/eval#v:option_new)
- **Global-local options** — Local value for number/boolean global-local option now unset when set without scope
  [`:help global-local`](https://neovim.io/doc/user/options#global-local)

---

## Performance

| Improvement | Details |
|---|---|
| **Incremental injection parsing** — Treesitter parses injections only for rendered line range |
| **`'breakindent'`** — Significantly improved for wrapped lines |
| **Cursor movement** — Faster with `[count]` |
| **`screenpos()`** — Faster |
| **`'diffopt'` linematch** — Scoring algorithm favours larger, less groups ([PR #23611](https://github.com/neovim/neovim/pull/23611)) |

---

## Defaults

### Color Scheme

- **New default colorscheme** — "Nvim branded" and accessible; redesigned by Evgeni Chasnovski
- **`:colorscheme vim`** — Revert to old legacy color scheme
- **Highlight group changes:**
  - `hl-FloatBorder` — Linked to `hl-NormalFloat` instead of `hl-WinSeparator`
  - `hl-NormalFloat` — Not linked to `hl-Pmenu`
  - `hl-WinBar` — Different background
  - `hl-WinBarNC` — Similar to `hl-WinBar` but not bold
  - `hl-WinSeparator` — Linked to `hl-Normal` instead of `hl-VertSplit`

### Editor Defaults

- **`'termguicolors'`** — Enabled by default when terminal supports 24-bit color
- **`'isfname'`** — On Windows, does not include ":"; drive letters handled correctly
- **`'comments'`** — Includes "fb:•"
- **`'shortmess'`** — Includes "C" flag
- **`'grepprg'`** — Uses `-H` and `-I` flags; defaults to ripgrep if available

### Treesitter Defaults

- **Enabled highlighting for:**
  - Treesitter query files
  - Vim help files
  - Lua files

### Removed `shortmess` Flags

- **`shm-f`** — Always use "(3 of 5)", never "(file 3 of 5)"
- **`shm-i`** — Always use "[noeol]"
- **`shm-x`** — Always use "[dos]", "[unix]", "[mac]"
- **`shm-n`** — Always use "[New]"

---

## API

### New API Features

- **`nvim_open_win()`** — Blocks all autocommands when `noautocmd` set (not just buffer-setting ones)
  [`:help nvim_open_win()`](https://neovim.io/doc/user/api#nvim_open_win())
- **`msgpack-rpc` client type** — For fully MessagePack-RPC compliant clients
  [`:help nvim_set_client_info()`](https://neovim.io/doc/user/api#nvim_set_client_info())

---

## Plugins

- **`:Man`** — Supports `:hide` modifier to open page in current window; respects `'wrapmargin'`
  [`:help :Man`](https://neovim.io/doc/user/man#:Man)
- **`:TOhtml`** — Rewritten in Lua to support Nvim-specific decorations; many options removed
  [`:help :TOhtml`](https://neovim.io/doc/usr_05#:TOhtml)

---

## Startup

- **`$NVIM_APPNAME`** — Can be set to relative path instead of only name
  [`:help $NVIM_APPNAME`](https://neovim.io/doc/user/starting#$NVIM_APPNAME)
- **`--startuptime`** — Reports startup times for both processes (TUI + server) as separate sections
  [`:help --startuptime`](https://neovim.io/doc/user/starting#--startuptime)

---

## TUI

- **Super/Meta modifiers** — Recognize "super" (`<D-`) and "meta" (`<T-`) in terminal emulators supporting `tui-csiu`
  [`:help tui-csiu`](https://neovim.io/doc/user/ui#tui-csiu)
- **`TermResponse`** — Can be used with `v:termresponse` to read escape sequence responses
  [`:help TermResponse`](https://neovim.io/doc/user/autocmd#TermResponse)
- **Cursor blinking fix** — Fixed bug where cursor blinked without `'guicursor'` configured; add `set guicursor+=n-v-c:blinkon500-blinkoff500` if needed
  [`:help cursor-blinking`](https://neovim.io/doc/user/ui#cursor-blinking)

---

## Breaking Changes

| Change | Details | Help |
|---|---|---|
| `nvim_open_win()` | Blocks all autocommands when `noautocmd` set | [`:help nvim_open_win()`](https://neovim.io/doc/user/api#nvim_open_win()) |
| `CursorMoved` | Triggers on main loop return, not immediately | [`:help CursorMoved`](https://neovim.io/doc/user/autocmd#CursorMoved) |
| `#` digit mapping | No longer stands for function key at start of lhs | — |
| `shm-q` | Fully hides macro recording message | [`:help shm-q`](https://neovim.io/doc/user/options#shm-q) |
| Legacy signs | Stored/displayed as extmarks internally | [`:help sign-commands`](https://neovim.io/doc/user/sign#sign-commands) |
| `:behave` | Removed | [`:help :behave`](https://neovim.io/doc/user/various#:behave) |
| Autocmd callback | Any truthy value (not just `true`) deletes autocommand | [`:help nvim_create_autocmd()`](https://neovim.io/doc/user/api#nvim_create_autocmd()) |
| `LanguageTree:parse()` | Requires explicit range argument for injections | [`:help LanguageTree:parse()`](https://neovim.io/doc/user/treesitter#LanguageTree:parse()) |
| `vim.lsp.util.parse_snippet()` | Strictly follows LSP snippet grammar | [`:help vim.lsp.util.parse_snippet()`](https://neovim.io/doc/user/lsp/#vim.lsp.util.parse_snippet()) |
| `vim.lsp.codelens.refresh()` | Takes `opts`; default changed to all buffers | [`:help vim.lsp.codelens.refresh()`](https://neovim.io/doc/user/lsp/#vim.lsp.codelens.refresh()) |
| `vim.json` functions | Removed undocumented functions, `vim.json.null`, `vim.json.array_mt` | [`:help vim.json`](https://neovim.io/doc/user/lua#vim.json) |
| `vim.islist()` | Now checks for list-like tables (no gaps, starts from 1) | [`:help vim.islist()`](https://neovim.io/doc/user/lua#vim.islist()) |
| `'backspace'` | No longer supports number values | [`:help 'backspace'`](https://neovim.io/doc/user/options#'backspace') |
| `OptionSet` vars | Now have option type instead of always strings | [`:help v:option_new`](https://neovim.io/doc/user/eval#v:option_new) |
| Treesitter highlight groups | Renamed to align with upstream and Helix | [`:help treesitter-highlight-groups`](https://neovim.io/doc/user/treesitter#treesitter-highlight-groups) |
| Default colorscheme | Redesigned; highlight groups changed | [`:help colorscheme`](https://neovim.io/doc/user/syntax#colorscheme) |
| `TermCursorNC` | Removed (unfocused terminals have no cursor) | [`:help TermCursorNC`](https://neovim.io/doc/user/syntax#TermCursorNC) |
| Vimball support | Removed including `:Vimuntar` command | — |
| Legacy TS injection queries | Support removed | — |
| `shortmess` flags | `shm-f`, `shm-i`, `shm-x`, `shm-n` removed | [`:help 'shortmess'`](https://neovim.io/doc/user/options#'shortmess') |
| `vim.treesitter.playground` | Renamed to `vim.treesitter.dev` | [`:help vim.treesitter.dev`](https://neovim.io/doc/user/treesitter#vim.treesitter.dev) |
| `add_predicate()` / `add_directive()` | Accept options table instead of boolean `force` | [`:help vim.treesitter.query.add_predicate()`](https://neovim.io/doc/user/treesitter#vim.treesitter.query.add_predicate()) |

---

## Removed Features

- **Vimball support** — Including `:Vimuntar` command
- **Legacy Treesitter injection queries** — Support removed
- **`shortmess` flags** — `shm-f`, `shm-i`, `shm-x`, `shm-n`

---

## Community Resources

### YouTube Videos

| Video | Channel | Date | Description |
|---|---|---|---|
| [Neovim 0.10: What's New?](https://www.youtube.com/watch?v=ZiH59zg59kg) | DevOnDuty | May 16, 2024 | Concise overview of major features and changes |
| [nvim 0.10 feature review!](https://www.youtube.com/watch?v=TUzB_PFJA) | TJ Devries (teej_dv) | May 20, 2024 | In-depth 4.5hr livestream review; most thorough video coverage |
| [Exploring Neovim 0.10!](https://www.youtube.com/watch?v=TUzB_PFJA) | TJ Devries (teej_dv) | Jul 1, 2024 | Live exploration with tangents; features in action |

### Blog Posts

| Post | Author | Date | Description |
|---|---|---|---|
| [What's New in Neovim 0.10](https://gpanders.com/blog/whats-new-in-neovim-0-10/) | Gregory Anders (gpanders) | May 16, 2024 | Definitive community blog post; covers colorscheme, LSP, terminal UI, Treesitter |
| [Neovim 0.10 released](https://lwn.net/Articles/973917/) | LWN.net | May 16, 2024 | LWN coverage summarizing key changes |
| [Neovim v10 setup with InlayHints](https://medium.com/@vishakhpro2002/neovim-v10-setup-with-inlayhints-838a503b17dc) | Vishakh Prakash | Jun 19, 2024 | Practical guide for setting up LSP inlay hints |

### Official Resources

| Resource | URL | Description |
|---|---|---|
| [Official Release Notes](https://neovim.io/doc/user/news-0.10.html) | neovim.io | Complete changelog (`:h news-0.10`) |
| [GitHub Release](https://github.com/neovim/neovim/releases/tag/v0.10.0) | github.com | Downloads, checksums, release notes |

---

## Key Significance

Neovim 0.10 was the **maturity release** that brought:

1. **New default colorscheme** — Redesigned by Evgeni Chasnovski for accessibility and aesthetics
2. **LSP inlay hints** — Native inline type annotations, a highly requested IDE feature
3. **Builtin commenting** — Treesitter-aware commenting replaced vim-commentary for many users
4. **`vim.system()`** — Native async process execution, replacing `vim.fn.system()` and jobstart patterns
5. **`vim.snippet`** — Built-in snippet expansion and navigation
6. **Treesitter query editor** — `:EditQuery` for interactive query development
7. **Terminal UI improvements** — OSC 52 clipboard, OSC 8 hyperlinks, `'termsync'` synchronized output
8. **Auto truecolor detection** — `'termguicolors'` enabled by default when supported
9. **Default LSP/diagnostic mappings** — Made Neovim more usable out-of-the-box
