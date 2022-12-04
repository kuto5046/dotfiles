# dotfiles
現在はgit, xonsh, zsh, neovim, tmuxのdotfilesを管理

## Install

1. 事前インストール
xonsh, zsh, neovim, git, tmuxをインストールする

Macの場合
```
brew install xonsh zsh git tmux neovim
```

Ubuntuの場合
```
sudo apt update
sudo apt install xonsh zsh git tmux neovim
```

2. レポジトリをcloneする
```
$ git clone <this repository>
```

3. 各種インストール

- ターミナル上にcolorschemeを反映

ubuntuの場合
https://github.com/arcticicestudio/nord-gnome-terminal

Macの場合
https://github.com/arcticicestudio/nord-terminal-app
https://github.com/arcticicestudio/nord-iterm2

- neovim用のiconを反映させるためのpatch fontのインストール
Macの場合
```
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font
cd ~/Library/Fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
```
iterm2でprofiles->text-> Non-ASCII FontでDroid Sans ..を指定

- neovimのtelescopeでtext検索するためにripgrepをインストール

```
# for mac
brew install ripgrep

# for ubuntu
sudo apt install ripgrep
```

4. dotfilesを反映
```
$ bash dotfiles/.bin/install.sh
```
これで完了。
