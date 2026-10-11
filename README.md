# dotfiles
現在はxonsh, zsh, neovim, tmux, weztermのdotfilesを管理

## Skills

個人用 skill は、隣の専用リポジトリ `../skills` と
Vercel の `skills` CLI で管理しています。
新しい編集元は専用リポジトリの `skills/<name>/` です。
会社固有の skill は別の会社用リポジトリで管理します。

```sh
cd ../skills
npm ci
npm run skills:install  # グローバル導入・ローカル変更の再導入
npm run skills:list
```

個人用の8個の skill は `~/.agents/skills/` と Claude Code 側のリンクで共有します。
詳しい編集・追加手順は専用リポジトリの README を参照してください。
専用リポジトリ: [kuto5046/skills](https://github.com/kuto5046/skills)（非公開）。
新しい PC では、この dotfiles の隣に専用リポジトリを clone してから上記を実行します。

```sh
git clone git@github.com:kuto5046/skills.git ../skills
```

導入物は dotfiles の Git 管理から除外しています。
旧 `skills/` 本体、`.codex/skills/` の互換リンク、独自管理スクリプトは整理済みです。

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

