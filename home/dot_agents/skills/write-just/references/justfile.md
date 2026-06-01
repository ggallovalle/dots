# Justfile Reference

## What To Rely On

- Recipes live in a `justfile`.
- `just` searches for a `justfile` in the current directory and parent directories.
- By default, recipes run in the directory that contains the `justfile`.
- `set working-directory := '...'` changes the default working directory for recipes.
- `[working-directory: '...']` overrides the working directory for a single recipe.
- `set no-cd` and `[no-cd]` keep recipes in the invocation directory instead of the `justfile` directory.

## Arguments

- Recipe parameters are supported.
- Quote interpolations when shell splitting would be wrong.
- Use exported arguments or positional arguments when you need shell-safe handling.

## Dependencies

- Recipes can depend on other recipes.
- Dependencies run before the dependent recipe.
- Subsequent dependencies can be chained with `&&`.

## Shell

- `set shell := ["zsh", "-cu"]` selects the shell used for recipe lines.
- Use a shell-specific recipe when the workflow needs shell features.

## Validation

- Run the actual recipe and check exit status and output.
- Compare migrated recipes against the original mise task behavior.
