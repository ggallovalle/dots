# Channel Specification Reference

Channels are TOML files in `~/.config/television/cable/` (or `$TELEVISION_CONFIG/cable/`).

**Official TV docs:**

- [Create Your First Channel](https://alexpasmantier.github.io/television/getting-started/first-channel)
- [Channels Guide](https://alexpasmantier.github.io/television/user-guide/channels)
- [Keybindings Guide](https://alexpasmantier.github.io/television/user-guide/keybindings)
- [Actions Reference](https://alexpasmantier.github.io/television/reference/actions)
- [Channel Specification](https://alexpasmantier.github.io/television/reference/channel-spec)

## `[metadata]`

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | string | Yes | Unique channel identifier used to invoke (`tv <name>`) |
| `description` | string | No | Human-readable description |
| `requirements` | string[] | No | Required external tools (checked at runtime) |

## `[source]`

| Field | Type | Required | Description |
|---|---|---|---|
| `command` | string, string[], or `{name, run}`[] | Yes | Command(s) producing entries, one per line |
| `ansi` | boolean | No | Parse ANSI escape codes (default: false) |
| `display` | string | No | Template for display (incompatible with `ansi=true`) |
| `output` | string | No | Template for final output on selection |
| `watch` | float | No | Auto-reload interval in seconds |
| `entry_delimiter` | string | No | Custom entry delimiter (default: newline) |
| `no_sort` | boolean | No | Preserve original order, disables frecency |
| `frecency` | boolean | No | Enable frecency ranking (default: true) |

## `[preview]`

| Field | Type | Required | Description |
|---|---|---|---|
| `command` | string or string[] | No | Preview command template(s) (cycle with Ctrl+F) |
| `env` | table | No | Environment variables for preview |
| `offset` | string | No | Template to extract line offset |
| `header` | string | No | Preview panel header template |
| `footer` | string | No | Preview panel footer template |

## `[ui]`

| Field | Type | Default | Description |
|---|---|---|---|
| `ui_scale` | int (0-100) | 100 | Percentage of terminal to use |
| `layout` | string | "landscape" | "landscape" or "portrait" |
| `input_bar_position` | string | "top" | "top" or "bottom" |
| `input_header` | string | channel name | Input bar header |
| `input_prompt` | string | ">" | Input prompt |

### `[ui.preview_panel]`

| Field | Type | Default | Description |
|---|---|---|---|
| `size` | int (0-100) | 50 | Preview panel width/height percentage |
| `header` | string | - | Header template |
| `footer` | string | - | Footer template |
| `scrollbar` | boolean | true | Show scrollbar |
| `border_type` | string | "rounded" | "none", "plain", "rounded", "thick" |
| `hidden` | boolean | false | Hide by default |

### `[ui.results_panel]`

| Field | Type | Default | Description |
|---|---|---|---|
| `border_type` | string | "rounded" | Border style |
| `padding` | table | all 0 | Panel padding |

## `[keybindings]`

| Field | Type | Description |
|---|---|---|
| `shortcut` | string | Global shortcut to switch to this channel |
| `<action>` | string or string[] | Override default keybinding or bind custom action |

Map built-in actions or custom `actions:<name>`.

## `[actions.NAME]`

| Field | Type | Required | Description |
|---|---|---|---|
| `description` | string | No | Action description |
| `command` | string | Yes | Command template |
| `mode` | string | No | "fork" (default) or "execute" |
| `separator` | string | No | Multi-select join character (default: " ") |

**Modes:**

- `fork` — run command, return to tv when done
- `execute` — replace tv with the command (doesn't return)

## Template syntax

Uses the [string-pipeline](https://docs.rs/string_pipeline) crate. `{}` is replaced with the selected entry.

### Field extraction

| Syntax | Description |
|---|---|
| `{}` | Entire entry |
| `{0}` | First `:`-delimited field |
| `{split:/:0}` | First field after splitting by `/` |
| `{split:/:..}` | All fields |
| `{split:/:1..3}` | Fields 1, 2 (exclusive end) |
| `{split:/:.2}` | Single field at index 2 |

### Transforms

| Transform | Description |
|---|---|
| `{strip_ansi}` | Remove ANSI codes |
| `{trim}` | Strip leading/trailing whitespace |
| `{upper}` | Uppercase |
| `{lower}` | Lowercase |
| `{reverse}` | Reverse string |
| `{truncate:N}` | Truncate to N chars |
| `{pad:N:CHAR:left}` | Left-pad to N with CHAR |
| `{prepend:TEXT}` | Prepend TEXT |
| `{append:TEXT}` | Append TEXT |
| `{regex_extract:PATTERN}` | Extract regex match |
| `{regex_extract:PATTERN:GROUP}` | Extract capture group |
| `{regex_replace:PATTERN:REPL}` | Replace regex matches |

### Collection transforms (after `split`)

| Transform | Description |
|---|---|
| `filter:PATTERN` | Keep elements matching regex |
| `sort` / `sort:desc` | Sort ascending/descending |
| `map:{PIPELINE}` | Apply pipeline to each element |
| `join:GLUE` | Join elements with GLUE |
| `tail:N` | Last N elements |
| `head:N` | First N elements |
| `dedup` | Remove consecutive duplicates |
| `enumerate` | Prefix with index |

### Chaining

Pipe operations with `|`:

```
{split:,:..|filter:\.py$|sort|map:{prepend:• }|join:\n}
```

Complete example:

```
{regex_extract:[^/]+$|prepend:ghq.}
# Input:  "github.com/owner/repo"
# Output: "ghq.repo"
```
