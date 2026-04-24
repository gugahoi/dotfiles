#!/usr/local/bin zsh

# check_and_source sources a file if the check passes
check_and_source() {
    test -e "$1" && source "$1"
}

# completion setups up cmd completion for a given tool if it is installed
completion(){
    if type "$1" &>/dev/null; then
        source <(eval "$2")
    fi
}


check_and_source "${HOME}/.aliases"
# source "${HOME}/.functions"
check_and_source "${HOME}/.exports"
check_and_source "${HOME}/.cargo/env"
check_and_source "${HOME}/.deno/env"


if type brew &>/dev/null; then
    export FPATH="$(brew --prefix)/share/zsh/site-functions:$(brew --prefix)/share/zsh-completions:${FPATH}"
    autoload -Uz compinit
    compinit

    check_and_source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    check_and_source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
    check_and_source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

    check_and_source "$(brew --prefix)/opt/nvm/nvm.sh"
    check_and_source "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"
fi

completion "jj" "jj util completion zsh"
completion "docker" "docker completion zsh"
completion "pnpm" "pnpm completion zsh"
completion "basiq" "basiq completion zsh"
completion "firestore" "firestore -p fake completion zsh"
completion "opencode" "opencode completion zsh"
completion "op" "op completion zsh" # 1Password CLI
completion "fzf" "fzf --zsh"
completion "exercisom" "exercisom completion zsh"

# enable vi mode
bindkey -v

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

if command -v -- go >/dev/null 2&>1; then
    # GOPATH
    export GOPATH=~/.go
    export GO111MODULE=on
    export PATH="$GOPATH/bin:$PATH"
fi


# if command is available, source the completion
# eg.: if fzf is available, source <(fzf --zsh)
# completion "fzf" "fzf --zsh"
function completion ()
{
    local binary="$1"
    shift || return 1

    [[ -n "$binary" && $# -gt 0 ]] || return 1
    command -v -- "$binary" > /dev/null 2>&1 || return 0

    local generator="$*"
    source <(eval "$generator")
}

eval "$(zoxide init zsh)"

if command -v -- sesh >/dev/null 2>&1; then
    # Bind <C-s> to run Sesh from zsh shell
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
    bindkey -M emacs '^s' sesh-sessions
    bindkey -M vicmd '^s' sesh-sessions
    bindkey -M viins '^s' sesh-sessions
fi


if command -v -- nvm >/dev/null 2>&1; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
    export PATH="$NVM_BIN:/opt/homebrew/bin:$PATH"
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

export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
