# 単一 HTML の数式組版

構造を持つ数式は、KaTeX で生成時に組版する。`<sup>` / `<sub>` は文章中の単位などには使えるが、上付きと下付きの同時配置や分数には使わない。

## 生成と出力

`scripts/render_math.mjs` は `renderToString` の HTML + MathML 出力を使い、KaTeX の CSS・WOFF2 フォント・ライセンス表記を完成 HTML に埋め込む。閲覧時の外部通信と数式 JS は不要。MathML は読み上げ用に残し、数式を画像にはしない。

既存の KaTeX があれば使う。なければ作業用ディレクトリに用意する。依存をプロジェクトや生成物に追加する必要はない。

```sh
math_tools_dir=$(mktemp -d)
npm install --prefix "$math_tools_dir" --no-save --ignore-scripts --no-audit --no-fund katex@0.16.25
node "<このスキルのディレクトリ>/scripts/render_math.mjs" draft.html page.html \
  --katex-dir "$math_tools_dir/node_modules/katex"
python3 "<このスキルのディレクトリ>/scripts/check_html.py" page.html
```

0.16.25 は検証済みの版。互換性のある既存インストールを置き換える必要はない。インストールできない環境では native MathML を代案にできるが、実際の閲覧環境で見た目を確認する。

## 下書きの記法

数式だけを inert な `script` 要素に入れる。インラインは `type="math/tex"`、独立した式は `type="math/tex; mode=display"`。TeX は HTML エンティティに変換せず、そのまま書く。本文やコードの `$` は走査しないため、金額などを誤変換しない。

```html
<div class="equation" data-review-id="context-transition">
  <script type="math/tex; mode=display">
    c_{t+1} = c_t \oplus f_{\theta}^{\mathrm{LM}}(c_t)
  </script>
</div>
<p><script type="math/tex">c_t</script> は現在のコンテキスト。</p>
```

共有するのは組版後の `page.html`。プレースホルダは置換されるので、review ID は外側の要素に付ける。再生成は下書きから行う。スクリプトは既存の出力を上書きせず、組版済み入力の再処理も拒否する。意図した古い出力を退避するか、別の出力名を選ぶ。解釈できない TeX は生成を止めるので、誤記を修正してから出力する。

## 見た目と数式の意味

- 変数は数式の既定の斜体を使う。名称の添字は `\mathrm{eff}` / `\mathrm{out}`、モデル名は `\mathrm{LM}` / `\mathrm{CLM}`、演算子は `\operatorname{clip}` と書く。
- 分数は `\frac{...}{...}`、上線は `\bar{c}_g`、同時に付く添字は `f_{\theta}^{\mathrm{CLM}}` とする。
- 日本語の長い注釈や条件は、数式の近くの通常の HTML に置く。場合分けを持つ式では条件との対応を保持する。
- `.equation` の色や余白は資料のトークンで決める。組版スクリプトは数式の配置だけを補い、資料全体のテーマを決めない。KaTeX 内部の配置・フォント・行高は上書きしない。
- 長い式は `aligned` や別の display ブロックを使って意味のある箇所で分ける。過剰な縮小やページ全体の横スクロールを避ける。

## 確認

スクリーンショット・印刷前に `document.fonts.ready` を待つ。デスクトップ・スマホ幅・印刷表示で分数、上線、上付きと下付き、括弧、演算子の間隔を見る。TeX プレースホルダが残っていないこと、数式のエラーがないこと、外部フォント通信なしで表示できることも確認する。数式の意味を変える修正は、根拠を確認してから行う。

一次資料: [KaTeX の Node.js 出力](https://katex.org/docs/node)、[出力オプション](https://katex.org/docs/options)、[CSS とフォント](https://katex.org/docs/browser)。
