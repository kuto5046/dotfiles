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

- neovim関連のインストール

```
# for mac
# telescopeでtext検索するためのripgrep
$ brew install ripgrep

# gitのUI
$ brew install jesseduffield/lazygit/lazygit
$ brew install lazygit

```

```
# for ubuntu
$ sudo apt install ripgrep

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' |  sed -E 's/.*"v*([^"]+)".*/\1/')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
sudo tar xf lazygit.tar.gz -C /usr/local/bin lazygit
```

4. dotfilesを反映
```
$ bash dotfiles/.bin/install.sh
```
これで完了。
