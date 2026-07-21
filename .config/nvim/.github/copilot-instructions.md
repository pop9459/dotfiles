# Copilot Instructions for this Repository

## Build, test, and lint commands

This repository is a Neovim/NvChad user config and does not define a project build or automated test suite.

- **Format Lua config:** `stylua .`
- **Format a single file:** `stylua lua/configs/lspconfig.lua`

`stylua` settings are defined in `.stylua.toml` (4-space indents, 120 column width).

## High-level architecture

The config is an **overlay on top of NvChad**, not a standalone Neovim distribution:

- `init.lua` bootstraps `lazy.nvim`, loads `NvChad/NvChad` (`branch = "v2.5"`), then imports local plugin specs via `{ import = "plugins" }`.
- After plugin setup, the base46 cached theme files are loaded, then local runtime modules are applied in order:
  - `options` (`lua/options.lua`)
  - `autocmds` (`lua/autocmds.lua`)
  - `mappings` (`lua/mappings.lua`, loaded in `vim.schedule(...)`)
- `lua/chadrc.lua` is the NvChad-facing UI/theme config entrypoint (currently using `catppuccin`).

Language/tooling behavior is split across `lua/configs/*` and used by plugin specs:

- `lua/configs/mason-tool-installer.lua`: ensures LSP/formatter binaries are installed
- `lua/configs/lspconfig.lua`: applies NvChad LSP defaults, then enables configured servers
- `lua/configs/conform.lua`: filetype → formatter mapping and format-on-save behavior

## Key conventions in this codebase

- **Always extend NvChad defaults first** in user modules (`require "nvchad.options"`, `require "nvchad.mappings"`, `require "nvchad.autocmds"`), then apply local overrides.
- **Plugin specs live under `lua/plugins/`**, while reusable plugin configuration lives under `lua/configs/` and is referenced with `opts = require "configs.<name>"` (or loaded in `config` callbacks).
- **Formatter/LSP toolchain is synchronized**: `mason-tool-installer` installs tools that are then referenced by `lspconfig` and `conform`.
- **Copilot keybinding convention:** Tab completion is disabled for Copilot (`copilot_no_tab_map = true`), and acceptance is mapped to `<C-l>` in insert mode.
- **Local editing defaults are opinionated:** 120-char preferred width (`textwidth` + `colorcolumn`), no wrap, scrolloff 8, and explicit PHP 4-space indent via `FileType` autocmd.
