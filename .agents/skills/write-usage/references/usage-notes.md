# Usage Notes

## Core Spec Shapes

- `cmd "name"` defines a command or subcommand.
- `arg "<name>"` defines a positional argument.
- `flag "-s --long <value>"` defines a flag.
- `complete "<arg>" run="..."` defines custom completion output.
- `config { ... }` defines config files, defaults, and aliases.

## Common Patterns

- Use nested `cmd` blocks to mirror the CLI tree.
- Prefer the compact `flag` form when the CLI is straightforward.
- Use the expanded `flag` block when alias, argument, or hide behavior is easier to read.
- Mark hidden aliases with `hide=#true`.
- Use `descriptions=#true` when completion output is `value:description`.
- Skip `descriptions=#true` when the description would just repeat the value.
- Use the template `words` list to make completions depend on earlier flags or args, such as `--lua-version`.

## KDL Intricacies

- Quote strings that contain spaces or reserved characters.
- Prefer raw strings for multi-line examples, shell snippets, and long help text.
- Use line continuations only when a single node must span lines cleanly.
- Remember that argument order matters; property order does not.
- Use child nodes when ordering or grouping is semantically important.
- Treat `/-` as a structural comment that removes the node from the parsed document.

## Recursive Authoring

1. Run `<cmd> --help` at the current node.
2. Extract every child command from the subcommand list.
3. For each child, run `<child> --help` too.
4. If `--help` is incomplete, consult `man <cmd>` or the subcommand man page.
5. Carry inherited/global flags to the appropriate parent node.
6. Preserve examples only when they clarify usage or edge cases.

## Local Generation Flow

The repo's zsh integration uses `home/dot_config/zsh/functions/gen-compusage`:

1. Author or update `home/dot_config/zsh/usage/<command>.kdl`.
2. Run `usage generate completion zsh <command> -f home/dot_config/zsh/usage/<command>.kdl`.
3. Install the generated completion into the shell's completion directory.
4. Re-run after spec changes.

## Validation

Use the `usage` CLI to validate specs before generating downstream artifacts:

- `usage lint <file>` catches common spec problems quickly.
- `usage lint -W <file>` treats warnings as failures.
- `usage lint -f json <file>` gives machine-readable output.
- `usage generate json -f <file>` is a good parse-and-normalize smoke test.
- `usage generate manpage -f <file>` confirms the rendered manpage shape.

Known quirk:

- `usage lint` can still emit `missing-cmd-help` for the root command node even when the top-level spec has `about` / `before_help` / `before_long_help`. Treat that as an informational lint quirk unless the generated output is actually wrong.

The example `home/dot_config/zsh/usage/herdr.kdl` shows a complete spec with:

- metadata (`name`, `bin`, `about`, `version`)
- global flags
- nested command trees
- args, flags, and completions
- config-aware behavior
