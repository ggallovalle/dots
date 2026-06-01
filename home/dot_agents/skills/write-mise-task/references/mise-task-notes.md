# Mise Task Notes

## Task Forms

- Use `mise.toml` tasks for small declarative wrappers.
- Use file tasks in `mise-tasks/`, `.mise/tasks/`, `mise/tasks/`, or `.config/mise/tasks/` when the task is a real script.
- File tasks can be grouped in subdirectories; names gain prefixes from the path.
- `_default` inside a task directory becomes that directory's base task.

## Choosing the Form

Use a TOML task when:

- the command is one line or close to it
- the task has minimal branching
- the behavior is mostly config, not code

Use a file task when:

- the task has shell logic, loops, conditionals, or multiple steps
- the task needs a shebang or a specific interpreter
- the task should feel like a script that mise discovers and runs
- the task needs `#USAGE` directives beside the implementation

## Converting a Script

1. Start with the script's intent, not its shell syntax.
2. Add a `description` that says what the task does.
3. Extract user inputs into args, flags, env vars, or task dependencies.
4. Move sequencing into `depends` where possible.
5. Add `sources` and `outputs` when the task should be skipped if nothing changed.
6. Choose TOML if the body stays small; otherwise move the script to a file task.

## Usage Integration

Use the `write-usage` skill when the task should expose a CLI-like surface.

- For TOML tasks, place the spec in `usage = '''...'''`.
- For file tasks, add `#USAGE` lines to the script.
- Use usage for flags, args, defaults, env bindings, choices, and completions.
- Validate usage-backed tasks with `mise tasks validate`; it checks `#USAGE` directives and specs.
- Install or test completions only after `usage` parses cleanly.

## Environment Guidance

Use mise environments when the variable belongs to the project, not the task:

- put project-wide values in `[env]` in `mise.toml`
- use `mise set` / `mise unset` for quick edits
- use `mise env --json` or `mise env --dotenv` when you need exported output
- use task `env` for task-local values, file-backed env, or values that should only exist while the task runs
- mark required variables with `required = true` or a required message
- use `redact = true` or `redactions` for sensitive values
- use `tools = true` when an env value depends on installed tools or `PATH`
- remember that environment variables are available to `mise run` and `mise exec`

## Validation

Use these checks before you consider a task finished:

- `mise tasks validate` to catch dependency cycles, missing refs, invalid usage specs, and file existence issues
- `mise tasks validate --json` for machine-readable output
- `mise tasks info <task>` to inspect the resolved task
- `mise tasks ls` to confirm the task is discoverable

## Practical Shape

Good task metadata usually includes:

- `description`
- `alias` when the task should have a short name
- `depends` for ordering
- `env` for stable inputs
- `sources` and `outputs` for freshness checks
- `run_windows` only when the behavior differs on Windows

Prefer task names that read like commands. Prefer dependencies over inline orchestration. Prefer file tasks once the body stops looking like configuration.
