---
name: arxiv-report
description: arxiv論文を詳細に分析し、日本語でレポートを生成する（並列処理で高速化）
allowed-tools: Task, WebFetch, WebSearch, Read, Write, Bash
model: sonnet
disable-model-invocation: true
argument-hint: <arxiv-id or URL>
---

# arxiv論文詳細レポート生成

arxiv論文のURLまたはIDを入力すると、以下を含む詳細な日本語レポートを生成します：

1. **詳細な論文解説**（関連研究のarxiv URL付き、論文中の図表画像を含む）
2. **GitHub実装の解析**（コード抜粋付き）
3. **Notionへの自動投稿**（設定済みの場合）

複数の独立したエージェントを並列実行して処理時間を短縮します。

## 使用方法

```
/arxiv-report https://arxiv.org/abs/2501.12345
/arxiv-report 2501.12345
```

## タスク

### 手順1: 初期確認

1. ユーザーから提供されたarxiv URLまたはIDを確認
2. URLからarxiv IDを抽出（例: `https://arxiv.org/abs/2501.12345` → `2501.12345`）
3. 画像保存用ディレクトリの作成: `arxiv_[arxiv_id]_images/`

### 手順2: 並列エージェントの起動

**重要**: 以下の4つのエージェントを**同時に**Taskツールで並列起動してください（1つのメッセージで4つのTask呼び出し）：

#### エージェント1: 論文本体解析（フェーズ1担当）
```
Taskツールパラメータ:
- subagent_type: "general-purpose"
- run_in_background: true
- description: "論文本体解析"
- prompt: [下記のプロンプト1を使用]
```

#### エージェント2: 関連研究調査（フェーズ2担当）
```
Taskツールパラメータ:
- subagent_type: "general-purpose"
- run_in_background: true
- description: "関連研究調査"
- prompt: [下記のプロンプト2を使用]
```

#### エージェント3: GitHub実装調査（フェーズ3担当）
```
Taskツールパラメータ:
- subagent_type: "general-purpose"
- run_in_background: true
- description: "GitHub実装調査"
- prompt: [下記のプロンプト3を使用]
```

#### エージェント4: 図表コンテキスト解析（フェーズ4担当）
```
Taskツールパラメータ:
- subagent_type: "general-purpose"
- run_in_background: true
- description: "図表コンテキスト解析"
- prompt: [下記のプロンプト4を使用]
```

---

### プロンプト1: 論文本体解析エージェント

```
arxiv論文 [arxiv_id] の本体を**可能な限り詳細に**解析してください。
情報の省略・要約は最小限にとどめ、論文から得られる知見を最大化することを最優先にしてください。

## 実行内容

### ステップ1: 基本情報の取得

WebFetchで `https://arxiv.org/abs/[arxiv_id]` にアクセスし以下を取得：
- タイトル（原題と日本語訳）
- 著者全員と所属機関
- 発表日・更新日・カテゴリ
- アブストラクト全文
- GitHub URLやプロジェクトページURL

### ステップ2: TeXソースの取得と全文解析

Bashツールで以下を実行：

```bash
curl -L "https://arxiv.org/e-print/[arxiv_id]" -o "arxiv_[arxiv_id]_tex.tar.gz"
mkdir -p arxiv_[arxiv_id]_tex
tar -xf arxiv_[arxiv_id]_tex.tar.gz -C arxiv_[arxiv_id]_tex 2>/dev/null || true
ls arxiv_[arxiv_id]_tex/
```

Globツールで `arxiv_[arxiv_id]_tex/**/*.tex` を検索し、メインの.texファイルを特定（main.tex, paper.tex, または最も大きい.texファイル）。
Readツールで読み込み、**全セクションを原文に忠実に詳細抽出**する。

**TeXソースが利用不可の場合のフォールバック**: `curl` が失敗した場合は
WebFetchで `https://arxiv.org/pdf/[arxiv_id].pdf` から解析してください。

### ステップ3: 詳細な内容抽出

各セクションについて以下を漏れなく抽出してください：

**Introduction**:
- 研究背景・動機（具体的な問題設定）
- 既存手法の課題・限界（何が問題なのか）
- 本研究の貢献・novelty（何を解決するか）
- 論文の構成

**Related Work**:
- 各関連研究の手法概要と本研究との差分
- 参照している主要論文（タイトルとciteキー）

**提案手法（Method/Approach）**:
- アーキテクチャ・アルゴリズムの詳細（数式・記号も含めて）
- 各コンポーネントの役割と設計意図
- 技術的な工夫・アイデアのキモ
- 従来手法との差分・改善点

