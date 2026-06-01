---
name: write-just
description: Write and refactor Justfiles, handling recipe syntax, working directories, arguments, dependencies, shell settings, and validation. Use when the user asks how to write justfiles, needs help with Just syntax or behavior, or wants to convert a shell workflow or mise task into a Just recipe.
---

# Write Just

## Workflow

1. Decide whether the task belongs in `just` at all.
   - Use `just` for shell workflows, multi-step commands, directory-aware recipes, and reusable local commands.
   - Keep trivial project metadata in `mise.toml` if `just` would add no value.
2. Prefer a Justfile when the command is a real recipe.
   - Use the project root `justfile` for shared commands.
   - Use a nested `justfile` only when the workflow is scoped to that subdirectory.
3. Map a mise task to Just only when migration is the goal.
   - Convert task `run` lines to recipe lines.
   - Convert `depends` to recipe dependencies.
   - Move task-local env into recipe variables or shell env setup.
   - Preserve the working directory explicitly if the recipe must run from a subdirectory.
4. Handle arguments deliberately.
   - Use recipe parameters for typed inputs.
   - Quote interpolations or use exported / positional arguments when shell splitting matters.
   - Keep flags simple unless the recipe truly needs them.
5. Keep recipes idiomatic.
   - Prefer short recipes and dependencies over long inline shell blocks.
   - Use `set shell := [...]` when the recipe needs zsh or another shell.
   - Use `set working-directory := ...` or `[working-directory: ...]` when recipes must run elsewhere.
6. Validate by running the actual command.
   - Confirm the Justfile parses.
   - Run the recipe and check stdout, stderr, and exit status.
   - If migrating from mise, compare the new recipe against the old task behavior.

## Migration Rules

- If a mise task is just a shell wrapper, convert it directly to a recipe.
- If a mise task depends on working-directory, dependencies, or argument handling, prefer a `justfile`.
- If the command needs more than simple parameter substitution, use a recipe rather than forcing it into `mise.toml`.
- If the command is only useful from one subdirectory, put the Justfile there and run it from that tree.

## Use The Reference

Read [`references/justfile.md`](references/justfile.md) before making claims about Just syntax or behavior.
