# dotfiles
現在はgit, xonsh, zsh, neovim, tmuxのdotfilesを管理

## Install

1. 事前インストール
xonsh, zsh, neovim, git, tmuxをインストールする

Macの場合
```sh
brew install xonsh zsh git tmux neovim
```

Ubuntuの場合
```sh
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt install xonsh zsh git tmux

# 以下のappimageを利用した方法でできる
# https://github.com/neovim/neovim/wiki/Installing-Neovim#appimage-universal-linux-package
```

2. レポジトリをcloneする
```sh
git clone <this repository>
```

3. 各種インストール

- ターミナル上にcolorschemeを反映

ubuntuの場合
https://github.com/arcticicestudio/nord-gnome-terminal

Macの場合
https://github.com/arcticicestudio/nord-terminal-app
https://github.com/arcticicestudio/nord-iterm2

- neovim用のiconを反映させるためのpatch fontのインストール
```sh
# for mac
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font
cd ~/Library/Fonts && curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf
```
iterm2でprofiles->text-> Non-ASCII FontでDroid Sans ..を指定

- neovim関連のインストール

telescopeでtext検索するためのripgrep
```sh
# for mac
brew install ripgrep

# for ubuntu
sudo apt install ripgrep
```

4. dotfilesを反映
```sh
bash dotfiles/.bin/install.sh
```

5. nvimのpluginのcompile
```sh
nvim dotfiles/.config/nvim/lua/plugins.lua
```

```vim
# 設定の読み込み(自動でpackerがinstallされる)
:so

# plugin install
:PackerInstall

# pluginの変更反映
:PackerSync
```



6. linter, formatterのインストール
masonを使って必要なものをインストールする
以下をvim上で実行するとインストール可能な一覧が確認できる
```vim
:Mason
```

これで完了。

