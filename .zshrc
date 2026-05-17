#!/usr/local/bin zsh

# check_and_source sources a file if the check passes
check_and_source() {
    test -e "$1" && source "$1"
}

load_nvm() {
    unset -f nvm node npm npx
    export NVM_DIR="$HOME/.nvm"

    [ -s "$BREW_PREFIX/opt/nvm/nvm.sh" ] && source "$BREW_PREFIX/opt/nvm/nvm.sh"
    [ -s "$BREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && source "$BREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
}

# completion setups up cmd completion for a given tool if it is installed
completion(){
    if type "$1" &>/dev/null; then
        local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
        local cache_file="$cache_dir/$1.zsh"

        if [[ ! -s "$cache_file" || "$cache_file" -ot "$(command -v "$1")" ]]; then
            mkdir -p "$cache_dir"
            eval "$2" >| "$cache_file"
        fi

        source "$cache_file"
    fi
}

check_and_source "${HOME}/.aliases"
# source "${HOME}/.functions"
check_and_source "${HOME}/.exports"
check_and_source "${HOME}/.cargo/env"
check_and_source "${HOME}/.deno/env"

# enable vi mode
bindkey -v
# bindkey -e

# delete keys fix for vi mode
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char

bindkey "^P" up-line-or-search
bindkey "^N" down-line-or-search

# Edit the current command line in $EDITOR with Ctrl-X Ctrl-E / Ctrl-X E
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M emacs '^Xe' edit-command-line
bindkey -M viins '^Xe' edit-command-line
bindkey -M vicmd '^Xe' edit-command-line

if type brew &>/dev/null; then
    BREW_PREFIX="$(brew --prefix)"
    export FPATH="$BREW_PREFIX/share/zsh/site-functions:$BREW_PREFIX/share/zsh-completions:${FPATH}"
    autoload -Uz compinit
    compinit

    check_and_source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    check_and_source "$BREW_PREFIX/share/google-cloud-sdk/path.zsh.inc"
    check_and_source "$BREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"
    check_and_source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

    if [ -s "$BREW_PREFIX/opt/nvm/nvm.sh" ]; then
        nvm() { load_nvm; nvm "$@"; }
        node() { load_nvm; node "$@"; }
        npm() { load_nvm; npm "$@"; }
        npx() { load_nvm; npx "$@"; }
    fi
fi

completion "jj" "jj util completion zsh"
completion "docker" "docker completion zsh"
completion "pnpm" "pnpm completion zsh"
completion "basiq" "basiq completion zsh"
completion "firestore" "firestore completion zsh"
completion "opencode" "opencode completion zsh"
completion "op" "op completion zsh" # 1Password CLI
completion "fzf" "fzf --zsh"
completion "exercisom" "exercisom completion zsh"

eval "$(/opt/homebrew/bin/brew shellenv)"

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi


# pure prompt
autoload -U promptinit
promptinit
prompt pure


if command -v -- bun >/dev/null 2>&1; then
    # bun
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"

    # bun completions
    check_and_source "${HOME}/.bun/_bun"
fi

if command -v -- go >/dev/null 2>&1; then
    # GOPATH
    export GOPATH=~/.go
    export GO111MODULE=on
    export PATH="$GOPATH/bin:$PATH"
fi

eval "$(zoxide init zsh)"

if command -v -- sesh >/dev/null 2>&1; then
    # Bind <M-f> to run Sesh from zsh shell
    function sesh-sessions() {
        {
            exec </dev/tty
            exec <&1
            local session
            session=$(sesh list --icons | fzf \
                    --no-sort --ansi \
                    --border-label ' sesh ' \
                    --border \
                    --prompt '⚡  ' \
                    --height 70% \
                    --header '  ^a all  ^t tmux  ^g configs  ^x zoxide  ^d kill  ^f find' \
                    --bind 'tab:down,btab:up' \
                    --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
                    --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
                    --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
                    --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
                    --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
                    --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
                    --preview-window 'right:55%' \
                --preview 'sesh preview {}')
            zle reset-prompt > /dev/null 2>&1 || true
            [[ -z "$session" ]] && return
            sesh connect $session
        }
    }

    zle     -N             sesh-sessions
    bindkey -M emacs '^[f' sesh-sessions
    bindkey -M vicmd '^[f' sesh-sessions
    bindkey -M viins '^[f' sesh-sessions
fi


# pnpm
if command -v -- pnpm >/dev/null 2>&1; then
    export PNPM_HOME="/Users/guga/Library/pnpm"
    case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
fi
# pnpm end

if command -v -- bob >/dev/null 2>&1; then
    export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
fi

if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
    export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
fi

export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
