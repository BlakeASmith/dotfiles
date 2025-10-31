# User Configuration Directory

This directory contains user-level configuration that's loaded by `init.lua`.

## Files

### keymaps.lua
General keybindings that work in both VSCode and standalone Neovim:
- Centered scrolling and search navigation
- Visual mode indentation
- Register-based copy/paste

### lspkeymap.lua
LSP-specific keybindings. Only loaded in standalone Neovim (VSCode handles LSP).

### format.lua
Formatting configuration. Only loaded in standalone Neovim.

### fuzzy.lua
Fuzzy search configuration. Only loaded in standalone Neovim.

### vscode-settings.lua (NEW)
VSCode-specific settings optimizations. Only loaded when `vim.g.vscode == true`.

## Loading Behavior

**In VSCode:**
```lua
require("user.vscode-settings")  -- VSCode optimizations
require("user.keymaps")           -- Keybindings
```

**In Standalone Neovim:**
```lua
require("user.lspkeymap")         -- LSP keybindings
require("user.format")            -- Formatting
require("user.fuzzy")             -- Fuzzy search
require("user.keymaps")           -- Keybindings
```

All keybindings are shared between both environments.
