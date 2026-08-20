#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
[[ -s "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

[[ -s "/home/vnkjd/.gvm/scripts/gvm" ]] && source "/home/vnkjd/.gvm/scripts/gvm"

# PATH
export GOPATH="$HOME/go"
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$GOPATH/bin:$PATH"

. "$HOME/.uv/bin/env"
