# 人類最低限zshrc
# autoload -U compinit; compinit
# setopt auto_cd
# setopt auto_pushd
# setopt pushd_ignore_dups
# setopt histignorealldups
# setopt always_last_prompt
# setopt complete_in_word
# setopt IGNOREEOF

export LANG=ja_JP.UTF-8
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
autoload -Uz colors

# colors
# alias l='ls -ltr --color=auto'
# alias ls='ls --color=auto'
# alias la='ls -la --color=auto'
PROMPT="%(?.%{${fg[red]}%}.%{${fg[red]}%})%n${reset_color}@${fg[blue]}%m${reset_color} %~ %# "

# vim
export VISUAL='/usr/local/bin/vim'

# poetry
source $HOME/.poetry/env

# xonsh起動
alias x='xonsh'
# x



# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/kyohei.uto/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/kyohei.uto/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/kyohei.uto/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/kyohei.uto/google-cloud-sdk/completion.zsh.inc'; fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# export PATH="$HOME/.poetry/bin:$PATH"

export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"

export PATH="$HOME/.poetry/bin:$PATH"
