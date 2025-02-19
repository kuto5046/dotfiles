# dotfiles
現在はxonsh, zsh, neovim, tmux, weztermのdotfilesを管理

## Install

1. 事前インストール

weztermのインストール  
https://wezfurlong.org/wezterm/installation.html

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

# neovim v0.9.1
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
sudo mv squashfs-root /
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
```

2. レポジトリをcloneする
```sh
git clone <this repository>
```

3. 各種インストール

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

5. nvimのpluginのinstall

パッケージマネージャはlazy.nvimを使用
```vim
# neovimを起動して以下のコマンドを入力
:Lazy
```

6. linter, formatterのインストール
masonを使って必要なものをインストールする
以下をvim上で実行するとインストール可能な一覧が確認できる
```vim
:Mason
```

7. .envの読み込み
.envにAPI KEYを管理している。以下を実行することで環境変数にAPI_KEYを読み込む。neovimのavante.nvimでclaudeやchat-gptを使う場合に必要。
```bash
set -a
source .env
set +a
```

## neovimの覚えておきたいkeymapやcommand

command
```
// TODOの一覧をtelescopeで表示する
:TodoTelescope
```
