# デザインの詳細

`SKILL.md` の判断の理由と、CSS・SVG の書き方。`assets/template.html` に実体がある。

## トークン

```css
/* レイアウト: 1 カラムの読み物。決まったこと → 前提 → 本体（部ごと）→ 持ち越した論点 */
:root{
  --bg:#f4f5f3; --surface:#ffffff; --fg:#1c2220; --muted:#5a6560; --line:#d5dbd7; --accent:#2c4a86;
  --ok:#2e7a4f; --idea:#2f6d9c; --hot:#b3306e; --later:#6b7480;   /* 状態 */
  --z1:#2f6d9c; --z2:#6a4f9e; --z3:#9a6227; --z4:#4b5560;          /* 登場人物・領域 */
  --tint:8%;
  --f-display:"Zen Kaku Gothic New","Hiragino Sans","Yu Gothic",sans-serif;
  --f-body:"BIZ UDPGothic","Hiragino Sans","Yu Gothic",sans-serif;
  --f-mono:"IBM Plex Mono",ui-monospace,Menlo,monospace;
}
```

- 背景 `#f4f5f3` は緑みをわずかに帯びた中間色。純粋な灰色より意図して選んだ色に見える。題材に合わせて色味を変えてよい。
- ダークの値は `@media (prefers-color-scheme: dark){:root:not([data-theme="light"]){…}}` と `:root[data-theme="dark"]{…}` に同じものを書き、両方に `color-scheme:dark` を付ける。片方だけだと、OS 設定かテーマ切り替えのどちらかに追従しない。色を `:root` 以外にしか定義しないと、片方のテーマで文字が読めなくなる。
- ダークでは淡色の塗りが沈むので `--tint` を 8% → 14% に上げる。
- 淡い塗りは `color-mix(in srgb, var(--z1) var(--tint), var(--surface))` で作る。トークン 1 つからライト・ダーク両方の淡色が出る。

## 書体

- 見出し: Zen Kaku Gothic New 700。和文ゴシックだが字形に表情があり、見出しだけで紙面の印象が決まる。
- 本文: BIZ UDPGothic 400/700。可読性重視の UD 書体で、長文と表で崩れない。15px・行間 1.8。
- 補助: IBM Plex Mono。eyebrow（`決算仕訳エージェント · … · 2026-10-05`）、部の番号、図番号に使う。字間を少し開ける。
- 読み物なら見出しに明朝（Shippori Mincho B1 / Zen Old Mincho）、硬い技術ノートなら IBM Plex Sans JP に替えてよい。替えても 3 役は守る。
- 見出しに `text-wrap: balance`、本文の幅は `max-width: 72ch`。

## レイアウト

- 外側の `.wrap` に `max-width:1080px; padding-inline:20px; padding-block:…`。左右の余白は `padding` の一括指定で潰さない。560px 以下では 16px。
- 兄弟要素の間隔は `display:flex/grid` と `gap` で取る。要素ごとの margin は使わない。
- カードの並びは `grid-template-columns:repeat(auto-fit,minmax(300px,1fr))`。狭い画面では 1 列になる。文字を含む子要素には `min-width:0`。
- ページ全体を横スクロールさせない。表は `.tbl{overflow-x:auto}` + `table{min-width:760px}`、図は `.fig-scroll{overflow-x:auto}` + `svg{min-width:…}` で、それぞれの中だけスクロールさせる。

## 部品

| 部品 | 役割 |
|---|---|
| `.eyebrow` | ページの所属と日付。等幅の小さい文字 |
| `.legend` + `.tag` | 状態の札と凡例。`.t-ok` `.t-idea` `.t-hot` `.t-later` |
| `nav.toc` + `.toc-row` | 部ごとに 1 行の目次。行頭に `.toc-k`（部の名前） |
| `.decisions` + `.dc` | 決まったことのカード。見出しの先頭に札 |
| `.part` | 第1部・第2部の区切り。アクセントの淡色で塗った帯 |
| `.stickies` + `.st` | 前提・目的・スコープなどの付箋 |
| `.tbl table.w` | 比較・一覧の表。状態の列は `td.c`（折り返さない） |
| `.fig` + `.figh` + `figcaption` | 図の枠、段の小見出し、キャプション |
| `.steps` | 番号つきの手順カード。`li.u` はユーザー、`li.a` はエージェント |
| `.two` + `.box` | 2 案の比較や「〜のとき / 〜のとき」の対比 |
| `.points` | 補足の箇条。左線の色で状態（`.ok` `.idea` `.hot`）を表す |

## SVG のクラス

```css
.d .zn{fill:color-mix(in srgb,var(--zc) var(--tint),var(--surface));stroke:color-mix(in srgb,var(--zc) 45%,transparent)}
.d .zl{fill:var(--zc);font-family:var(--f-display);font-weight:700;font-size:12.5px}   /* 帯のラベル */
.d .bx{fill:var(--surface);stroke:color-mix(in srgb,var(--fg) 30%,transparent)}       /* 箱 */
.d .bx.dash / .hot / .ok / .lean / .mute                                               /* 補足・人の手・到達点・採用・見送り */
.d .ar{stroke:var(--muted);stroke-width:1.4;fill:none}  .d .ar.dash{stroke-dasharray:4 4}
.d .al{…;paint-order:stroke;stroke:var(--surface);stroke-width:3px}                    /* 線に重ねても読めるラベル */
```

帯の色は `class="zn z1"` のように `--zc` を切り替えて付ける。

## レーン図の座標の決め方

- viewBox は幅 1240 程度。左 0〜80 を帯のラベル用に空ける。
- 箱は幅 140、列のピッチ 166（列 k の x = 84 + 166k）。隙間の中央は x = 列の x + 153。
- ユーザー帯の箱は y=30・高さ 80、エージェント帯の箱は y=160・高さ 72。
- 帯をまたぐ矢印: 箱の右辺中央から隙間の中央まで水平 → 垂直 → 次の箱の左辺へ水平（`M556,196 H569 V70 H581`）。
- 分岐: 判定の箱の右辺から、y をずらして 2 本出す（`M224,184 …` と `M224,214 H237 V374 H249`）。
- 戻り: 箱の下辺から下の空いた帯へ降り、水平に戻って戻り先の箱の下辺へ上がる（`M984,110 V258 H818 V233`）。ラベルは水平部分の上に `.al` で置く。
- 箱の中の文字は 1 行あたり全角 11〜12 字まで。収まらなければ改行するか箱を広げる。

## 確認で見るもの

- 箱と線の重なり、ラベルと線の重なり、箱からはみ出した文字。
- 図や表の外でページが横にスクロールしないか。
- 同じ id の marker が 2 つないか（あると後ろの図の矢印が消えることがある）。
