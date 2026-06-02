---
name: tv-channel
description: Create, preview, and validate Television (tv) channel TOML files. Covers source commands, preview templates, custom actions (fork/execute), keybindings, template pipeline syntax, and channel testing. Use when the user asks to create or modify a tv channel (`*.toml` in `~/.config/television/cable/`).
---

# TV Channel

## Quick start

A channel is a TOML file in `~/.config/television/cable/`. Minimum:

```toml
[metadata]
name = "my-channel"

[source]
command = "my-command"
```

Invoke: `tv my-channel`

## Workflows

### 1. Design the source command

The source produces one entry per line. Ask the user what they want to search. Examples:

- `ghq list` — list repos
- `docker ps` — list containers
- `fd -t f` — list files
- Custom command with `--format` for structured output

### 2. Add a preview

```toml
[preview]
command = "bat -n --color=always '{}'"
```

`{}` is replaced with the selected entry. Use `{split:DELIM:INDEX}` to extract fields from structured input.

### 3. Add custom actions

Two modes:

| Mode | Behavior |
|---|---|
| `fork` | Run command, return to tv when done |
| `execute` | Replace tv with the command |

```toml
[keybindings]
enter = "actions:open"
ctrl-e = "actions:edit"

[actions.open]
command = "open '{}'"
mode = "fork"

[actions.edit]
command = "nvim '{}'"
mode = "execute"
```

When the action spawns a new terminal window (e.g. wezterm, foot), use `mode = "fork"`.
When the action replaces tv (e.g. cd into a dir, nvim, $EDITOR), use `mode = "execute"`.

### 4. Track with chezmoi

Since tv config is chezmoi-managed in this repo (mapped under `home/dot_config/television/cable/`):

```bash
chezmoi add ~/.config/television/cable/<channel>.toml
chezmoi apply
```

Check it's tracked: `chezmoi managed | grep television`

### 5. Validate the channel

1. Run `tv <name>` — check it loads without errors.
2. Press `ctrl-r` — reload source, verify entries appear.
3. Navigate entries — preview panel should update.
4. Test each action — verify correct behavior and that `fork`/`execute` mode is right.
5. Check the channel appears in remote control (`ctrl-t`).

### 5. Template pipeline reference

Patterns for transforming entries. See [REFERENCE.md](REFERENCE.md#template-syntax) for full list.

| Pattern | Description |
|---|---|
| `{}` | Entire entry |
| `{split:/:.2}` | Field at index 2 after splitting by `/` |
| `{split:/:1..3}` | Fields 1 through 3 (exclusive end) |
| `{regex_extract:\d+}` | Extract digits |
| `{regex_extract:[^/]+$\|prepend:foo.}` | Extract basename, prefix with `foo.` |
| `{strip_ansi}` | Remove ANSI escape codes |
| `{trim}` | Strip whitespace |
| `{upper}` / `{lower}` | Case conversion |
| `{split:D:..\|filter:PATTERN\|sort\|join:GLUE}` | Split, filter, sort, rejoin |

### 6. Common patterns

**Idempotent session attach:**
```toml
[actions.zellij]
command = "wezterm start --cwd $(ghq root)/'{}' -- zellij attach -c '{regex_extract:[^/]+$}'"
mode = "fork"
```
`zellij attach -c` creates if missing, attaches if exists.

**Multi-source cycling with names:**
```toml
[source]
command = [
  { name = "Default", run = "fd -t f" },
  { name = "Hidden",  run = "fd -t f -H" },
]
```

**Preview fallback:**
```toml
[preview]
command = "eza --color=always -T -L 2 '{}' 2>/dev/null || ls -1 '{}'"
```
