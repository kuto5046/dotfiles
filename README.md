# dotfiles
現在はgit, xonsh, zsh, neovimのdotfilesを管理

## Install

1. xonsh, zsh, neovim, gitはあらかじめインストールしておく  
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
