---
name: write-mise-task
description: Turn shell scripts and CLI workflows into idiomatic mise tasks, including deciding between TOML tasks and file tasks, adding dependencies/aliases/env, integrating usage specs for args and completions, and validating with mise task tooling. Use when authoring or refactoring `mise.toml` tasks or executable task files under `mise-tasks/`, `.mise/tasks/`, `mise/tasks/`, or `.config/mise/tasks/`.
---

# Write Mise Task

## Workflow

1. Identify the task's real contract:
   - inputs, outputs, side effects
   - dependencies and ordering
   - arguments, flags, env vars, defaults
   - whether it should be reusable from `mise run`
2. Choose the task form:
   - use a TOML task for short, declarative, low-logic tasks
   - use a file task for executable scripts, multiline shell, shell-specific logic, or when the task needs to be a first-class script
3. If the task has user-facing arguments or completions, add a usage spec.
   - use the `write-usage` skill for the spec itself
   - embed `usage = '''...'''` in TOML tasks
   - use `#USAGE ...` comments in file tasks
4. Add the mise metadata that makes the task idiomatic:
   - `description`
   - `alias`
   - `depends`
   - `env`
   - `sources` / `outputs` when the task can be skipped safely
5. Validate with `mise tasks validate` before considering it done.

## Environment Rules

- Use `[env]` in `mise.toml` for project-wide environment state.
- Use task `env` for task-local values and file-based env loading.
- Mark required variables explicitly instead of hiding them in the script body.
- Use `redact` for secrets and `tools = true` when env values depend on tools.
- If the request is really about environment setup rather than a runnable task, prefer an environment config over a task.

## Split Rules

- Keep simple wrappers in `mise.toml`.
- Split to a file task when the body becomes a script instead of configuration.
- Split when the task needs rich argument parsing, completions, or docs and the usage spec would dominate the TOML entry.
- Split when the task is shared across directories or benefits from grouped file-task discovery.
- Split when the shell logic is platform-sensitive and needs its own shebang or interpreter.

## Output Shape

- Prefer names that read like commands, not shell fragments.
- Put descriptions on every user-facing task.
- Use dependencies instead of manual sequencing inside the script when the ordering is meaningful.
- Use `usage`-powered args for anything the user should type or tab-complete.

See [mise task notes](references/mise-task-notes.md) for the task/file-task layout, validation commands, and examples of turning scripts into idiomatic tasks.
