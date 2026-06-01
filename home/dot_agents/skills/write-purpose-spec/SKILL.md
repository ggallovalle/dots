---
name: write-purpose-spec
description: Write or update purpose-oriented implementation specs in Typst, especially repo specs like specs/004-superschema with context.typ, design.typ, plan.typ, composition/reference files, and tasks/*.typ. Use when Codex needs to create a new spec directory, add or revise spec/task documents, preserve the local spec structure, make the writing goal-driven rather than task-dump driven, and verify valid Typst syntax by compiling to HTML.
---

# Write Purpose Spec

## Workflow

1. Inspect nearby specs before writing. Read the target spec directory, or if creating a new one, read the closest existing numbered spec and at least one completed task file.
2. Identify the purpose before the work list. State the problem, architectural intent, behavioral target, and non-goals before prescribing tasks.
3. Preserve the repo's Typst shape. Use `.typ` files with Typst headings, plain bullets, fenced code examples when needed, and `#link("relative/path.typ")[...]` for internal links.
4. Keep specs executable as planning artifacts. Tasks should name files, requirements, tests, done criteria, shortcuts/deferred work, blockers, and verification commands when applicable.
5. Verify every created or edited Typst file can compile to HTML.

## Directory Shape

Prefer this structure for a substantial spec:

```text
specs/NNN-topic/
├── context.typ
├── design.typ
├── plan.typ
├── composition.typ or other focused reference files when needed
└── tasks/
    ├── README.typ
    ├── 001-short-task-name.typ
    ├── 002-short-task-name.typ
    └── ...
```

Use fewer files for small specs, but keep the roles distinct:

- `context.typ`: explain why the work exists, user/domain concepts, current system constraints, glossary, and invariants.
- `design.typ`: define the target architecture or behavior contract. Prefer decisions, APIs, data flow, ownership, lifecycle, failure modes, and explicit constraints.
- `plan.typ`: summarize the goal, motivation, decision summary, non-goals, implementation sequence, and final acceptance.
- `tasks/README.typ`: list the ordered tasks and link to each task file.
- `tasks/*.typ`: make each implementation step independently actionable and verifiable.
- Focused reference files: split out deep design areas only when they would overload `design.typ`.

## Purpose-Oriented Writing

Start every spec from a thesis, not from a backlog. A good spec answers:

- What outcome must exist when this is done?
- Why is the outcome needed now?
- What compatibility, migration, or behavioral target constrains the design?
- What is intentionally out of scope?
- What would prove the implementation is complete?

For architecture specs, include contracts that future tasks can test against. Avoid vague phrasing such as "improve", "handle better", or "support things" unless immediately tied to observable behavior.

For task specs, write so an implementer can start without rediscovering context. Include:

- `Goal`
- `Scope`
- `Baseline Inputs`
- `Requirements`
- `Tests`
- `Done`

If a task has already been implemented, put the implementation record first, before the original task plan:

- `Implementation Notes`
- `Files Created`
- `Files Modified`
- `Shortcuts / Deferred`
- `Blockers`
- `Verification`

## Typst Conventions

Use valid Typst syntax:

- `= Title`, `== Section`, `=== Subsection` for headings.
- Backticks for inline code.
- Markdown-style bullets are accepted in Typst; keep indentation simple.
- Use fenced code blocks for code or tree examples.
- Use `#link("tasks/README.typ")[\`tasks/\`]` for relative links.
- Avoid raw Markdown links like `[text](path)`; that is not Typst syntax.
- Avoid Markdown pipe tables. Use Typst table syntax, for example `#table(columns: 2, [Name], [Purpose], [context.typ], [Concepts])`, or use bullets when a table is not needed.
- Escape or avoid unmatched `{`, `}`, `#`, `$`, and backslashes in prose when Typst treats them as syntax.

## Verification

After editing, compile each changed Typst document to HTML from the repo root:

```bash
typst compile --features html --format html specs/NNN-topic/plan.typ /tmp/plan.html
typst compile --features html --format html specs/NNN-topic/design.typ /tmp/design.html
typst compile --features html --format html specs/NNN-topic/tasks/001-task.typ /tmp/001-task.html
```

For many files, loop over them and write outputs under a temporary directory:

```bash
tmpdir="$(mktemp -d)"
for file in specs/NNN-topic/*.typ specs/NNN-topic/tasks/*.typ; do
  typst compile --features html --format html "$file" "$tmpdir/$(basename "$file" .typ).html"
done
```

Fix all Typst diagnostics before finishing. Report the verification command run and whether it passed.
