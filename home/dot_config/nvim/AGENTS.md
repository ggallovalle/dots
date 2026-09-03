# Neovim config — agent context

This workspace (`~/.config/nvim`) is the **chezmoi target** for Neovim. It is not a git repository.

## Dotfiles repo

| | Path |
|---|---|
| Git repo (`$DOTFILES`) | `/home/kbroom/dots` |
| Remote | `git@github.com:ggallovalle/dots` |
| Chezmoi source | `$DOTFILES/home/dot_config/nvim` |
| Chezmoi target (this folder) | `~/.config/nvim` |

Chezmoi maps `home/dot_config/…` → `~/.config/…`. Edits here correspond to `home/dot_config/nvim/…` in the repo.

Repo-wide rules (chezmoi workflow, commit style, tooling) live in [`$DOTFILES/AGENTS.md`](/home/kbroom/dots/AGENTS.md).

## Editing

Prefer editing **source** at `$DOTFILES/home/dot_config/nvim` when working on changes that will be committed.

If you edit files in this target folder, sync them into the source tree before committing:

```bash
chezmoi add ~/.config/nvim/<path>
# or, for a specific file already under management:
chezmoi re-add ~/.config/nvim/<path>
```

Do not run `chezmoi apply` on the whole tree. Apply only specific paths when needed.

This config includes `kbplugin.chezmoi`: with Chezmoi enabled in Neovim, saving a managed target file runs `chezmoi add` automatically.

## Commits

Run all git commands from **`$DOTFILES`**, not from this folder.

```bash
cd "$DOTFILES"
git status
git add home/dot_config/nvim/<path>
git commit -m "<type>(nvim): <summary>"
```

Use [conventional commits](https://www.conventionalcommits.org/) with an `nvim` scope, matching existing history (e.g. `feat(nvim): …`, `chore(nvim): …`, `fix(nvim): …`).

Before committing, confirm the change exists under `home/dot_config/nvim/` in the repo (not only in this target directory).

## Layout

- `init.lua` — entrypoint
- `lua/kbinit/` — core config (plugins, LSP, keymaps, languages)
- `lua/kbplugin/` — local plugins (`chezmoi`, `restart`, `mdtyp`, …)
- `lua/std/` — shared stdlib helpers
- `lazy-lock.json` — plugin lockfile; commit when plugins change
