# What's New in Neovim 0.12

> You are on **NVIM v0.12.2** (LuaJIT 2.1.1774638290, Release build)
> Released March 29, 2026

---

## LSP

### Native LSP Configuration API

`vim.lsp.config()` and `vim.lsp.enable()` are now the primary API. The old `require("lspconfig")[server].setup()` pattern is deprecated.

- **`vim.lsp.config(name, cfg)`** — Define/extend a server configuration (no side effects)
  [`:help vim.lsp.config`](https://neovim.io/doc/user/lsp/#vim.lsp.config())
- **`vim.lsp.enable(name)`** — Start/stop clients as necessary, detach non-applicable clients
  [`:help vim.lsp.enable()`](https://neovim.io/doc/user/lsp/#vim.lsp.enable())
- **`vim.lsp.is_enabled(name)`** — Check if config is enabled without resolving
  [`:help vim.lsp.is_enabled()`](https://neovim.io/doc/user/lsp/#vim.lsp.is_enabled())
- **`vim.lsp.get_configs(filter?)`** — Get all configs matching optional filter
  [`:help vim.lsp.get_configs()`](https://neovim.io/doc/user/lsp/#vim.lsp.get_configs())
- **`:lsp`** — Interactive LSP client management
  [`:help :lsp`](https://neovim.io/doc/user/lsp/#:lsp)
- **`:checkhealth vim.lsp`** — Check which buffers active LSP features are attached to
  [`:help :checkhealth`](https://neovim.io/doc/user/lsp/#:checkhealth)

### New LSP Capabilities

| Capability | Description | Help |
|---|---|---|
| `textDocument/inlineCompletion` | Inline completion (Ghost text) | [`:help lsp-inline_completion`](https://neovim.io/doc/user/lsp/#lsp-inline_completion) |
| `textDocument/selectionRange` | Incremental selection (`v_an` outwards, `v_in` inwards) | [`:help v_an`](https://neovim.io/doc/user/lsp/#v_an) |
| `textDocument/documentColor` | Document color presentation | [`:help lsp-document_color`](https://neovim.io/doc/user/lsp/#lsp-document_color) |
| `textDocument/linkedEditingRange` | Linked editing range | [`:help lsp-linked_editing_range`](https://neovim.io/doc/user/lsp/#lsp-linked_editing_range) |
| `textDocument/onTypeFormatting` | Format on type | [`:help lsp-on_type_formatting`](https://neovim.io/doc/user/lsp/#lsp-on_type_formatting) |
| `textDocument/diagnostic` | Pull diagnostics (with related documents) | [`:help lsp-diagnostic`](https://neovim.io/doc/user/lsp/#lsp-diagnostic) |
| `textDocument/documentLink` | Document links (`gx` opens link at cursor) | [`:help gx`](https://neovim.io/doc/user/lsp/#gx) |
| `textDocument/codeLens` | Reimplemented code lenses (display as virtual lines) | [`:help lsp-codelens`](https://neovim.io/doc/user/lsp/#lsp-codelens) |
| `textDocument/semanticTokens/range` | Viewport-only semantic tokens (performance) | [`:help lsp-semantic_tokens`](https://neovim.io/doc/user/lsp/#lsp-semantic_tokens) |
| `workspace/codeLens/refresh` | Code lens refresh | [`:help lsp-workspace`](https://neovim.io/doc/user/lsp/#lsp-workspace) |
| `workspace/diagnostic` | Workspace-wide diagnostics | [`:help vim.lsp.buf.workspace_diagnostics()`](https://neovim.io/doc/user/lsp/#vim.lsp.buf.workspace_diagnostics()) |

### LSP Improvements

- **`vim.lsp.completion.enable()`** gained `cmp` option for custom ordering
  [`:help vim.lsp.completion.enable()`](https://neovim.io/doc/user/lsp/#vim.lsp.completion.enable())
- **`vim.lsp.buf.rename()`** highlights symbol being renamed with `hl-LspReferenceTarget`
  [`:help vim.lsp.buf.rename()`](https://neovim.io/doc/user/lsp/#vim.lsp.buf.rename())
- **`vim.lsp.buf.signature_help()`** supports `noActiveParameterSupport`
  [`:help vim.lsp.buf.signature_help()`](https://neovim.io/doc/user/lsp/#vim.lsp.buf.signature_help())
- **`vim.lsp.buf.code_action()`** filter receives client ID as argument
  [`:help vim.lsp.buf.code_action()`](https://neovim.io/doc/user/lsp/#vim.lsp.buf.code_action())
- **`vim.lsp.ClientConfig`** gained `workspace_required` and `exit_timeout` (top-level, graduated from experimental `flags.exit_timeout`)
  [`:help vim.lsp.ClientConfig`](https://neovim.io/doc/user/lsp/#vim.lsp.ClientConfig)
- **`vim.diagnostic.open_float()`** shows `DiagnosticRelatedInformation`; `gf` jumps to location
  [`:help vim.diagnostic.open_float()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.open_float())
- **`gf`** in diagnostic float jumps to related information location
- **Annotated text edits** supported
- **Disabled field** on code actions supported
- **Multiline semantic tokens** supported
- **Dynamic registration** for `textDocument/diagnostic`
- **`cmd` function form** receives resolved config as second arg: `cmd(dispatchers, config)`
  [`:help vim.lsp.Config`](https://neovim.io/doc/user/lsp/#vim.lsp.Config)

### Default LSP Mappings

- **`grt`** — `vim.lsp.buf.type_definition()`
  [`:help grt`](https://neovim.io/doc/user/lsp/#grt)
- **`grx`** — `vim.lsp.codelens.run()`
  [`:help grx`](https://neovim.io/doc/user/lsp/#grx)

---

## vim.pack (Built-in Plugin Manager)

Experimental but stable for daily use. Replaces need for lazy.nvim, packer, etc.

- **`vim.pack.add(specs, opts)`** — Add plugins from git URLs
  [`:help vim.pack`](https://neovim.io/doc/user/pack/#vim.pack)
- **`:packadd`** cache updated in-place (big startuptime improvement)
  [`:help :packadd`](https://neovim.io/doc/user/repeat/#%3Apackadd)
- **`PackChanged`** autocmd for post-install/update hooks
  [`:help PackChanged`](https://neovim.io/doc/user/pack/#PackChanged)
- **Lockfile** (`nvim-pack-lock.json`) for reproducible installs
  [`:help vim.pack-lockfile`](https://neovim.io/doc/user/vimpack/#vim.pack-lockfile)

---

## UI

### Experimental ui2

Redesigned core messages and commandline UI. Replaces legacy message grid.

- Avoids "Press ENTER" interruptions
- Avoids delays from `W10` and other warnings
- Highlights cmdline as you type
- Provides pager as buffer + window
- Enable: `require('vim._core.ui2').enable()`
  [`:help ui2`](https://neovim.io/doc/user/lua/#ui2)

### New Commands

- **`:restart`** — Restart Neovim and reattach current UI
  [`:help :restart`](https://neovim.io/doc/user/starting#:restart)
- **`:connect`** — Dynamically connect UI to server at given address
  [`:help :connect`](https://neovim.io/doc/user/starting#:connect)

### Statusline & Messages

- Default `'statusline'` shows:
  - [`vim.diagnostic.status()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.status())
  - [`vim.ui.progress_status()`](https://neovim.io/doc/user/ui/#vim.ui.progress_status())
  - `:terminal` exit code
- **`'busy'`** option shows ◐ symbol in statusline
  [`:help 'busy'`](https://neovim.io/doc/user/options#'busy')
- **`'pumborder'`** adds border to popup menu
  [`:help 'pumborder'`](https://neovim.io/doc/user/options#'pumborder')
- **`'winborder'`** supports "bold" style and custom border styles
  [`:help 'winborder'`](https://neovim.io/doc/user/options#'winborder')
- **`'statusline'`** allows stacking highlight groups
  [`:help 'statusline'`](https://neovim.io/doc/user/options#'statusline')
- Error messages more concise: "Error in:" instead of "Error detected while processing:"
  [`:help ui-messages`](https://neovim.io/doc/user/ui/#ui-messages)
- Native progress bars via OSC 9;4 sequence for `Progress` events
  [`:help Progress`](https://neovim.io/doc/user/ui/#Progress)

---

## Editor

### New Commands

- **`:uniq`** — Deduplicate text in current buffer
  [`:help :uniq`](https://neovim.io/doc/user/editing#:uniq)
- **`:iput`** — Like `:put` but adjusts indent
  [`:help :iput`](https://neovim.io/doc/user/editing#:iput)
- **`:retab -indentonly`** — Only change leading whitespace
  [`:help :retab`](https://neovim.io/doc/user/change#:retab)
- **`:wall ++p`** — Auto-create missing parent directories
  [`:help :wall`](https://neovim.io/doc/user/editing#:wall)
- **`:help!`** — DWIM behavior, guesses help tag at cursor
  [`:help :help!`](https://neovim.io/doc/user/help#:help!)
- **`:DiffTool`** — Compare directories and files
  [`:help :DiffTool`](https://neovim.io/doc/user/diff#:DiffTool)
- **`:Undotree`** — Visually navigate undo-tree
  [`:help :Undotree`](https://neovim.io/doc/user/undo#:Undotree)
- **`:EditQuery`** — Treesitter query editor with tab-completion
  [`:help :EditQuery`](https://neovim.io/doc/user/treesitter#:EditQuery)

### Other Editor Changes

- **`gx`** in help buffers opens online documentation for tag at cursor
  [`:help gx`](https://neovim.io/doc/user/help#gx)
- **`:source`** with range in non-Lua files detects Lua codeblocks via treesitter
  [`:help :source`](https://neovim.io/doc/user/lua#:source)
- **`i_CTRL-R`** inserts registers literally (10x speedup, different behavior)
  [`:help i_CTRL-R`](https://neovim.io/doc/user/index#i_CTRL-R)
- **`'0'`** in `'shada'` prevents storing jumplist
  [`:help 'shada'`](https://neovim.io/doc/user/starting#'shada')
- **Prompt buffers** support multiline input/paste, undo/redo, `o/O` normal commands
  [`:help prompt-buffer`](https://neovim.io/doc/user/terminal#prompt-buffer)
- **`'wildchar'`** enables completion in search contexts (`/`, `?`, `:g`, `:v`, `:vimgrep`)
  [`:help 'wildchar'`](https://neovim.io/doc/user/options#'wildchar')
- **`'exrc'`** security: must `:trust` instead of "(a)llow"
  [`:help 'exrc'`](https://neovim.io/doc/user/options#'exrc)
- **Omnicompletion** available in help buffers
  [`:help ft-help-omni`](https://neovim.io/doc/user/ft_help#ft-help-omni)

---

## Lua APIs

### New APIs

| API | Description | Help |
|---|---|---|
| `vim.net.request()` | Built-in HTTP client (no more shelling out to curl) | [`:help vim.net.request()`](https://neovim.io/doc/user/lua#vim.net.request()) |
| `vim.fs.ext()` | Returns last extension of a file | [`:help vim.fs.ext()`](https://neovim.io/doc/user/lua#vim.fs.ext()) |
| `vim.fs.root()` | Can define "equal priority" via nested lists | [`:help vim.fs.root()`](https://neovim.io/doc/user/lua#vim.fs.root()) |
| `vim.list.unique()` | Deduplicate lists | [`:help vim.list.unique()`](https://neovim.io/doc/user/lua#vim.list.unique()) |
| `vim.list.bisect()` | Binary search | [`:help vim.list.bisect()`](https://neovim.io/doc/user/lua#vim.list.bisect()) |
| `vim.version.range()` | Human-readable string via `tostring()` | [`:help vim.version.range()`](https://neovim.io/doc/user/lua#vim.version.range()) |
| `vim.version.intersect()` | Compute intersection of two version ranges | [`:help vim.version.intersect()`](https://neovim.io/doc/user/lua#vim.version.intersect()) |
| `vim.text.diff()` | Renamed from `vim.diff` | [`:help vim.text.diff()`](https://neovim.io/doc/user/lua#vim.text.diff()) |
| `vim.pos` / `vim.range` | EXPERIMENTAL: Position/Range abstraction | [`:help vim.pos`](https://neovim.io/doc/user/lua#vim.pos) |
| `vim.hl.range()` | Multiple timed highlights | [`:help vim.hl.range()`](https://neovim.io/doc/user/lua#vim.hl.range()) |
| `vim.wait()` | Returns callback results | [`:help vim.wait()`](https://neovim.io/doc/user/lua#vim.wait()) |
| `vim.json.encode()` | `indent` for pretty-formatting, `sort_keys` option | [`:help vim.json.encode()`](https://neovim.io/doc/user/lua#vim.json.encode()) |
| `vim.json.decode()` | `skip_comments` option | [`:help vim.json.decode()`](https://neovim.io/doc/user/lua#vim.json.decode()) |
| `vim.tbl_extend()` | `behavior` argument can be a function | [`:help vim.tbl_extend()`](https://neovim.io/doc/user/lua#vim.tbl_extend()) |
| `Iter:take()` / `Iter:skip()` | Optionally accept predicates | [`:help Iter:take()`](https://neovim.io/doc/user/lua#Iter:take()) |
| `Iter:peek()` | Works for all iterator types | [`:help Iter:peek()`](https://neovim.io/doc/user/lua#Iter:peek()) |
| `Iter:unique()` | Deduplicate iterators | [`:help Iter:unique()`](https://neovim.io/doc/user/lua#Iter:unique()) |
| `nvim__exec_lua_fast()` | EXPERIMENTAL: Execute Lua while Nvim is blocking | [`:help nvim__exec_lua_fast()`](https://neovim.io/doc/user/api#nvim__exec_lua_fast()) |
| `nvim_open_tabpage()` | Open a new tabpage | [`:help nvim_open_tabpage()`](https://neovim.io/doc/user/api#nvim_open_tabpage()) |
| `nvim_win_set_config()` | Move floating windows to other tabpages | [`:help nvim_win_set_config()`](https://neovim.io/doc/user/api#nvim_win_set_config()) |
| `nvim_win_text_height()` | Limit lines checked, returns `end_row`/`end_vcol` | [`:help nvim_win_text_height()`](https://neovim.io/doc/user/api#nvim_win_text_height()) |
| `nvim_ui_send()` | Write arbitrary data to UI stdout | [`:help nvim_ui_send()`](https://neovim.io/doc/user/api#nvim_ui_send()) |
| `nvim_echo()` | Set ui-messages kind, create Progress messages | [`:help nvim_echo()`](https://neovim.io/doc/user/api#nvim_echo()) |
| `nvim_get_chan_info()` | Includes `exitcode` for :terminal buffers | [`:help nvim_get_chan_info()`](https://neovim.io/doc/user/api#nvim_get_chan_info()) |
| `nvim_set_hl()` | Update specified attributes only; SGR dim/blink/conceal/overline | [`:help nvim_set_hl()`](https://neovim.io/doc/user/api#nvim_set_hl()) |
| `vim.secure.trust()` | Accepts `path` for `allow` action | [`:help vim.secure.trust()`](https://neovim.io/doc/user/lua#vim.secure.trust()) |
| `vim.secure.read()` | Returns `true` for trusted directories | [`:help vim.secure.read()`](https://neovim.io/doc/user/lua#vim.secure.read()) |
| `vim.glob.to_lpeg()` | LPeg-based Peglob (~50% speedup) | [`:help vim.glob.to_lpeg()`](https://neovim.io/doc/user/lua#vim.glob.to_lpeg()) |

---

## Treesitter

- **`v_an`** / **`v_in`** / **`v_]n`** / **`v_[n`** — Incremental selection of treesitter nodes
  [`:help v_an`](https://neovim.io/doc/user/treesitter#v_an)
- **`:EditQuery`** gained tab-completion, works with injected languages
  [`:help :EditQuery`](https://neovim.io/doc/user/treesitter#:EditQuery)
- **`Query:iter_captures()`** supports specifying starting and ending columns
  [`:help Query:iter_captures()`](https://neovim.io/doc/user/treesitter#Query:iter_captures())
- **`LanguageTree:parse()`** accepts a list of ranges
  [`:help LanguageTree:parse()`](https://neovim.io/doc/user/treesitter#LanguageTree:parse())
- **Treesitter highlighting** enabled for Markdown files by default
- **`ft-query-plugin`** no longer enables `vim.treesitter.query.lint()` by default
  [`:help ft-query-plugin`](https://neovim.io/doc/user/treesitter#ft-query-plugin)
- **`treesitter-directive-offset!`** can be applied to quantified captures
  [`:help treesitter-directive-offset!`](https://neovim.io/doc/user/treesitter#treesitter-directive-offset!)

---

## Diagnostics

- **`vim.diagnostic.setloclist()`** / **`vim.diagnostic.setqflist()`** support `format` function
  [`:help vim.diagnostic.setloclist()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.setloclist())
- **`vim.diagnostic.get()`** accepts `enabled` filter
  [`:help vim.diagnostic.get()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.get())
- **`vim.diagnostic.status()`** returns status description of current buffer diagnostics
  [`:help vim.diagnostic.status()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.status())
- **`vim.diagnostic.fromqflist()`** accepts `opts.merge_lines` for multiline compiler messages
  [`:help vim.diagnostic.fromqflist()`](https://neovim.io/doc/user/diagnostic/#vim.diagnostic.fromqflist())
- **Breaking:** `vim.diagnostic.disable()` and `vim.diagnostic.is_disabled()` removed (deprecated in 0.10)
  [`:help deprecated-0.10`](https://neovim.io/doc/user/deprecated#deprecated-0.10)
- **Breaking:** Diagnostic signs can no longer be configured with `:sign-define` or `sign_define()`
  [`:help diagnostic-signs`](https://neovim.io/doc/user/diagnostic/#diagnostic-signs)

---

## Options

| Option | Description | Help |
|---|---|---|
| `'autocomplete'` | Enables insert-mode auto-completion | [`:help 'autocomplete'`](https://neovim.io/doc/user/options#'autocomplete') |
| `'autowriteall'` | Writes all buffers on SIGHUP/SIGQUIT/SIGTSTP | [`:help 'autowriteall'`](https://neovim.io/doc/user/options#'autowriteall') |
| `'chistory'` / `'lhistory'` | Size of quickfix stack | [`:help 'chistory'`](https://neovim.io/doc/user/options#'chistory') |
| `'complete'` | New flags: `F{func}`, `F`, `o`, `{flag}^<limit>` | [`:help 'complete'`](https://neovim.io/doc/user/options#'complete') |
| `'completeopt'` | New flag `nearest` (sort by distance to cursor) | [`:help 'completeopt'`](https://neovim.io/doc/user/options#'completeopt') |
| `'diffanchors'` | Addresses to anchor a diff | [`:help 'diffanchors'`](https://neovim.io/doc/user/options#'diffanchors') |
| `'diffopt'` | Default includes `indent-heuristic` and `inline:char` | [`:help 'diffopt'`](https://neovim.io/doc/user/options#'diffopt') |
| `'fillchars'` | New flag `foldinner` | [`:help 'fillchars'`](https://neovim.io/doc/user/options#'fillchars') |
| `'listchars'` | New flag `leadtab` | [`:help 'listchars'`](https://neovim.io/doc/user/options#'listchars') |
| `'maxsearchcount'` | Max value for `searchcount()`, defaults to 999 | [`:help 'maxsearchcount'`](https://neovim.io/doc/user/options#'maxsearchcount') |
| `'pummaxwidth'` | Max width for completion popup menu | [`:help 'pummaxwidth'`](https://neovim.io/doc/user/options#'pummaxwidth') |
| `'shelltemp'` | Defaults to `false` | [`:help 'shelltemp'`](https://neovim.io/doc/user/options#'shelltemp') |
| `'shada'` | Excludes `/tmp/` and `/private/` paths by default | [`:help 'shada'`](https://neovim.io/doc/user/options#'shada') |
| `'scrollback'` | Max value increased from 100000 to 1000000 | [`:help 'scrollback'`](https://neovim.io/doc/user/options#'scrollback') |

---

## Performance

- **`:packadd`** cache updated in-place — big startuptime improvement for `vim.pack.add()` patterns
- **`vim.glob.to_lpeg()`** — LPeg-based Peglob (~50% speedup for complex patterns)
- **`i_CTRL-R`** — 10x speedup for register insertion
- **LSP `textDocument/semanticTokens/range`** — Viewport-only token requests

---

## Terminal

- **CSI 3 J** — Clear terminal scrollback sequence supported
- **DEC private mode 2026** — Synchronized output (batch screen updates, avoid tearing)
- **Suspended PTY process** — Indicated by "[Process suspended]", resume by pressing key
- **Terminal exit** — "[Process exited]" shown as virtual text, exit code in statusline
- **`nvim_open_term()`** — Can be called with non-empty buffer (contents piped to PTY)
  [`:help nvim_open_term()`](https://neovim.io/doc/user/api#nvim_open_term())

---

## Breaking Changes

| Change | Details | Help |
|---|---|---|
| `vim.diff` renamed | Now `vim.text.diff` | [`:help vim.text.diff()`](https://neovim.io/doc/user/lua#vim.text.diff()) |
| `i_CTRL-R` behavior | Inserts registers literally, not as user input | [`:help i_CTRL-R`](https://neovim.io/doc/user/index#i_CTRL-R) |
| Diagnostic signs | No longer configurable via `:sign-define` | [`:help diagnostic-signs`](https://neovim.io/doc/user/diagnostic/#diagnostic-signs) |
| `vim.diagnostic.disable()` | Removed (deprecated in 0.10) | [`:help deprecated-0.10`](https://neovim.io/doc/user/deprecated#deprecated-0.10) |
| `vim.diagnostic.is_disabled()` | Removed (deprecated in 0.10) | [`:help deprecated-0.10`](https://neovim.io/doc/user/deprecated#deprecated-0.10) |
| `shelltemp` default | Now `false` | [`:help 'shelltemp'`](https://neovim.io/doc/user/options#'shelltemp') |
| `nvim_get_commands()` | Returns `complete` as Lua function if defined as such | [`:help nvim_get_commands()`](https://neovim.io/doc/user/api#nvim_get_commands()) |
| LSP JSON null | Represented as `vim.NIL` instead of `nil` | [`:help vim.NIL`](https://neovim.io/doc/user/lua#vim.NIL) |
| `ui-messages` events | No longer emits `msg_show.return_prompt`, `msg_history_clear` | [`:help ui-messages`](https://neovim.io/doc/user/ui/#ui-messages) |
| `shellmenu` plugin | Removed | — |
| `package-tohtml` | Now opt-in, use `:packadd nvim.tohtml` | [`:help package-tohtml`](https://neovim.io/doc/user/usr_05#package-tohtml) |
| `vim.treesitter.get_parser()` | Returns nil instead of throwing error on failure | [`:help vim.treesitter.get_parser()`](https://neovim.io/doc/user/treesitter#vim.treesitter.get_parser()) |

---

## Community Resources

### YouTube Videos

| Video | Channel | Date | Description |
|---|---|---|---|
| [Neovim 0.12: What's New?](https://www.youtube.com/watch?v=xSiQP23ZZhI) | DevOnDuty | Apr 5, 2026 | Comprehensive walkthrough of all new features, referencing `:help news-0.12` |
| [Neovim 0.12 Release with the Core Team](https://www.youtube.com/watch?v=EiBg91LTOYk) | linkarzu | Apr 2026 | Interview with Neovim core team about 0.12 release, project direction |
| [Neovim 0.12 - 5 Changes That Matter](https://www.youtube.com/watch?v=i4eKGAaLoUQ) | TheSystematician | Apr 24, 2026 | Focused overview of the 5 most impactful changes |
| [A Demo of vim.pack](https://www.youtube.com/watch?v=J1r0vrqOMJo) | echasnovski | Mar 13, 2026 | Comprehensive demo by vim.pack's primary author |
| [How to Setup Neovim 0.12 for AI Coding](https://www.youtube.com/watch?v=BBCScVuP3xo) | — | Apr 12, 2026 | From-scratch setup with AI coding plugins |
| [Neovim 0.12 Playlist](https://www.youtube.com/playlist?list=PLl0ydjOKtSawJnVkFsyO3JJHSUSYkryoo) | — | — | Curated playlist of multiple 0.12 videos |

### Blog Posts

| Post | Author | Date | Description |
|---|---|---|---|
| [What's New in Neovim 0.12](https://dotfiles.substack.com/p/whats-new-in-neovim-012) | Adib Hanna | Apr 5, 2026 | Most thorough community guide with practical examples and migration checklist |
| [A Guide to vim.pack](https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack) | Evgeni Chasnovski | Mar 13, 2026 | Definitive guide by vim.pack's author, covers concepts, migration from lazy.nvim |
| [Features I want to try first in Neovim 0.12](https://cj.rs/blog/nvim0.12/) | Clement Joly | Mar 29, 2026 | Practical first-impressions, highlights features worth trying |
| [Refreshing your Neovim config for 0.12.0](https://justinhj.github.io/2026/04/06/refreshing-your-neovim-config-for-0-12-0.html) | justinhj | Apr 6, 2026 | Hands-on account of clearing out and refreshing config for 0.12 |
| [Neovim 0.12 Config Walkthrough](https://williamhleucka.com/blog/neovim-0-12-config-2026) | William Hleucka | — | Highlights features that made author "audibly react" |
| [I read the nvim v0.12 release note so you don't have to](https://jdhao.github.io/2026/04/02/nvim-v012-release/) | jdhao | Apr 2, 2026 | Curated summary focusing on vim.pack and other highlights |
| [vim.pack vs lazy.nvim](https://samuellawrentz.com/blog/neovim-vim-pack-vs-lazy-nvim/) | Samuel Lawrentz | Mar 31, 2026 | Comparison: should you ditch lazy.nvim? |
| [Native LSP in Neovim 0.12](https://dotfiles.substack.com/p/native-lsp-in-neovim-012) | Adib Hanna | Apr 8, 2026 | Deep dive into native LSP improvements and `vim.lsp.config`/`vim.lsp.enable()` flow |
| [nvim-treesitter Archived. What You Need to Do](https://samuellawrentz.com/blog/nvim-treesitter-archived-neovim-0-12-migration/) | Samuel Lawrentz | Apr 13, 2026 | Migration guide for nvim-treesitter archival in context of 0.12 |

### Official Documentation

- [Official News Documentation](https://neovim.io/doc/user/news-0.12/) — Authoritative reference for all changes
- [GitHub Release](https://github.com/neovim/neovim/releases/tag/v0.12.0) — Release notes and downloads
- [Full Changelog](https://github.com/neovim/neovim/commit/fc7e5cf6c93fef08effc183087a2c8cc9bf0d75a) — Complete list of fixes and features
