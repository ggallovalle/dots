# Neovim Config

A minimal Neovim configuration using `vim.pack` for plugin management.

## Keymaps

See [keymaps.lua](./lua/kbroominit/keymaps.lua)

## Requirements

See [doctor.lua](./lua/kbroominit/doctor.lua)

## Quick Start

```bash
# Restart Neovim - plugins install automatically
nvim
```

## Updating Plugins

```bash
nvim
vim.pack.update()  -- or :lua vim.pack.update()
```

