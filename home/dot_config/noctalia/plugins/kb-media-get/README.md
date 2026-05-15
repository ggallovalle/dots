# KB Media Get

Noctalia plugin that opens a small popup to paste a URL, then runs a background media fetch command and shows a notification when it finishes.

## Features

- Minimal centered popup
- Submit with `Enter`
- Close with `Esc`, `Ctrl+C`, or click outside
- Validates single non-empty `http(s)` URL
- Runs command in background
- Shows start + result notifications
- Shortens home path in success message (`/home/user/...` -> `~/...`)

## Trigger

Default Niri keybind in this repo:

- `Mod+Shift+M` -> `qs -c noctalia-shell ipc call plugin:kb-media-get toggle`

## IPC

Show available functions:

```bash
qs -c noctalia-shell ipc show
```

Plugin target:

- `plugin:kb-media-get`

Functions:

- `toggle`
- `showCommandPath`
- `setCommandPath <path>`

Examples:

```bash
qs -c noctalia-shell ipc call plugin:kb-media-get showCommandPath
qs -c noctalia-shell ipc call plugin:kb-media-get setCommandPath "/home/kbroom/ghq/github.com/ggallovalle/kbzsh.jelly/apps/cli/src/main.ts"
```

## Command Execution

The plugin executes:

```bash
bun run <commandPath> -- media get --json <url>
```

`commandPath` is configurable via plugin settings (through IPC `setCommandPath`).

Default path in this repo:

- `/home/kbroom/ghq/github.com/ggallovalle/kbzsh.jelly/apps/cli/src/main.ts`

## Reload

After changing plugin code:

```bash
killall qs && qs -c noctalia-shell
```