**実験（Experiments）**:
- 使用データセット（名前・サイズ・特徴）
- 評価指標（名前・計算方法）
- ベースライン・比較手法の一覧
- 主要な実験結果（具体的な数値）
- アブレーション研究の結果と考察

**考察・結論（Discussion/Conclusion）**:
- 結果の解釈・考察
- 手法の限界・失敗ケース
- 今後の課題・展望

### ステップ4: JSONに保存

Writeツールで `arxiv_[arxiv_id]_phase1.json` に保存：

```json
{
  "title": "原題",
  "title_ja": "日本語訳",
  "authors": "著者全員（カンマ区切り）",
  "affiliation": "所属機関",
  "date": "発表日（更新日も含む）",
  "category": "arxivカテゴリ",
  "abstract": "アブストラクト全文",
  "github_url": "URL or null",
  "project_url": "URL or null",
  "sections": {
    "introduction": "背景・課題・貢献の詳細説明（300字以上）",
    "related_work": "関連研究の詳細（各研究の手法と本研究との差分）",
    "method": "提案手法の詳細説明（アーキテクチャ・数式・設計意図を含む、500字以上）",
    "experiments": "実験設定・データセット・評価指標・主要結果の数値・アブレーション（400字以上）",
    "discussion": "結果の考察・限界・今後の課題",
    "conclusion": "結論のまとめ",
    "その他のセクション名": "内容"
  },
  "key_contributions": [
    "貢献1（具体的に）",
    "貢献2",
    "貢献3"
  ],
  "main_results": [
    {"benchmark": "ベンチマーク名", "metric": "指標", "score": "スコア", "baseline": "比較対象", "improvement": "改善幅"}
  ],
  "limitations": ["限界1", "限界2"],
  "references": [
    {"citekey": "...", "title": "...", "url": "arxiv URLがあれば"}
  ]
}
```

**重要**: sectionsの各フィールドは箇条書きではなく、論文の内容を忠実に反映した**詳細な文章**で記述してください。
情報の省略は避け、論文を読んでいない人が内容を完全に理解できるレベルの詳細さを目指してください。

完了後、結果JSONファイルのパスを出力してください。
```

---

### プロンプト2: 関連研究調査エージェント

```
arxiv論文 [arxiv_id] の関連研究を調査してください（5本程度に絞る）。

## 実行内容

WebSearchで関連arxiv論文を効率的に調査：

1. `"[主要キーワード] arxiv [年]"` で最新研究を2-3本
2. `"[第一著者名] arxiv"` で著者の他の論文1-2本
3. 論文中の重要引用から1-2本

各論文について以下を記録：
- タイトル
- arxiv URL
- 簡潔な関係性（1-2文）

Writeツールで `arxiv_[arxiv_id]_phase2.json` に結果を保存：
```json
{
  "related_papers": [
    {"title": "...", "url": "...", "relation": "..."},
    ...
  ]
}
```

完了後、結果JSONファイルのパスを出力してください。
```

---

### プロンプト3: GitHub実装調査エージェント

```
arxiv論文 [arxiv_id] のGitHub実装を調査してください。

## 実行内容

1. フェーズ1で見つかったGitHub URLにアクセス（なければWebSearchで1回のみ検索）

2. **見つからない場合はスキップ**してnull結果を返す

3. 見つかった場合のみ：
   - WebFetchでREADMEを確認
   - 主要コードファイルを1-2個特定
   - 重要部分50-100行程度をWebFetchで抽出

Writeツールで `arxiv_[arxiv_id]_phase3.json` に結果を保存：
```json
{
  "github_url": "..." or null,
  "readme_summary": "...",
  "code_files": [
    {"path": "...", "code": "...", "description": "..."},
    ...
  ]
}
```

完了後、結果JSONファイルのパスを出力してください。
```

---

### プロンプト4: 図表コンテキスト解析エージェント

```
arxiv論文 [arxiv_id] の図表を抽出し、各図がどのセクションで言及されているかを解析してください。

## 実行内容

### ステップ1: 図表の画像と情報を抽出

Bashツールで以下を実行してください：

```bash
# 出力ディレクトリを作成
mkdir -p arxiv_[arxiv_id]_figures

# extract_figures.py でTeXソースから図表を抽出（画像・キャプション・ラベル）
uv run ~/.claude/skills/arxiv-figure-extractor/scripts/extract_figures.py \
    [arxiv_id] arxiv_[arxiv_id]_figures
```

実行後、`arxiv_[arxiv_id]_figures/figures_summary.json` の内容をReadツールで確認してください。

