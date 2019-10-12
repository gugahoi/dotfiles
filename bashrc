#!/usr/bin/env bash

source ~/.{aliases,functions,exports}

export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTIGNORE="ls:ps:history:ll:tig:gst"
export HISTCONTROL=ignoreboth
PROMPT_COMMAND='history -a'

# GOPATH
export GOPATH=~/.go
export GO111MODULE=on
export PATH="$GOPATH/bin:$PATH"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/usr/local/bin/google-cloud-sdk/path.zsh.inc' ]; then source '/usr/local/bin/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/usr/local/bin/google-cloud-sdk/completion.zsh.inc' ]; then source '/usr/local/bin/google-cloud-sdk/completion.zsh.inc'; fi

# z cli
[ -f /usr/local/etc/profile.d/z.sh ] && . /usr/local/etc/profile.d/z.sh

# autocompletion for homebrew
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="\[\033[32m\]\u:\[\033[1;33m\]\w\[\033[36m\]\$(parse_git_branch)\[\033[0m\] > "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# heroku autocomplete setup
HEROKU_AC_BASH_SETUP_PATH=/Users/gus/Library/Caches/heroku/autocomplete/bash_setup && test -f $HEROKU_AC_BASH_SETUP_PATH && source $HEROKU_AC_BASH_SETUP_PATH;

# This loads nvm
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# Setting fd as the default source for fzf
export FZF_DEFAULT_COMMAND='fd --type f'
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
