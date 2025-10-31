# VSCode NVIM Plugin Configuration

Your Neovim configuration has been set up to work seamlessly with the VSCode NVIM plugin.

## How It Works

The configuration uses Neovim's `vim.g.vscode` global variable to detect when running in VSCode and automatically adjusts behavior:

- **In VSCode**: Minimal configuration with only keymaps and VSCode-compatible plugins
- **In standalone Neovim**: Full configuration with all plugins, LSP, formatting, etc.

## Configuration Files

### `nvim/init.lua`
Main entry point that detects VSCode environment and conditionally loads:
- VSCode mode: `vscode-settings.lua` + `keymaps.lua`
- Neovim mode: Full lazy.nvim setup with all plugins

### `nvim/lua/config/lazy.lua`
Plugin manager configuration that:
- Skips plugin loading in VSCode (`cond = not vim.g.vscode`)
- Disables plugin update checks in VSCode
- Still loads when in VSCode to avoid errors, but with plugins disabled

### `nvim/lua/user/vscode-settings.lua` (NEW)
VSCode-specific settings that:
- Disable line numbers (VSCode provides its own)
- Disable cursor line/column (VSCode handles this)
- Set performance-optimized timeouts
- Disable unused providers (ruby, perl, node)

### `nvim/lua/plugins/vscode.lua` (NEW)
Lightweight plugins that work great in VSCode:
- `vim-repeat`: Enhance `.` repeating
- `vim-surround`: Surround text operations
- `targets.vim`: Better text objects
- `vim-visual-multi`: Multiple cursor support

### `nvim/lua/user/keymaps.lua`
Your existing keymaps that work in both environments:
- Centered scrolling (Ctrl-D, Ctrl-U)
- Centered search navigation
- Visual mode indentation

## Usage

### VSCode with Neovim Extension

1. Install the **Neovim** extension in VSCode
2. Set your Neovim path in VSCode settings:
   ```json
   "vim.neovimPath": "/path/to/nvim"
   ```
3. Use Vim keybindings in VSCode - your keymaps will load automatically

### Standalone Neovim

Just use Neovim normally:
```bash
nvim
```

All plugins, LSP, formatting, and your full configuration loads as before.

## Keybindings Available in Both

Your keybindings work identically in both environments:
- `<leader>y[1-4]` - Yank to registers 5-8
- `<leader>p[1-4]` - Paste from registers 5-8
- `Ctrl-D/U` - Centered page scrolling
- `n/N` - Centered search navigation
- `< / >` - Indent in visual mode

## What's Different in VSCode

When running in VSCode:
1. All your full-featured plugins are disabled (Telescope, Noice, Mason, LSP, etc.)
2. VSCode handles completion, diagnostics, formatting
3. VSCode provides UI elements (line numbers, status bar, command palette)
4. Neovim provides only keybindings and text editing power
5. Lightweight VSCode-compatible plugins enhance vim motions

## Performance Notes

- VSCode mode is lightweight - minimal Neovim overhead
- Standalone Neovim has full functionality with all plugins
- The same config file handles both seamlessly

## Troubleshooting

### Plugins Loading in VSCode
If full plugins load in VSCode, check:
1. Verify `vim.g.vscode` is being set by the VSCode extension
2. Ensure lazy.lua has `cond = not vim.g.vscode` on plugin import

### Keymaps Not Working
1. Ensure VSCode extension is installed and enabled
2. Check keymaps don't conflict with VSCode shortcuts
3. Verify neovimPath is set correctly in VSCode settings

### Settings Conflicts
If VSCode-specific settings don't apply:
1. Check `vscode-settings.lua` is being required in VSCode branch
2. Verify `vim.g.vscode` is true: `:lua print(vim.g.vscode)`

## Future Customization

To add more VSCode-specific keymaps, edit `nvim/lua/user/keymaps.lua` (they apply to both).

To add more VSCode-compatible plugins, add them to `nvim/lua/plugins/vscode.lua` with `cond = vim.g.vscode`.

For Neovim-only plugins, use the existing plugin files with implicit VSCode exclusion.
