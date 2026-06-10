---
name: write-usage
description: Convert CLI `--help` output and man pages into Usage KDL, including recursive subcommand discovery, flags, args, completions, config, KDL validation, and local generation flow. Use when building or updating `usage/*.kdl` specs from an existing command's help text or man page output.
---

# Write Usage

## Workflow

1. Start at the root command.
2. Read `--help` and record:
   - command names and nesting
   - positional args
   - flags, aliases, defaults, env vars, config keys
   - examples and hidden/global behavior
3. Recurse into every subcommand branch by running each child with `--help` too.
   - example: `luarocks --help`
   - then: `luarocks show --help`
   - then: `luarocks install --help`
   - continue until leaf commands are covered
4. Use `man` pages to fill gaps, confirm defaults, and capture details omitted by `--help`.
5. Normalize everything into `usage` KDL.
6. Write one spec file per command tree or entrypoint, mirroring the CLI layout.
7. Run the local generation flow to install completions or other derived output.

## Mapping Rules

- Use `cmd "name"` for subcommands; nest children under their parent.
- Use `arg "<name>"` for positionals.
- Use `flag "-s --long <value>"` or the expanded node form when aliases or arguments are clearer.
- Set `hide=#true` for hidden aliases or commands.
- Preserve inherited/global flags at the highest sensible level.
- Add `complete` entries when the CLI exposes enumerated or discoverable values.
- Omit `descriptions=#true` when the completion label and inserted value are the same.
- Use Tera `words` context when a completion depends on earlier args or flags.
- Capture `config`, `env`, and `default` only when the source documents them.

## Source Priority

Prefer this order when information conflicts:

1. Actual CLI `--help` output
2. `man` page
3. Existing usage spec or local examples

If the CLI has recursive subcommands, treat help from each subcommand as authoritative for that branch.

## Local Flow

Use the repo's usage authoring pattern as the system-of-record for output. The zsh flow in `home/dot_config/zsh/functions/gen-compusage` shows the intended install step:

- keep authored specs in `home/dot_config/zsh/usage/`
- generate shell completion from the spec with `usage generate completion zsh <cmd> -f <spec>`
- regenerate after spec edits

## Validate KDL

Use the `usage` CLI itself as the primary validator before generating artifacts:

- run `usage lint <file>` for a fast parse and rule check
- add `-W` to turn warnings into failures when you want stricter review
- use `-f json` when you need machine-readable output for automation
- smoke-test the spec with `usage generate json -f <file>` if you want to inspect the normalized spec
- generate docs with `usage generate manpage -f <file>` when you want to confirm the rendered manual text

Note: `usage lint` currently reports `missing-cmd-help` for the root command node even when the top-level spec already has `about` / `before_help` / `before_long_help`. Treat that info as a CLI lint quirk unless the generated docs are actually missing the intended top-level help text.

## KDL Notes

Keep KDL readable and valid as a document language, not just as a CLI spec:

- quote any string that contains spaces, punctuation, or reserved KDL characters
- prefer raw strings for multi-line help text, examples, or shell snippets
- use line continuations only when a single node must span multiple lines
- remember that arguments are ordered, but properties are not
- use children blocks when ordering matters or the structure is nested
- use `/-` or `//` only for comments; do not rely on commented-out nodes to contribute data

See [Usage Notes](references/usage-notes.md) for the spec summary and the local authoring flow.
