# sheldon
eval "$(sheldon source)"

####################
# シェル設定
####################
# 新しく入れたコマンドを即認識する
zstyle ":completion:*:commands" rehash 1

# 色を有効化
autoload -Uz colors && colors

# https://qiita.com/maejimayuto/items/01216e6255c156fa7bf4
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'    # 補完候補で、大文字・小文字を区別しないで補完出来るようにするが、大文字を入力した場合は区別する
zstyle ':completion:*' ignore-parents parent pwd ..    # ../ の後は今いるディレクトリを補間しない
zstyle ':completion:*:default' menu select=1           # 補間候補一覧上で移動できるように
zstyle ':completion:*:cd:*' ignore-parents parent pwd  # 補間候補にカレントディレクトリは含めない

# 補完候補が多い場合の制御
LISTMAX=30                                              # 30個以上候補がある場合は確認を求める
zstyle ':completion:*' list-max-items 100               # 最大100個まで候補を表示
zstyle ':completion:*' use-cache true                   # 補完をキャッシュして高速化
zstyle ':completion:*' cache-path ~/.zsh/cache          # キャッシュファイルの保存先

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# setopt share_history           # 履歴を他のシェルとリアルタイム共有する
setopt hist_ignore_all_dups    # 同じコマンドをhistoryに残さない
setopt hist_ignore_space       # historyに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks      # historyに保存するときに余分なスペースを削除する
setopt hist_save_no_dups       # 重複するコマンドが保存されるとき、古い方を削除する
setopt inc_append_history      # 実行時に履歴をファイルにに追加していく
setopt auto_cd                 # cdコマンドを省略してディレクトリに移動できるようにする

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end

if [ -e /usr/local/share/zsh-completions ]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
fi

autoload -Uz compinit
compinit -u

####################
# 環境変数
####################
export LANG=ja_JP.UTF-8
export LC_CTYPE=ja_JP.UTF-8

# poetry
export PATH="$HOME/.local/bin:$PATH"

# gcloud
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$PYENV_ROOT/shims:$PATH"
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
# nodebrew
export PATH="$HOME/.nodebrew/current/bin:$PATH"

####################
# エイリアス
####################
# .envの仮想環境を読み込む
alias dotenv="set -a && source ~/.env && set +a"

# tmuxでよく使うペイン構成を作成
alias ide="bash ~/.script/ide.sh"

# ghqリポジトリをfzfで選択してtmuxセッションを開く
export PATH="$HOME/ghq/github.com/kuto5046/dotfiles/.bin:$PATH"


####################
# 勝手に追加されるもの
####################

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(direnv hook zsh)"

# mise
eval "$(mise activate zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/kyohei.uto.002/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/kyohei.uto.002/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/kyohei.uto.002/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/kyohei.uto.002/google-cloud-sdk/completion.zsh.inc'; fi
# opencode
export PATH=~/.opencode/bin:$PATH

export AQUA_GLOBAL_CONFIG="/Users/kyohei.uto.002/.config/aquaproj-aqua/aqua.yaml"

export PATH="$(aqua root-dir)/bin:$PATH"

export NPM_CONFIG_PREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/npm-global"

export PATH=$NPM_CONFIG_PREFIX/bin:$PATH

# Start ssh-agent automatically
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_ed25519 2> /dev/null
fi
