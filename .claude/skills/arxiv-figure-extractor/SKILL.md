---
name: arxiv-figure-extractor
description: "arXiv論文のURLまたはIDを渡すとPDFをダウンロードし、図(Figure)・表(Table)のキャプション情報を抽出する。arXivのURL(abs/pdf/html形式)やarXiv IDに対応。ユーザーが「arXivの論文から図を抽出して」「この論文のFigureを取り出して」「arxivペーパーの図表情報を取得して」「論文の図表を取得して」と言った場合に使用。arXiv URLや論文IDが含まれる場合にトリガーされる。"
---

# arXiv Figure Extractor

arXiv論文のPDFから図(Figure)と表(Table)のキャプション情報を抽出するスキル。

## Quick Start

```bash
uv run --with pymupdf ~/.claude/skills/arxiv-figure-extractor/scripts/extract_figures.py <arxiv-url-or-id> <output-dir>
```

### 使用例

```bash
# abs URL
uv run --with pymupdf ~/.claude/skills/arxiv-figure-extractor/scripts/extract_figures.py https://arxiv.org/abs/2301.12345 ./output

# pdf URL
uv run --with pymupdf ~/.claude/skills/arxiv-figure-extractor/scripts/extract_figures.py https://arxiv.org/pdf/2301.12345 ./output

# arXiv IDのみ
uv run --with pymupdf ~/.claude/skills/arxiv-figure-extractor/scripts/extract_figures.py 2301.12345 ./output
```

## 出力形式

出力ディレクトリに以下のファイルが生成される:

```
output-dir/
└── figures_summary.json  # 抽出結果のサマリー
```

### figures_summary.json の構造

```json
{
  "source": "/tmp/.../paper.pdf",
  "total_figures": 5,
  "total_tables": 2,
  "items": [
    {
      "kind": "figure",
      "number": 1,
      "caption": "Overview of our proposed method.",
      "page": 2
    }
  ]
}
```

## 抽出の仕組み

1. **キャプション検出**: テキストブロックから `Figure N:` / `Fig. N.` / `Table N:` パターンを検出
2. **サマリー生成**: 検出したキャプション情報をJSONとして保存

## scripts/

- `extract_figures.py` - メインスクリプト。`uv run --with pymupdf` で実行（事前インストール不要）
