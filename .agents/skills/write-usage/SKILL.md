---
name: write-usage
description: Derive Usage KDL specs from `--help` and man pages. Use for authoring or updating `usage/*.kdl` files.
---

# Write Usage

## Workflow

1. Start at root command, run `--help`.
2. Record: cmd names, nesting, positional args, flags, aliases, defaults, env, config keys, examples.
3. Recurse into every subcommand — see Recursive Authoring.
4. Map CLI concepts to KDL nodes per Mapping Rules below.
5. Write one spec file per command tree.
6. Run local generation flow to produce shell completions.

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

Keep specs in `home/dot_config/zsh/usage/`. Generate completions with `usage generate completion zsh <cmd> -f <spec>`. See Local Generation Flow in usage-notes for details.

## Validate KDL

Run `usage complete-word --shell zsh -f <spec.kdl> -- <cmd> <partial>` to confirm completions return the expected values. This shells out for each completion — it catches logic errors in `run` scripts that `usage lint` can't.

Run `usage lint <file>` for syntax checks. Note: may report `missing-cmd-help` on root node even with `about` set — ignore unless generated docs are actually wrong.



## Verify Completions

Before generating the final shell completion file, smoke-test the spec directly with `usage complete-word`:

```
usage complete-word --shell zsh -f <spec.kdl> -- <cmd> <partial-cmdline>
```

- sets the shell profile (`--shell zsh`, `--shell fish`, `--shell bash`)
- `-f <spec>` points at the authored KDL file
- `--` separates `usage` flags from the simulated command line
- everything after `--` is the fake command line usage uses to compute completions
- append `''` (empty string) as the final token to get completions for the next word
- omit the trailing space but include enough words to reach the completion context you want to test

Examples:

```
# List notes for default vault
usage complete-word --shell zsh -f spec.kdl -- zen read ''

# List notes after --vault <name>
usage complete-word --shell zsh -f spec.kdl -- zen read --vault kbbit ''

# List folders after --folder
usage complete-word --shell zsh -f spec.kdl -- zen list --folder ''
```

This runs the `run` script inline (shelling out for each completion) without touching any installed completion file or real zsh state.

## KDL Notes

This spec uses **KDL 2.0**. See the [KDL spec](https://kdl.dev/spec/) for full language reference.

Key KDL 2.0 details for usage specs:

- Boolean values are `#true`, `#false`; null is `#null`
- quote strings with spaces or reserved KDL characters
- prefer raw strings for multi-line examples, shell snippets, and long help text
- use line continuations only when a single node must span multiple lines
- arguments are ordered; properties are not
- use child blocks when nesting or ordering matters
- `/-` removes the node from the parsed document (structural comment)

See [Usage Notes](references/usage-notes.md) for context-dependent completions, recursive authoring, and the local generation flow.
