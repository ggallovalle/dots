---
name: caveman-review
description: >
  Ultra-compressed code review comments. Cuts noise from PR feedback while preserving
  the actionable signal. Each comment is one line: location, problem, fix. Use when user
  says "review this PR", "code review", "review the diff", "/review", or invokes
  /caveman-review. Auto-triggers when reviewing pull requests.
---

Write code review comments terse and actionable. One line per finding. Location, mnemonic name, problem, fix. No throat-clearing.

## Rules

**Format:** `L<line>: <SEVERITY> <MNEMONIC> [F<N>]: <problem>. <fix>.`

Each finding gets a mnemonic — a short UPPERCASE slug that distills the issue — and a sequential `F<N>` ID (`F1`, `F2`, …) assigned in order within each review. Use the ID to reference the finding in follow-up threads: "F3 still applies after the rebase" or "fixed F1, F4".

**Common mnemonics:**

| Mnemonic | When to use |
|----------|-------------|
| `NULL` | unchecked null/undefined path |
| `BOUNDS` | missing guard, range, or validation |
| `RETRY` | missing retry or backoff |
| `RACE` | race condition, unsynchronized shared state |
| `ERR` | swallowed/hidden error |
| `PERF` | performance issue (N+1, O(n²), re-render) |
| `NEST` | excessive nesting, early-return opportunity |
| `DUP` | duplicated logic or config |
| `MAGIC` | magic number or string |
| `UNUSED` | dead code, unused import/param |
| `SIDE` | side effect in pure-ish context |
| `TYPE` | type safety gap, `any`, loose cast |
| `SEC` | security concern (injection, secret leak) |
| `FRAG` | fragile test (timing, order-dependent, mock tight) |

New mnemonics are welcome — invent whatever captures the essence. Author and reviewer can refer to findings by mnemonic alone in follow-up threads.

**Severity prefix (optional, when mixed):**
- `🔴 bug:` — broken behavior, will cause incident
- `🟡 risk:` — works but fragile (race, missing null check, swallowed error)
- `🔵 nit:` — style, naming, micro-optim. Author can ignore
- `❓ q:` — genuine question, not a suggestion

**Drop:**
- "I noticed that...", "It seems like...", "You might want to consider..."
- "This is just a suggestion but..." — use `nit:` instead
- "Great work!", "Looks good overall but..." — say it once at the top, not per comment
- Restating what the line does — the reviewer can read the diff
- Hedging ("perhaps", "maybe", "I think") — if unsure use `q:`

**Keep:**
- Exact line numbers
- Exact symbol/function/variable names in backticks
- Concrete fix, not "consider refactoring this"
- The *why* if the fix isn't obvious from the problem statement

## Examples

❌ "I noticed that on line 42 you're not checking if the user object is null before accessing the email property. This could potentially cause a crash if the user is not found in the database. You might want to add a null check here."

✅ `L42: 🔴 bug NULL [F1]: user can be null after .find(). Add guard before .email.`

❌ "It looks like this function is doing a lot of things and might benefit from being broken up into smaller functions for readability."

✅ `L88-140: 🔵 nit NEST [F2]: 50-line fn does 4 things. Extract validate/normalize/persist.`

❌ "Have you considered what happens if the API returns a 429? I think we should probably handle that case."

✅ `L23: 🟡 risk RETRY [F3]: no retry on 429. Wrap in withBackoff(3).`

## Auto-Clarity

Drop terse mode for: security findings (CVE-class bugs need full explanation + reference), architectural disagreements (need rationale, not just a one-liner), and onboarding contexts where the author is new and needs the "why". In those cases write a normal paragraph, then resume terse for the rest.

## Boundaries

Reviews only — does not write the code fix, does not approve/request-changes, does not run linters. Output the comment(s) ready to paste into the PR. "stop caveman-review" or "normal mode": revert to verbose review style.
