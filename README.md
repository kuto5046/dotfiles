# dotfiles
現在はxonsh, zsh, neovim, tmux, weztermのdotfilesを管理

## Install
1. レポジトリをcloneする
```sh
git clone https://github.com/jdx/mise.git
```
```

```
2. インストール

- zsh
- git
- tmux
- mise
https://github.com/jdx/mise
下記で各種ツールがインストールされる
```
mise trust
mise install
```

- ripgrep(https://github.com/BurntSushi/ripgrep)
- git-graph(https://github.com/git-bahn/git-graph)


3. nvimのpluginのinstall

パッケージマネージャはlazy.nvimを使用
```vim
# neovimを起動して以下のコマンドを入力
:Lazy
```

4. linter, formatterのインストール
masonを使って必要なものをインストールする
以下をvim上で実行するとインストール可能な一覧が確認できる
```vim
:Mason
```

5. .envの読み込み
.envにAPI KEYを管理している。以下を実行することで環境変数にAPI_KEYを読み込む。neovimのavante.nvimでclaudeやchat-gptを使う場合に必要。
```bash
set -a
source .env
set +a
```