**TeXソースが利用不可でPDFフォールバックになった場合:**
- 画像ファイルは生成されないが、キャプション情報は取得できる
- フォールバック時は `--pdf-only` フラグ付きで再実行：
  ```bash
  uv run --with pymupdf ~/.claude/skills/arxiv-figure-extractor/scripts/extract_figures.py \
      [arxiv_id] arxiv_[arxiv_id]_figures --pdf-only
  ```

### ステップ2: 各図のセクション参照コンテキストを解析

Bashツールで以下を実行してください：

```bash
# analyze_figure_context.py でTeXから各図のセクション参照を解析
uv run ~/.claude/skills/arxiv-figure-extractor/scripts/analyze_figure_context.py \
    [arxiv_id] arxiv_[arxiv_id]_phase4_raw.json \
    --figures-summary arxiv_[arxiv_id]_figures/figures_summary.json
```

Readツールで `arxiv_[arxiv_id]_phase4_raw.json` を読み込んでください。

### ステップ3: 結果を統合してJSONに保存

figures_summary.json と phase5_raw.json の情報を統合し、Writeツールで `arxiv_[arxiv_id]_phase5.json` に保存：

```json
{
  "figures_dir": "arxiv_[arxiv_id]_figures",
  "total_figures": 7,
  "figures": [
    {
      "number": 1,
      "label": "fig:overview",
      "caption": "Overview of our proposed method. The model takes X as input...",
      "image_files": ["arxiv_[arxiv_id]_figures/images/figure_01_overview.pdf"],
      "image_available": true,
      "section_mentions": [
        {
          "section_path": ["3. Proposed Method", "3.1 Architecture"],
          "context": "As illustrated in Figure 1, our model consists of an encoder that processes the input sequence and a decoder that generates the output.",
          "ref_count": 2
        },
        {
          "section_path": ["4. Experiments"],
          "context": "The architecture shown in Figure 1 is evaluated on three benchmarks.",
          "ref_count": 1
        }
      ]
    },
    ...
  ],
  "tables": [
    {
      "number": 1,
      "label": "tab:results",
      "caption": "Comparison with state-of-the-art methods.",
      "section_mentions": [...]
    }
  ]
}
```

**注意事項:**
- `image_available`: 画像ファイルが実際に保存されている場合は true
- TeXソースが利用不可でPDFフォールバックの場合は `image_available: false`
- `image_files` のパスは相対パスで記録

完了後、結果JSONファイルのパスと抽出できた図表数を出力してください。
```

---

### 手順3: 結果の統合とレポート生成

すべてのバックグラウンドエージェントの完了を待ち、結果を統合：

**レートリミット発生時の対応**: エージェントがレートリミットで異常終了した場合でも、
途中まで保存されたJSONファイルが存在する可能性があります。
各JSONファイルをReadツールで読み込み、ファイルが存在しない・または内容が不完全な場合は
その旨をユーザーに報告した上で、利用可能なデータのみでレポートを生成してください。

1. Readツールで各JSONファイルを読み込み（ファイルが存在しない場合はスキップ）：
   - `arxiv_[arxiv_id]_phase1.json`
   - `arxiv_[arxiv_id]_phase2.json`
   - `arxiv_[arxiv_id]_phase3.json`
   - `arxiv_[arxiv_id]_phase4.json`（図表コンテキスト情報）

2. Writeツールで `arxiv_[arxiv_id]_report.md` を生成：

   **注意**: `arxiv_[arxiv_id]_report.md` がすでに存在する場合（別エージェントが先に生成した場合など）は、
   Writeツールの前にReadツールで一度読み込んでから上書きしてください。
   Claudeのルール上、未読のファイルへのWriteはエラーになります。

---
**Markdownレポートテンプレート:**

```markdown
# [論文タイトル日本語訳]

**原題**: [英語タイトル]
**著者**: [著者]
**所属**: [所属]
**発表日**: [日付]
**arxiv**: https://arxiv.org/abs/[arxiv_id]
**カテゴリ**: [カテゴリ]
**GitHub**: [URL or なし]

---

## 1. 詳細な論文解説

### 1.1 概要
[詳細な説明]

### 1.2 背景と動機
- 従来手法の課題
- 本研究の必要性
- 解決すべき問題

### 1.3 提案手法の詳細
- アーキテクチャ
- アルゴリズム
- 技術的工夫

#### 論文中の図表

phase4.jsonの各figureに対して、以下の形式で出力してください（全ての図を含める）：

---

**Figure [number]**: [caption の日本語訳]

> *原文キャプション*: [caption]

![Figure [number]]([image_file_path])
*(画像ファイルが利用不可の場合はこの行を省略)*

**言及セクション:**
- **[section_path を " > " で結合]** ([ref_count]回参照)
  > [context の日本語訳または原文（長い場合は冒頭100文字程度）]

