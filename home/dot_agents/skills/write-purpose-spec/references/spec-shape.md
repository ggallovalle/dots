# Purpose Spec Shape Reference

Use this as a compact checklist when creating specs similar to `specs/004-superschema`.

## Top-Level Files

`plan.typ` should carry the executive shape:

- `Goal`
- `Motivation`
- `Decision Summary`
- `Non-Goals`
- `Implementation Sequence`
- `Final Acceptance`

`context.typ` should carry conceptual onboarding:

- why the feature exists
- main concepts
- current limitations
- glossary or domain terms
- invariants that affect many tasks

`design.typ` should carry the contract:

- status
- purpose
- architectural contracts
- public API sketches
- state ownership and lifetimes
- error handling and diagnostics
- extension points
- concurrency or performance constraints

Focused reference files such as `composition.typ` should be used when one topic needs deeper treatment than fits cleanly in `design.typ`.

## Task Files

Unimplemented task files should include:

- `Goal`
- `Scope`
- `Baseline Inputs`
- `Requirements`
- `Tests`
- `Done`

Implemented task files may preserve the original plan but should start with an implementation record:

- `Implementation Notes`
- `Files Created`
- `Files Modified`
- `Shortcuts / Deferred`
- `Blockers`
- `Verification`

## Typst HTML Check

Compile changed `.typ` files with:

```bash
typst compile --features html --format html path/to/file.typ /tmp/file.html
```

Typst HTML is stricter than prose review for syntax mistakes, especially invalid links, accidental markup, and unbalanced code fences.
