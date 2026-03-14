# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

- **nvim** - Neovim configuration
- **tmux** - Tmux configuration
- **zsh** - Zsh configuration
- **gh** - GitHub CLI configuration
- **Brewfile** - Homebrew package list

## Installation

### Prerequisites

Ensure you have GNU Stow installed:

```bash
brew install stow
```

Clone this repository to your home directory or a dedicated location:

```bash
git clone https://github.com/gugahoi/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### Setup

Use Stow to create symlinks for configuration files:

```bash
# Stow all packages
stow .

# Or stow individual packages
stow nvim
stow tmux
stow zsh
```

This will create symlinks from the repository files to their target locations in your home directory (e.g., `.config/nvim`, `.zshrc`, etc.).

## Managing Files

### Add a New Configuration

1. Place the configuration file in the appropriate directory structure within this repository
2. Run `stow <package-name>` to create symlinks
3. Commit your changes:

```bash
git add .
git commit -m "Add/update <package> configuration"
git push
```

### Update an Existing Configuration

Since the files are symlinked, changes made in `~/.config` or `~/.<file>` will directly modify the files in this repository. Simply commit your changes:

```bash
git add .
git commit -m "Update <package> configuration"
git push
```

### Remove a Configuration

If you no longer want a package symlinked:

```bash
stow -D <package-name>
```

This removes the symlinks without deleting the files from the repository.

## How Stow Works

Stow uses a simple structure:
- Files in this repository should mirror the directory structure of your home directory
- When you run `stow`, it creates symlinks from the repo to your home directory
- For example: `dotfiles/.config/nvim/init.lua` → `~/.config/nvim/init.lua`

## Dotfiles Directory Structure

```
dotfiles/
├── .config/
│   ├── nvim/          # Neovim config
│   └── gh/            # GitHub CLI config
├── .tmux.conf         # Tmux configuration
├── .zshrc             # Zsh configuration
├── .gitconfig         # Git configuration
├── Brewfile           # Homebrew packages
└── README.md
```

## Useful Stow Commands

```bash
# Simulate stowing without creating symlinks (dry-run)
stow -n .

# Show what stow would do
stow -v .

# Unstow a package
stow -D nvim

# Restow (remove and recreate symlinks)
stow -R .

# Adopt existing files into the stow directory
stow -a nvim
```

## Troubleshooting

### Symlink conflicts

If Stow reports conflicts, it means files already exist in your home directory that conflict with the symlinks. You can:

1. Delete the existing file if it's redundant
2. Manually merge the content if needed
3. Use `stow --adopt` to move existing files into the stow directory

### Checking current symlinks

```bash
# See what's currently symlinked
ls -la ~/.config/nvim
ls -la ~/.zshrc
```

## Notes

- Keep your dotfiles in version control for easy backup and portability
- Test changes on a new system or in a virtual environment first
- Some applications may cache configs; restart them to see changes take effect
