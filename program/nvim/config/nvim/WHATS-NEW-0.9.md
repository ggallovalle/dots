# What's New in Neovim 0.9

> Released April 7, 2023

---

## LSP

### New Features

- **Semantic token highlighting** — Enabled by default when client supports it; opt-out by deleting `semanticTokensProvider` from `server_capabilities` in `LspAttach` callback
  [`:help lsp-semantic-highlight`](https://neovim.io/doc/user/lsp/#lsp-semantic-highlight)
- **`willSave` / `willSaveWaitUntil`** — Server can modify document before save (e.g., remove unused imports, format)
  [`:help lsp-client-capabilities`](https://neovim.io/doc/user/lsp/#lsp-client-capabilities)
- **`workspace/didChangeWatchedFiles`** — Preliminary support to notify servers of file changes; disabled by default; enable via `workspace.didChangeWatchedFiles.dynamicRegistration=true`
  [`:help lsp-client-capabilities`](https://neovim.io/doc/user/lsp/#lsp-client-capabilities)
- **`vim.lsp.codelens.clear()`** — Clear code lenses
  [`:help vim.lsp.codelens.clear()`](https://neovim.io/doc/user/lsp/#vim.lsp.codelens.clear())
- **`vim.diagnostic`** — Supports LSP DiagnosticsTag
  [`:help lsp-diagnostic`](https://neovim.io/doc/user/lsp/#lsp-diagnostic)

---

## Diagnostics

- **`vim.diagnostic.is_disabled()`** — Check if diagnostics are disabled in a buffer or namespace
  [`:help vim.diagnostic.is_disabled()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.is_disabled())
- **`vim.diagnostic.open_float()`** — Accepts `suffix` option (default: renders LSP error codes)
  [`:help vim.diagnostic.open_float()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.open_float())
- **`vim.diagnostic.config()`** — `virtual_text` configuration now has `suffix` option (does nothing by default)
  [`:help vim.diagnostic.config()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.config())

---

## Treesitter

### New Features

- **`:InspectTree`** / **`vim.treesitter.inspect_tree()`** — Opens split window showing text representation of nodes in language tree
  [`:help :InspectTree`](https://neovim.io/doc/user/treesitter#:InspectTree)
- **`vim.treesitter.foldexpr()`** — Use Treesitter for folding via `'foldexpr'`
  [`:help vim.treesitter.foldexpr()`](https://neovim.io/doc/user/treesitter#vim.treesitter.foldexpr())
- **Help file syntax highlighting** — Treesitter syntax highlighting for `help` files with highlighted code examples; enable via `ftplugin/help.lua` with `vim.treesitter.start()`
  [`:help ft-help`](https://neovim.io/doc/user/ft_help#ft-help)
- **Directives** — Treesitter captures can be transformed by directives for dynamic language injections
  [`:help treesitter-directives`](https://neovim.io/doc/user/treesitter#treesitter-directives)
- **`vim.treesitter.get_node_text()`** — Accepts `metadata` option for custom directives via `vim.treesitter.query.add_directive()`
  [`:help vim.treesitter.get_node_text()`](https://neovim.io/doc/user/treesitter#vim.treesitter.get_node_text())
- **`vim.treesitter.language.add()`** — Replaces `vim.treesitter.language.require_language`
  [`:help vim.treesitter.language.add()`](https://neovim.io/doc/user/treesitter#vim.treesitter.language.add())
- **Injection queries** — New format per tree-sitter spec; previous format support will be removed
  [`:help treesitter-language-injection`](https://neovim.io/doc/user/treesitter#treesitter-language-injection)
- **TSNode API expanded:**
  - `TSNode:tree()` — Get the tree containing the node
    [`:help TSNode:tree()`](https://neovim.io/doc/user/treesitter#TSNode:tree())
  - `TSNode:has_changes()` — Check if node has changes
    [`:help TSNode:has_changes()`](https://neovim.io/doc/user/treesitter#TSNode:has_changes())
  - `TSNode:extra()` — Get extra nodes
    [`:help TSNode:extra()`](https://neovim.io/doc/user/treesitter#TSNode:extra())
  - `TSNode:equal()` — Compare nodes
    [`:help TSNode:equal()`](https://neovim.io/doc/user/treesitter#TSNode:equal())
  - `TSNode:range()` — Takes optional `include_bytes` argument
    [`:help TSNode:range()`](https://neovim.io/doc/user/treesitter#TSNode:range())

### Treesitter Breaking Changes

- **`help` parser renamed** — Renamed to `vimdoc`; language-specific highlight groups change from `@foo.help` to `@foo.vimdoc`
  [`:help treesitter-highlight-groups`](https://neovim.io/doc/user/treesitter#treesitter-highlight-groups)
- **`vim.treesitter.get_node_text()`** — Returns `string` (not `string|string[]|nil`); `concat` option removed; invalid ranges cause error
  [`:help vim.treesitter.get_node_text()`](https://neovim.io/doc/user/treesitter#vim.treesitter.get_node_text())
- **`LanguageTree:parse()`** — No longer returns changed regions; use `on_changedtree` callbacks
  [`:help LanguageTree:parse()`](https://neovim.io/doc/user/treesitter#LanguageTree:parse())

---

## Editor

### New Features

- **`'statuscolumn'`** — Customize gutter area (fold, sign, number columns) using `'statusline'` syntax; supports mouse click callbacks, custom margins, separators
  [`:help 'statuscolumn'`](https://neovim.io/doc/user/options#'statuscolumn')
- **EditorConfig** — Builtin support, enabled by default; disable via `vim.g.editorconfig = false`
  [`:help editorconfig`](https://neovim.io/doc/user/editorconfig#editorconfig)
- **`$NVIM_APPNAME`** — Environment variable for configuring directories for config/state files; enables multiple Neovim configurations side by side
  [`:help $NVIM_APPNAME`](https://neovim.io/doc/user/starting#$NVIM_APPNAME)
- **`nvim -l`** — Run Lua scripts from shell; works with stdin
  [`:help -l`](https://neovim.io/doc/user/starting#-l)
- **`vim.secure.trust()`** / **`:trust`** — Manage files in trust database; `vim.secure.read()` prompts user to trust file; used by `'exrc'`
  [`:help vim.secure.trust()`](https://neovim.io/doc/user/lua#vim.secure.trust())
- **`'exrc'`** — Now supports `.nvim.lua` file; no longer marked deprecated
  [`:help 'exrc'`](https://neovim.io/doc/user/options#'exrc')
- **`'showcmdloc'`** — Display `'showcmd'` information in status line or tab line; `%S` statusline item; useful with `'cmdheight'=0`
  [`:help 'showcmdloc'`](https://neovim.io/doc/user/options#'showcmdloc')
- **`'splitkeep'`** — Control scroll behavior of horizontal splits
  [`:help 'splitkeep'`](https://neovim.io/doc/user/options#'splitkeep')
- **`'diffopt'` linematch** — Second-stage diff on individual hunks for more accurate diffs; also available to `vim.diff()`
  [`:help 'diffopt'`](https://neovim.io/doc/user/options#'diffopt`)
- **`--remote-ui`** — Connect to remote instance and display in TUI locally; run headless nvim in background, display UI on demand
  [`:help --remote-ui`](https://neovim.io/doc/user/starting#--remote-ui)
- **`vim.lua_omnifunc()`** — Omnifunc implementation for Lua
  [`:help vim.lua_omnifunc()`](https://neovim.io/doc/user/lua#vim.lua_omnifunc())
- **tmux clipboard** — Default clipboard provider copies to system clipboard in tmux 3.2+
  [`:help provider-clipboard`](https://neovim.io/doc/user/provider#provider-clipboard)
- **`:Inspect`** / **`vim.inspect_pos()`** / **`vim.show_pos()`** — Get/show items at buffer position (Treesitter captures, LSP semantic tokens, syntax groups, extmarks)
  [`:help vim.inspect_pos()`](https://neovim.io/doc/user/lua#vim.inspect_pos())
- **`:= {expr}`** — Evaluate Lua expression; shorter form of `:lua ={expr}`
  [`:help :=`](https://neovim.io/doc/user/lua#:=)

### Editor Breaking Changes

- **Cscope removed** — All commands (`:cscope`, `:lcscope`, `:scscope`, `:cstag`), options, and `cscope_connection()` function removed; ctags support remains
  [`:help cscope`](https://neovim.io/doc/user/cscope#cscope)
- **`:hardcopy` removed** — Command and all print options removed
  [`:help hardcopy`](https://neovim.io/doc/user/various#hardcopy)
- **`'paste'` deprecated** — `'pastetoggle'` removed; paste works automatically in GUI and TUI
  [`:help paste`](https://neovim.io/doc/user/options#paste)
- **`'commentstring'` default** — Now empty instead of `"/*%s*/"`
  [`:help 'commentstring'`](https://neovim.io/doc/user/options#'commentstring')

### Editor Changed Behavior

- **TUI separate process** — TUI runs in separate process (previously separate thread); TUI always available (no longer build-time feature)
  [`:help TUI`](https://neovim.io/doc/user/ui#TUI)
- **`msgsep` always enabled** — Even if `'display'` doesn't contain "msgsep" flag; no longer possible to scroll whole screen for long messages
  [`:help msgsep`](https://neovim.io/doc/user/ui#msgsep)
- **`has('gui_running')`** — Now supported to check if GUI (not TUI) is attached
  [`:help has()`](https://neovim.io/doc/user/builtin#has())
- **Unsaved changes preserved** — When `channel-stdio` is closed (previously discarded)
  [`:help channel-stdio`](https://neovim.io/doc/user/channel#channel-stdio)

---

## Lua APIs

### New APIs

| API | Description | Help |
|---|---|---|
| `vim.loader.enable()` | Experimental byte-compilation and caching of Lua files for faster startup | [`:help lua-loader`](https://neovim.io/doc/user/lua#lua-loader) |
| `vim.version` | Parse/compare semver version strings | [`:help lua-version`](https://neovim.io/doc/user/lua#lua-version) |
| `vim.filetype.get_option()` | Get default option value for specific filetype (with caching) | [`:help vim.filetype.get_option()`](https://neovim.io/doc/user/lua#vim.filetype.get_option()) |
| `vim.pretty_print` | Pretty print (renamed to `vim.print`) | [`:help vim.print`](https://neovim.io/doc/user/lua#vim.print) |
| `nvim_get_hl()` | Get highlight group definitions compatible with `nvim_set_hl()` | [`:help nvim_get_hl()`](https://neovim.io/doc/user/api#nvim_get_hl()) |
| `require'bit'` | Always available | [`:help lua-bit`](https://neovim.io/doc/user/lua#lua-bit) |
| `vim.health` | Replaces `require'health'` | [`:help vim.health`](https://neovim.io/doc/user/lua#vim.health) |

### Lua Changed Behavior

- **`nvim_open_win()`** — Accepts relative `mouse` option to open floating window relative to mouse position
  [`:help nvim_open_win()`](https://neovim.io/doc/user/api#nvim_open_win())
- **`nvim_eval_statusline()`** — Supports evaluating `'statuscolumn'` via `use_statuscol_lnum` opts field
  [`:help nvim_eval_statusline()`](https://neovim.io/doc/user/api#nvim_eval_statusline())
- **`nvim_buf_get_extmarks()`** — Accepts `-1` `ns_id` for all namespaces; adds namespace id to details array; marks can be filtered by type
  [`:help nvim_buf_get_extmarks()`](https://neovim.io/doc/user/api#nvim_buf_get_extmarks())
- **`vim.fs.dir()`** — Has `opts` argument with `depth` field for recursive directory tree search
  [`:help vim.fs.dir()`](https://neovim.io/doc/user/lua#vim.fs.dir())
- **`vim.gsplit()`** — Supports all features of `vim.split()`
  [`:help vim.gsplit()`](https://neovim.io/doc/user/lua#vim.gsplit())
- **`nvim_select_popupmenu_item()`** — Supports cmdline-completion popup menu
  [`:help nvim_select_popupmenu_item()`](https://neovim.io/doc/user/api#nvim_select_popupmenu_item())
- **`nvim_list_uis()`** — Reports all `ui-option` fields
  [`:help nvim_list_uis()`](https://neovim.io/doc/user/api#nvim_list_uis())
- **`nvim_get_option_value()`** — Has `filetype` option to return default option for specific filetype
  [`:help nvim_get_option_value()`](https://neovim.io/doc/user/api#nvim_get_option_value())
- **`:highlight`** — Supports additional attribute "altfont"
  [`:help :highlight`](https://neovim.io/doc/user/syntax#:highlight)
- **`:Man`** — Supports manpage names containing spaces
  [`:help :Man`](https://neovim.io/doc/user/man#:Man)
- **API calls** — Show more information about where exception happened
- **`win_viewport` UI event** — Contains information about virtual lines for consistent smooth scrolling
  [`:help ui-event`](https://neovim.io/doc/user/ui#ui-event)

### Lua Breaking Changes

- **`filetype.vim` removed** — Replaced by Lua filetype API
  [`:help lua-filetype`](https://neovim.io/doc/user/lua#lua-filetype)
- **`'hkmap'`, `'hkmapp'`, `'aleph'` removed** — Use `'keymap'` option instead
  [`:help 'keymap'`](https://neovim.io/doc/user/options#'keymap')
- **`vim.highlight.create()`** / **`vim.highlight.link()`** — Removed; use `nvim_set_hl()`
  [`:help nvim_set_hl()`](https://neovim.io/doc/user/api#nvim_set_hl())

---

## UI

- **`'statuscolumn'`** — Customizable gutter area with `'statusline'` syntax
  [`:help 'statuscolumn'`](https://neovim.io/doc/user/options#'statuscolumn')
- **`'showcmdloc'`** — Display showcmd in statusline/tabline
  [`:help 'showcmdloc'`](https://neovim.io/doc/user/options#'showcmdloc')
- **`--remote-ui`** — Connect to headless Neovim and display UI locally
  [`:help --remote-ui`](https://neovim.io/doc/user/starting#--remote-ui)
- **`:Inspect`** — Inspect highlights, captures, tokens, extmarks at cursor
  [`:help :Inspect`](https://neovim.io/doc/user/lua#:Inspect)
- **`:InspectTree`** — Visual Treesitter node inspection in split window
  [`:help :InspectTree`](https://neovim.io/doc/user/treesitter#:InspectTree)

---

## Options

| Option | Description | Help |
|---|---|---|
| `'statuscolumn'` | Customize gutter area with statusline syntax | [`:help 'statuscolumn'`](https://neovim.io/doc/user/options#'statuscolumn') |
| `'showcmdloc'` | Display showcmd in statusline/tabline | [`:help 'showcmdloc'`](https://neovim.io/doc/user/options#'showcmdloc') |
| `'splitkeep'` | Control scroll behavior of horizontal splits | [`:help 'splitkeep'`](https://neovim.io/doc/user/options#'splitkeep') |
| `'diffopt'` | New `linematch` option for second-stage diff on hunks | [`:help 'diffopt'`](https://neovim.io/doc/user/options#'diffopt') |
| `'commentstring'` | Default now empty (was `"/*%s*/"`) | [`:help 'commentstring'`](https://neovim.io/doc/user/options#'commentstring') |
| `'paste'` | Deprecated; `'pastetoggle'` removed | [`:help paste`](https://neovim.io/doc/user/options#paste) |

---

## Performance

| Improvement | Details |
|---|---|
| **`vim.loader`** — Experimental byte-compilation and caching of Lua files |
| **Linematch diff** — More accurate diffs with second-stage hunk comparison |

---

## Build & Dependencies

- **libiconv and intl** — Now required build dependencies
- **`LUA_GEN_PRG`** — Build parameter introduced for reproducibility workaround
- **`.deb` package** — Removed; use AppImage or tarball instead
- **TUI** — Always available (no longer build-time `+tui/-tui` feature)

---

## Breaking Changes

| Change | Details | Help |
|---|---|---|
| Cscope removed | All commands, options, functions removed | [`:help cscope`](https://neovim.io/doc/user/cscope#cscope) |
| `:hardcopy` removed | Command and print options removed | [`:help hardcopy`](https://neovim.io/doc/user/various#hardcopy) |
| `'paste'` deprecated | `'pastetoggle'` removed; paste automatic | [`:help paste`](https://neovim.io/doc/user/options#paste) |
| `vim.treesitter.get_node_text()` | Returns `string`; `concat` removed; invalid ranges error | [`:help vim.treesitter.get_node_text()`](https://neovim.io/doc/user/treesitter#vim.treesitter.get_node_text()) |
| `help` parser renamed | Now `vimdoc`; highlight groups change `@foo.help` → `@foo.vimdoc` | [`:help treesitter-highlight-groups`](https://neovim.io/doc/user/treesitter#treesitter-highlight-groups) |
| `'commentstring'` default | Now empty | [`:help 'commentstring'`](https://neovim.io/doc/user/options#'commentstring') |
| libiconv/intl required | Build dependencies | — |
| `filetype.vim` removed | Replaced by Lua filetype API | [`:help lua-filetype`](https://neovim.io/doc/user/lua#lua-filetype) |
| `'hkmap'`/`'hkmapp'`/`'aleph'` | Removed; use `'keymap'` | [`:help 'keymap'`](https://neovim.io/doc/user/options#'keymap') |
| `LanguageTree:parse()` | No longer returns changed regions | [`:help LanguageTree:parse()`](https://neovim.io/doc/user/treesitter#LanguageTree:parse()) |
| `vim.highlight.create()`/`link()` | Removed; use `nvim_set_hl()` | [`:help nvim_set_hl()`](https://neovim.io/doc/user/api#nvim_set_hl()) |
| `require'health'` | Removed; use `vim.health` | [`:help vim.health`](https://neovim.io/doc/user/lua#vim.health) |

---

## Removed Features

- **Cscope support** — All commands, options, functions
- **`:hardcopy`** — Command and print options
- **`filetype.vim`** — Replaced by Lua filetype API
- **`'hkmap'`, `'hkmapp'`, `'aleph'`** — Use `'keymap'`
- **`vim.highlight.create()`**, **`vim.highlight.link()`** — Use `nvim_set_hl()`
- **`require'health'`** — Use `vim.health`

---

## Deprecations

| Deprecated | Replacement | Help |
|---|---|---|
| `vim.treesitter.language.require_language()` | `vim.treesitter.language.add()` | [`:help vim.treesitter.language.add()`](https://neovim.io/doc/user/treesitter#vim.treesitter.language.add()) |
| `vim.treesitter.get_node_at_pos()` | `vim.treesitter.get_node()` | [`:help vim.treesitter.get_node()`](https://neovim.io/doc/user/treesitter#vim.treesitter.get_node()) |
| `vim.treesitter.get_node_at_cursor()` | `vim.treesitter.get_node()` | [`:help vim.treesitter.get_node()`](https://neovim.io/doc/user/treesitter#vim.treesitter.get_node()) |
| `nvim_get_hl_by_name()` | `nvim_get_hl()` | [`:help nvim_get_hl()`](https://neovim.io/doc/user/api#nvim_get_hl()) |
| `nvim_get_hl_by_id()` | `nvim_get_hl()` | [`:help nvim_get_hl()`](https://neovim.io/doc/user/api#nvim_get_hl()) |
| `nvim_exec()` | `nvim_exec2()` | [`:help nvim_exec2()`](https://neovim.io/doc/user/api#nvim_exec2()) |
| `vim.pretty_print` | `vim.print` | [`:help vim.print`](https://neovim.io/doc/user/lua#vim.print) |
| Top-level Treesitter functions | Moved to `vim.treesitter.query.*`, `vim.treesitter.language.*`, `vim.treesitter.get_range()`, `vim.treesitter.get_node_text()` | [`:help treesitter`](https://neovim.io/doc/user/treesitter#treesitter) |

### Treesitter Functions Moved

| Old | New |
|---|---|
| `vim.treesitter.inspect_language()` | `vim.treesitter.language.inspect()` |
| `vim.treesitter.get_query_files()` | `vim.treesitter.query.get_files()` |
| `vim.treesitter.set_query()` | `vim.treesitter.query.set()` |
| `vim.treesitter.query.set_query()` | `vim.treesitter.query.set()` |
| `vim.treesitter.get_query()` | `vim.treesitter.query.get()` |
| `vim.treesitter.query.get_query()` | `vim.treesitter.query.get()` |
| `vim.treesitter.parse_query()` | `vim.treesitter.query.parse()` |
| `vim.treesitter.query.parse_query()` | `vim.treesitter.query.parse()` |
| `vim.treesitter.add_predicate()` | `vim.treesitter.query.add_predicate()` |
| `vim.treesitter.add_directive()` | `vim.treesitter.query.add_directive()` |
| `vim.treesitter.list_predicates()` | `vim.treesitter.query.list_predicates()` |
| `vim.treesitter.list_directives()` | `vim.treesitter.query.list_directives()` |
| `vim.treesitter.query.get_range()` | `vim.treesitter.get_range()` |
| `vim.treesitter.query.get_node_text()` | `vim.treesitter.get_node_text()` |

---

## Community Resources

### YouTube Videos

| Video | Channel | Date | Description |
|---|---|---|---|
| [Neovim 0.9 New Features](https://www.youtube.com/watch?v=3TRouzuWOuQ) | — | Apr 2023 | Primary video dedicated to 0.9.0 release highlights |
| [Setup Neovim 0.9 For Rust, TypeScript And Lua](https://www.youtube.com/watch?v=eoMzRjPehro) | bitter tea sweet orange | — | Practical setup for multi-language development with 0.9 |
| [Effortless Neovim 0.9 & AstroNvim Setup](https://www.youtube.com/watch?v=MmVUR4B35MI) | — | — | Setup with AstroNvim distribution using ChatGPT-4 guidance |

### Blog Posts & Articles

| Post | Author | Date | Description |
|---|---|---|---|
| [Neovim: From simple texteditor to IDE like](https://huyhoang8398.github.io/blog/posts/) | Kn | Jul 15, 2023 | Practical guide for IDE-like experience using 0.9 features |
| [Modern Neovim -- Configuration Hacks](https://alpha2phi.medium.com/modern-neovim-configuration-hacks) | alpha2phi | Apr 28, 2023 | Configuration hacks leveraging new 0.9 features |
| [Modern Neovim -- Configuration Recipes](https://alpha2phi.medium.com/modern-neovim-configuration-recipes) | alpha2phi | Mar 31, 2023 | Configuration recipes for PDE setup around 0.9 release |
| [How to install latest version (0.9+) of Neovim on Debian](https://frvfrvr.github.io/2023/06/15/myvimsetup2/) | frvfrvr | Jun 15, 2023 | Installation changes addressing .deb package removal |

### Official Resources

| Resource | URL | Description |
|---|---|---|
| [Official Release Notes](https://neovim.io/doc/user/news-0.9/) | neovim.io | Complete changelog (`:h news-0.9`) |
| [GitHub Release](https://github.com/neovim/neovim/releases/tag/v0.9.0) | github.com | Downloads, 536+ individual changes documented |

### Community Discussions

| Discussion | Platform | Date | Description |
|---|---|---|---|
| [Neovim 0.9](https://news.ycombinator.com/item?id=35467684) | Hacker News | Apr 7, 2023 | Discussion of standout features: trust database, semantic tokens, statuscolumn |
| [NVIM 0.9.0 was released](https://www.reddit.com/r/neovim/comments/12einob/nvim_090_was_released/) | r/neovim | Apr 7, 2023 | Reddit announcement; users celebrating dropping <=0.6 support |
| [Neovim 0.9.0 - New Features](https://www.reddit.com/r/neovim/comments/12hplpu/neovim_090_new_features/) | r/neovim | Apr 2023 | Reddit post highlighting new features |

---

## Key Significance

Neovim 0.9 was the **modernization release** that brought:

1. **`'statuscolumn'`** — Fully customizable gutter area; enabled statuscolumn plugins like gitsigns.nvim to render signs inline
2. **Semantic token highlighting** — LSP-driven syntax highlighting for richer, more accurate code coloring
3. **`vim.loader`** — Experimental Lua byte-compilation and caching; significantly improved startup times
4. **`$NVIM_APPNAME`** — Multiple Neovim configurations side by side; enabled testing different setups
5. **`vim.secure.trust()`** / **`:trust`** — Secure project-local configuration with `.nvim.lua` files
6. **Builtin EditorConfig** — No longer needed external plugin
7. **`nvim -l`** — Run Lua scripts directly from command line; made Neovim a Lua runtime
8. **`:InspectTree`** — Visual Treesitter inspection; essential for query development
9. **Linematch diff** — Dramatically improved diff accuracy
10. **`--remote-ui`** — Headless Neovim with on-demand UI display
11. **Paste mode automatic** — No more `:set paste` / `:set nopaste` toggling
12. **Tmux clipboard integration** — System clipboard works in tmux without extra configuration
