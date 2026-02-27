---
name: arxiv-figure-extractor
description: "arXiv論文のURLまたはIDを渡すとTeXソースをダウンロードし、図(Figure)・表(Table)のキャプション情報と画像ファイルを抽出する。arXivのURL(abs/pdf/html形式)やarXiv IDに対応。ユーザーが「arXivの論文から図を抽出して」「この論文のFigureを取り出して」「arxivペーパーの図表情報を取得して」「論文の図表を取得して」と言った場合に使用。arXiv URLや論文IDが含まれる場合にトリガーされる。"
---

# arXiv Figure Extractor

arXiv論文のTeXソースから図(Figure)と表(Table)のキャプション情報と画像ファイルを抽出するスキル。

## Quick Start

```bash
uv run ~/.claude/skills/arxiv-figure-extractor/scripts/extract_figures.py <arxiv-url-or-id> <output-dir>
```

### 使用例

```bash
# abs URL
uv run ~/.claude/skills/arxiv-figure-extractor/scripts/extract_figures.py https://arxiv.org/abs/2301.12345 ./output

# arXiv IDのみ
uv run ~/.claude/skills/arxiv-figure-extractor/scripts/extract_figures.py 2301.12345 ./output

# PDFのみを使う（TeXソースが利用できない場合）
uv run --with pymupdf ~/.claude/skills/arxiv-figure-extractor/scripts/extract_figures.py 2301.12345 ./output --pdf-only
```

## 動作の仕組み

### 優先: TeXソースからの抽出（デフォルト）

1. `https://arxiv.org/e-print/<arxiv_id>` からTeXソース (tar.gz) をダウンロード
2. アーカイブを展開し、メインの`.tex`ファイルを特定
3. `\input` / `\include` を再帰的に展開して全ソースを収集
4. `\begin{figure}...\end{figure}` 環境を解析
   - `\caption{...}` からキャプションを抽出
   - `\label{...}` からラベルを抽出
   - `\includegraphics{...}` から画像ファイルパスを解析・コピー
5. `\begin{table}...\end{table}` 環境のキャプションを抽出

### フォールバック: PDFからの抽出

TeXソースが入手できない場合、PDFからキャプションテキストのみを抽出（画像なし）。
PyMuPDFが必要: `uv run --with pymupdf ... --pdf-only`

## 出力形式

```
output-dir/
├── figures_summary.json  # 抽出結果のサマリー
└── images/               # 抽出された画像ファイル（TeXソース利用時のみ）
    ├── figure_01_overview.pdf
    ├── figure_02_results.png
    └── ...
```

### figures_summary.json の構造

```json
{
  "source": "tex",
  "total_figures": 5,
  "total_tables": 2,
  "items": [
    {
      "kind": "figure",
      "number": 1,
      "label": "fig:overview",
      "caption": "Overview of our proposed method.",
      "image_files": ["images/figure_01_overview.pdf"]
    },
    {
      "kind": "table",
      "number": 1,
      "label": "tab:results",
      "caption": "Results on benchmark datasets.",
      "image_files": []
    }
  ]
}
```

## scripts/

- `extract_figures.py` - メインスクリプト。外部依存なしで `uv run` で実行可能（PDFフォールバック時は `--with pymupdf` が必要）
