# Read by every zsh, including the non-interactive login shells that Rex and
# other tools launch commands through, which never read .zshrc. Keep env vars
# that those commands need (e.g. PI_CODING_AGENT_DIR) in .exports.
[[ -r "$HOME/.exports" ]] && source "$HOME/.exports"
