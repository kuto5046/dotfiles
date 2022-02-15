# dotfiles
現在はgit, xonsh, zsh, neovim, tmuxのdotfilesを管理

## Install

1. xonsh, zsh, neovim, git, tmuxはあらかじめインストールしておく 
細かい点が違うかも
neovimは以下の方法だと古いversionしかインストールできなかった気がする
また環境設定する際に追記する

Macの場合
```
brew install xonsh zsh git tmux neovim
```

Ubuntuの場合
```
sudo apt update
sudo apt install xonsh zsh git tmux neovim
```

ここも自動化できるのならしたいところ

2. レポジトリをcloneする
```
$ git clone <this repository>
```

3. 各種設定をインストール
```
$ bash dotfiles/.bin/install.sh
```
これで完了。

ターミナル上にcolorschemeを反映させるためには別途必要かも
ubuntuには勝手にnordが反映された。
MacのTerminalやiterms2を使う場合はnordをgitからcloneして設定する。

https://github.com/arcticicestudio/nord-terminal-app  
https://github.com/arcticicestudio/nord-iterm2 