---

**例（Figure 1の場合）:**

---

**Figure 1**: 提案手法の概要図

> *原文キャプション*: Overview of our proposed method. The model takes X as input and produces Y as output.

![Figure 1](arxiv_2501.12345_figures/images/figure_01_overview.pdf)

**言及セクション:**
- **Proposed Method > Architecture** (2回参照)
  > 図1に示すように、本モデルはエンコーダとデコーダから構成され...
- **Experiments** (1回参照)
  > 図1のアーキテクチャを3つのベンチマークで評価した...

---

[全ての図についてこの形式で記載]

### 1.4 実験結果
- データセット
- 評価指標
- 主要結果
- ベースライン比較

### 1.5 考察と限界
- 強み
- 弱み
- 今後の課題

### 1.6 関連研究
1. **[タイトル](arxiv_url)** - [説明]
2. ...
[5本程度]

---

## 2. 実装コード解析

**リポジトリ**: [URL or 「公式実装なし」]

### 主要コード

#### [ファイル名]
```python
[コード抜粋 50-100行]
```
[説明]

### 実装のポイント
- 重要な実装上の工夫
- パフォーマンス最適化
- 注意すべき点

---

## まとめ
- 本論文の主要な貢献
- 実用上の価値
- 今後の展望

**レポート生成**: [日付] by Claude Code
```

---

### 手順4: Notionへの投稿

**Notion MCPツール（mcp__notion__*）を使用してNotionにレポートを投稿：**

1. **ページ作成**: Notion MCPの `create_page` ツールを使用
   - タイトル: 論文タイトル（英語原題をそのまま使用）
   - プロパティ:
     - Authors: 著者名
     - ArXiv ID: arxiv ID
     - Date: 発表日
     - Category: カテゴリ
     - GitHub: GitHub URL（あれば）

2. **コンテンツ追加**: Markdownレポートの各セクションをNotionブロックに変換
   - 見出し → heading blocks
   - 箇条書き → bulleted_list blocks
   - コード → code blocks
   - 画像 → image blocks（ローカルファイルをアップロード）

3. **画像アップロード**: `arxiv_[arxiv_id]_images/` 内の画像をNotionにアップロード

4. **完了通知**: 生成したNotion URLをユーザーに通知

**Notion MCPが利用不可の場合：**
- Markdownファイルのみ生成
- ユーザーに手動インポートを案内

---

### 手順5: 完了通知

すべての処理完了後、以下を出力：

```
✅ **arxiv論文レポート生成完了**

📄 **論文**: [タイトル]
📁 **ファイル**:
   - arxiv_[arxiv_id]_report.md
   - arxiv_[arxiv_id]_figures/ (図表画像・TeXソースから抽出)
🔗 **関連論文**: X本調査
💻 **GitHub**: [見つかった/見つからなかった]
🖼️ **図表**: Z枚の図を抽出（各図のセクション参照コンテキスト付き）
📈 **Notion**: [投稿済みURL / 手動インポート必要]
```

---

## Notionセットアップ

Notion Remote MCPは既にセットアップ済みです（HTTP接続）。

### 保存先データベース設定

**データベースURL**: https://www.notion.so/35dd7cb2129c41feac4722d1aa9eab4b
**data_source_id**: `2153175b-5aa8-4ade-9ba4-ebcecc6ab7ae`

### データベースプロパティ

- **Title** (title型): 論文タイトル（英語原題）
- **userDefined:URL** (url型): arXiv URL
- **Status** (status型): "In progress" または "ToDo"
- **AI 要約** (text型): 論文の簡潔な要約
- **Tag** (relation型): 論文カテゴリタグ
- **Created time** (created_time型): 作成日時（自動）

### Paperタグの設定

論文レポートには必ず **Paper** タグを紐づけてください：
- **TagプロパティURL**: `https://www.notion.so/42ba32a0679c4e839e89d66d86a6b157`

### Notionページ作成時の設定例

```json
{
  "parent": {"type": "data_source_id", "data_source_id": "2153175b-5aa8-4ade-9ba4-ebcecc6ab7ae"},
  "pages": [{
    "properties": {
      "Title": "[論文の英語原題]",
      "userDefined:URL": "https://arxiv.org/abs/[arxiv_id]",
      "Status": "In progress",
      "AI 要約": "[簡潔な要約]",
      "Tag": "https://www.notion.so/42ba32a0679c4e839e89d66d86a6b157"
    },
    "content": "[Markdownレポート全文]"
  }]
}
```

それでは、上記の手順でarxiv論文の詳細レポートを生成してください。
