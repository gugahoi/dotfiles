# Neovim Configuration

A modern Neovim setup using [nightly Neovim](https://github.com/neovim/neovim) and [vim.pack](https://neovim.io/doc/user/packages.html) for package management.

## Requirements

- **Neovim**: Nightly build (latest development version)
- **Node.js**: Required for LSP and some plugin functionality
- **Git**: For plugin installation and management

## Installation

1. Clone this repository to your Neovim config directory:
```bash
git clone <repository-url> ~/.config/nvim
```

2. Start Neovim. Plugins will be automatically loaded via vim.pack.

3. Install language servers via Mason:
```vim
:Mason
```

## Project Structure

```
~/.config/nvim/
├── init.lua                 # Entry point
├── nvim-pack-lock.json      # Locked plugin versions
├── stylua.toml              # Code formatting config
├── lua/
│   ├── config/              # Core configuration
│   │   ├── options.lua      # Neovim settings
│   │   ├── keymaps.lua      # Key bindings
│   │   ├── diagnostics.lua  # Diagnostic settings
│   │   └── init.lua         # Config entry point
│   └── plugins/             # Plugin configurations
│       ├── lsp.lua          # Language server setup
│       ├── treesitter.lua   # Syntax highlighting
│       ├── format.lua       # Code formatting
│       ├── theme.lua        # Color scheme
│       ├── git.lua          # Git integration
│       ├── picker.lua       # Fuzzy finder
│       ├── tmux.lua         # Tmux navigation
│       ├── amp.lua          # Amp.nvim configuration
│       └── init.lua         # Plugin registry
└── ftdetect/                # Filetype detection
```

## Key Plugins

### Productivity
- **amp.nvim** - Sourcegraph Amp integration
- **blink.cmp** - Fast completion engine
- **conform.nvim** - Code formatting
- **snacks.nvim** - Utilities and UI enhancements
- **todo-comments.nvim** - Highlight and manage TODOs

### Development
- **nvim-lspconfig** - LSP configuration
- **mason.nvim** - Language server installer
- **mason-lspconfig.nvim** - Mason + LSP bridge
- **nvim-treesitter** - Advanced syntax highlighting
- **nvim-treesitter-textobjects** - Syntax-aware text objects

### Navigation
- **vim-tmux-navigator** - Seamless Tmux integration
- **fff.nvim** - File explorer
- **neogit** - Git client

### Appearance
- **cyberdream.nvim** - Modern color scheme
- **gitsigns.nvim** - Git decorations

## Configuration

### Managing Plugins

Plugins are managed through `nvim-pack-lock.json`. To update:

1. Add or remove plugins in `pack/plugins/opt/` or `pack/plugins/start/`
2. Update `nvim-pack-lock.json` with the desired revision

### Key Bindings

Leader key is configured as `<Space>`. View keymaps in `lua/config/keymaps.lua`.

### LSP Configuration

Language servers are installed and configured in `lua/plugins/lsp.lua`. Use `:Mason` to install additional servers.

### Formatting

Code formatting is handled by `conform.nvim`. Configure formatters in `lua/plugins/format.lua`.

## Development Workflow

- **Completion**: Blink.cmp provides intelligent completions
- **Diagnostics**: Real-time error checking with integrated LSP
- **Git Integration**: Neogit for git operations, gitsigns for inline git info
- **Testing**: Use your preferred test runner configured in keymaps

## Troubleshooting

### Plugins not loading
- Ensure plugins are in `pack/plugins/start/` or `pack/plugins/opt/`
- Check `:PlugStatus` for plugin status

### LSP not working
- Run `:Mason` and install the required language server
- Check `:LspInfo` for LSP status
- Review `lua/plugins/lsp.lua` for server configuration

### Performance issues
- Check startup time with `:StartupTime`
- Review lazy-loading configuration in `lua/plugins/init.lua`

## License

See the repository for license information.
