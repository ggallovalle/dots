---
name: write-a-skill
description: Create new agent skills with proper structure, progressive disclosure, and bundled resources. Use when user wants to create, write, or build a new skill.
---

# Writing Skills

## Process

1. **Gather requirements** - ask user about:
   - What task/domain does the skill cover?
   - What specific use cases should it handle?
   - Should the skill be installed **locally** or **globally**?
     - Local: create under `<repo-root>/.agents/skills/<name>/`
     - Global: create under the global skills folder (`$XDG_CONFIG_HOME/opencode/skills/<name>/`)
      - Do **not** assume a default; always ask explicitly.
    - Does it need executable scripts or just instructions?
    - Any reference materials to include?

2. **User interaction rule** - when any part of the skill involves user interaction:
   - Use the **AskUserQuestion tool** (open-ended, no preset options).
   - Do not use preset options for these prompts.
   - The question text should be tailored to the task and phrased like this example:
     > "What change do you want to work on? Describe what you want to build or fix."

3. **Draft the skill** - create:
   - SKILL.md with concise instructions
   - Additional reference files if content exceeds 500 lines
   - Utility scripts if deterministic operations needed

4. **Validate scripts before done** - if scripts were added:
   - Run each script (or its expected invocation) with Bun and confirm it executes successfully.
   - Type-check scripts with `bunx tsc --noEmit` using the `tsconfig.json` created by `bun init` in `scripts/`.
   - Fix runtime/type issues before considering the skill complete.

5. **Review with user** - present draft and ask:
   - Does this cover your use cases?
   - Anything missing or unclear?
   - Should any section be more/less detailed?

## Skill Structure

Path notation rules:

- Do not use explicit user-specific absolute paths (for example, `/home/<user>/...`).
- Do not use `~` for XDG-managed locations.
- Use environment variables instead:
  - Config: `$XDG_CONFIG_HOME/...`
  - Data: `$XDG_DATA_HOME/...`
  - Cache: `$XDG_CACHE_HOME/...`
  - State: `$XDG_STATE_HOME/...`
  - Runtime: `$XDG_RUNTIME_DIR/...`
- For non-XDG home-relative paths, use `$HOME/...`.

Choose location first:

- Local skill path: `<repo-root>/.agents/skills/<name>/`
- Global skill path: `$XDG_CONFIG_HOME/opencode/skills/<name>/`

```
skill-name/
├── SKILL.md           # Main instructions (required)
├── REFERENCE.md       # Detailed docs (if needed)
├── EXAMPLES.md        # Usage examples (if needed)
└── scripts/           # Utility scripts (if needed)
    └── helper.ts
```

## SKILL.md Template

```md
---
name: skill-name
description: Brief description of capability. Use when [specific triggers].
---

# Skill Name

## Quick start

[Minimal working example]

## Workflows

[Step-by-step processes with checklists for complex tasks]

## Advanced features

[Link to separate files: See [REFERENCE.md](REFERENCE.md)]
```

## Description Requirements

The description is **the only thing your agent sees** when deciding which skill to load. It's surfaced in the system prompt alongside all other installed skills. Your agent reads these descriptions and picks the relevant skill based on the user's request.

**Goal**: Give your agent just enough info to know:

1. What capability this skill provides
2. When/why to trigger it (specific keywords, contexts, file types)

**Format**:

- Max 1024 chars
- Write in third person
- First sentence: what it does
- Second sentence: "Use when [specific triggers]"

**Good example**:

```
Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when user mentions PDFs, forms, or document extraction.
```

**Bad example**:

```
Helps with documents.
```

The bad example gives your agent no way to distinguish this from other document skills.

## When to Add Scripts

Add utility scripts when:

- Operation is deterministic (validation, formatting)
- Same code would be generated repeatedly
- Errors need explicit handling

Scripts save tokens and improve reliability vs generated code.

When scripts are needed, implement them with these standards:

- Use TypeScript for script files.
- Initialize the scripts folder with Bun (`bun init`) inside `scripts/`.
- Prefer Bun runtime APIs first (`Bun.file`, `Glob` from `bun`, Bun runtime features).
- Use `node:fs/promises` only for operations not supported by Bun APIs.
- Add a Bun shebang at the top of executable scripts (for example: `#!/usr/bin/env bun`).
- Structure scripts with an `async main()` function.
- Execute `main()` only when `import.meta.main` is true.
- Add a short header comment that states the script prefers Bun APIs and include docs links:
  - https://bun.com/docs/runtime/markdown
  - https://bun.com/docs/runtime/file-io
  - https://bun.com/docs/runtime/glob
  - https://bun.com/docs/runtime/toml
  - https://bun.com/docs/runtime/shell
  - https://bun.com/docs/runtime/webview

Example script pattern:

```ts
#!/usr/bin/env bun
/**
 * This script prefers Bun runtime APIs when possible.
 * Docs:
 * - https://bun.com/docs/runtime/file-io
 * - https://bun.com/docs/runtime/glob
 * - https://bun.com/docs/runtime/markdown
 * - https://bun.com/docs/runtime/toml
 * - https://bun.com/docs/runtime/shell
 * - https://bun.com/docs/runtime/webview
 */

import { Glob, Webview } from "bun";
import { mkdir } from "node:fs/promises";

async function main(): Promise<void> {
  const source = Bun.file("README.md");

  if (!(await source.exists())) {
    throw new Error("README.md not found");
  }

  const text = await source.text();
  const html = Bun.markdown.html(text);

  await mkdir("dist", { recursive: true });
  await Bun.write("dist/README.html", html);

  const shellResult = await Bun.$`ls -1`;
  console.log(shellResult.text());

  for await (const path of new Glob("**/*.md").scan(".")) {
    console.log(path);
  }

  if (process.env.SHOW_WEBVIEW === "1") {
    const win = new Webview();
    win.title = "README Preview";
    win.navigate(`data:text/html,${encodeURIComponent(html)}`);
    win.run();
  }
}

if (import.meta.main) {
  await main();
}
```

## When to Split Files

Split into separate files when:

- SKILL.md exceeds 180 lines
- Content has distinct domains (finance vs sales schemas)
- Advanced features are rarely needed

## Review Checklist

After drafting, verify:

- [ ] Description includes triggers ("Use when...")
- [ ] SKILL.md under 180 lines
- [ ] No time-sensitive info
- [ ] Consistent terminology
- [ ] Concrete examples included
- [ ] References one level deep
