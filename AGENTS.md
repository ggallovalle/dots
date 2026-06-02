# Chezmoi dotfiles

This repo manages dotfiles with [chezmoi](https://www.chezmoi.io/).

- **Source path**: `home/` (configured as `sourceDir` in `machine/cachyos/chezmoi.yaml`)
- Chezmoi is installed via mise (see `mise.toml`)

## Critical rule

**Whenever you modify a file under `home/`, you MUST run `chezmoi apply` afterward** to apply the changes to the real home directory. Forgetting this means the source files will be out of sync with what's actually installed.
