# Usage Notes

## Context-Dependent Completions

1. Define `complete <arg> run="..."` at root level — it cascades into every `cmd` that has that arg name.

2. In the `run` script, use Tera to materialise the current command line:
   ```
   set -- {% for word in words %}{{ word }}{% if not loop.last %} {% endif %}{% endfor %}
   ```

3. Walk `$@` with a `case` loop to extract the relevant flag value:
   ```
   value=
   while [ $# -gt 0 ]; do
     case $1 in
       --flag)   shift; value=${1-};  break ;;
       --flag=*) value=${1#*=};       break ;;
     esac
     shift
   done
   ```
    Break after the first hit — only guaranteed match in practice.

4. Build the completion command conditionally:
   ```
   cmd --json ${value:+--flag "$value"} | jq ...
   ```
   `${value:+--flag "$value"}` expands to the flag only when `$value` is non-empty.

### KDL string notes

- Prefer `"""..."""` multi-line strings over `\"` escaping — they avoid quote-escalation entirely. Open with `run="""` and a newline immediately after.
- `$` is NOT special in KDL double-quoted or multi-line strings — use it literally (`$1`, `$vault`, `${1-}`).
- Use `\"` only when a single-line `"..."` string must contain shell double quotes.
- `\$` is NOT a valid KDL escape — will cause a parse error.

### When to use

This pattern is worth it when:
- The completion depends on a flag that selects between data sources (vault, profile, environment, server).
- The command exposes a machine-readable output format that can be filtered programmatically.
- The number of values is unbounded or dynamic (file system, DB, API).

Skip it when the completion targets a static or small enumerated set — use `choices` or a simple `run` script instead.

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

Examples under `home/dot_config/zsh/usage/` show complete specs with metadata, global flags, nested command trees, args, flags, completions, and config-aware behavior.
