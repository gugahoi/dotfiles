#!/usr/bin/env bash
# Bootstrap these dotfiles on a fresh macOS machine.
# Idempotent: safe to re-run. See README.md for details.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# 1. Homebrew (also pulls Xcode Command Line Tools if missing).
if ! command -v brew >/dev/null 2>&1; then
    echo "==> Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Put brew on PATH for the rest of this script (Apple Silicon vs Intel).
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# 2. Everything in the Brewfile (installs stow, among others).
echo "==> brew bundle"
brew bundle --file="$DOTFILES_DIR/Brewfile"

# 3. Symlink the dotfiles into $HOME.
echo "==> stow"
stow -t ~ .

# 4. Tmux Plugin Manager + the @plugin entries in .tmux.conf. Must run after
#    stow: TPM reads ~/.tmux.conf, and ~/.tmux is a stowed symlink.
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
    echo "==> Installing TPM"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Skips plugins that are already installed. Runs against a throwaway tmux
# server (own socket dir, TMUX unset), so it always reads the freshly stowed
# config and never touches a tmux session you're running this from.
echo "==> tmux plugins"
TPM_SOCKET_DIR="$(mktemp -d)"
trap 'rm -rf "$TPM_SOCKET_DIR"' EXIT
(
    unset TMUX
    export TMUX_TMPDIR="$TPM_SOCKET_DIR"
    "$TPM_DIR/bin/install_plugins"
)

echo "==> Done. Restart your shell (or 'exec zsh')."
echo "    Optional: run 'focus-blocker setup' to enable the Focus blocker (needs sudo)."
