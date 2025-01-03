# 人類最低限zshrc
autoload -U compinit; compinit
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt histignorealldups
setopt always_last_prompt
setopt complete_in_word
setopt IGNOREEOF

export LANG=ja_JP.UTF-8
export LC_CTYPE=ja_JP.UTF-8

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
export PATH="$HOME/.local/bin:$PATH"

# xonsh起動
alias x='xonsh'

# .envの仮想環境を読み込む
alias dotenv="set -a && source ~/.env && set +a"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/kyohei.uto/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/kyohei.uto/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/kyohei.uto/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/kyohei.uto/google-cloud-sdk/completion.zsh.inc'; fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"


# gcp
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# rust
export PATH="/usr/local/go/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# cuda
# export PATH = /usr/local/cuda-11.8/bin
# export LD_LIBRARY_PATH = /usr/local/cuda-11.8/lib64

# wezterm
export PATH="/Applications/WezTerm.app/Contents/MacOS:$PATH"

# rye
source "$HOME/.rye/env"

# nodebrew
export PATH="$HOME/.nodebrew/current/bin:$PATH"


export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

. "$HOME/.cargo/env"

# tmux内でitalicに謎のhighlightがかかる問題の対処
# https://gist.github.com/gyribeiro/4192af1aced7a1b555df06bd3781a722
alias tmux="env TERM=screen-256color tmux"