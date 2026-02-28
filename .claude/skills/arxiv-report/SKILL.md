---
name: arxiv-report
description: arxiv論文を詳細に分析し、日本語でレポートを生成する（並列処理で高速化、ベンチマーク比較付き）
allowed-tools: Task, WebFetch, WebSearch, Read, Write, Bash
model: sonnet
disable-model-invocation: true
argument-hint: <arxiv-id or URL>
---

# arxiv論文詳細レポート生成

arxiv論文のURLまたはIDを入力すると、以下を含む詳細な日本語レポートを生成します：

1. **詳細な論文解説**（関連研究のarxiv URL付き、論文中の図表画像を含む）
2. **ベンチマーク比較Leaderboard**（ChatGPT、Claude、Gemini等の商用モデルとの性能比較表）
3. **落合フォーマット**でのまとめ（箇条書き形式）
4. **GitHub実装の解析**（コード抜粋付き）
5. **Notionへの自動投稿**（設定済みの場合）

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

**重要**: 以下の5つのエージェントを**同時に**Taskツールで並列起動してください（1つのメッセージで5つのTask呼び出し）：

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

#### エージェント4: ベンチマーク調査（フェーズ4担当）
```
Taskツールパラメータ:
- subagent_type: "general-purpose"
- run_in_background: true
- description: "ベンチマーク調査"
- prompt: [下記のプロンプト4を使用]
```

#### エージェント5: 図表コンテキスト解析（フェーズ5担当）
```
Taskツールパラメータ:
- subagent_type: "general-purpose"
- run_in_background: true
- description: "図表コンテキスト解析"
- prompt: [下記のプロンプト5を使用]
```

---

### プロンプト1: 論文本体解析エージェント

```
arxiv論文 [arxiv_id] の本体を解析してください。

## 実行内容

1. WebFetchで `https://arxiv.org/abs/[arxiv_id]` から基本情報を抽出：
   - タイトル（原題と日本語訳）
   - 著者と所属
   - 発表日、カテゴリ
   - アブストラクト
   - GitHub URLやプロジェクトページ

2. WebFetchで `https://arxiv.org/pdf/[arxiv_id].pdf` からPDF全文を解析：
   - 全セクションの内容
   - 提案手法の詳細
   - 実験設定と結果
   - 主要な図表を特定（5-7個程度、ページ番号を記録）
   - 引用文献リスト

3. 論文中の図表に関するメモ（※画像の実際の抽出はフェーズ5が担当）：
   - 各セクションで主要な図表番号を記録（例: "Figure 3 shows the architecture..."）
   - 図表の説明が本文にある場合はメモしておく

4. Writeツールで `arxiv_[arxiv_id]_phase1.json` に結果を保存：
   ```json
   {
     "title": "...",
     "title_ja": "...",
     "authors": "...",
     "affiliation": "...",
     "date": "...",
     "category": "...",
     "abstract": "...",
     "github_url": "..." or null,
     "sections": {...},
     "references": [...]
   }
   ```

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

### プロンプト4: ベンチマーク調査エージェント

```
arxiv論文 [arxiv_id] のベンチマーク評価を調査し、Leaderboard形式でまとめてください。

## 実行内容

1. **ベンチマーク情報の抽出**:
   - WebFetchで `https://arxiv.org/pdf/[arxiv_id].pdf` から実験結果セクションを解析
   - 使用されているベンチマーク名を特定（例: MMLU, HumanEval, MATH, GSM8K, MT-Bench等）
   - 論文中の評価指標とスコアを記録
   - **論文での手法の名称を必ず記録**（例: "Proposed Method", "Our Model", 具体的なモデル名等）

2. **商用モデルの優先調査**:
   各ベンチマークについて、以下の順序で調査（WebSearchを使用）:

   **優先度1 - 商用クローズドモデル（必須）**:
   - GPT-4, GPT-4 Turbo, GPT-4o, GPT-3.5 (OpenAI)
   - Claude 3 Opus, Claude 3.5 Sonnet, Claude 3 Haiku (Anthropic)
   - Gemini Ultra, Gemini Pro, Gemini Flash (Google)
   - 検索クエリ例: `"[benchmark_name] GPT-4 score"`, `"[benchmark_name] Claude 3.5 Sonnet performance"`

   **優先度2 - 主要オープンモデル**:
   - Llama 3, Llama 2 (Meta)
   - Mistral, Mixtral (Mistral AI)
   - Qwen (Alibaba)
   - 検索クエリ例: `"[benchmark_name] Llama 3 benchmark"`, `"[benchmark_name] leaderboard 2024"`

   **優先度3 - 公式リーダーボード**:
   - Papers with Code, Hugging Face Leaderboards
   - 検索クエリ例: `"[benchmark_name] leaderboard papers with code"`, `"[benchmark_name] huggingface leaderboard"`

3. **調査制限**:
   - 各ベンチマークにつき最低3つの商用モデル、最大10モデルまで
   - 検索は各ベンチマークにつき最大5回まで
   - 見つからないベンチマークはスキップ

4. **データ構造化**:
   Writeツールで `arxiv_[arxiv_id]_phase4.json` に結果を保存:

```json
{
  "benchmarks": [
    {
      "name": "MMLU",
      "description": "Massive Multitask Language Understanding",
      "paper_score": {
        "model": "[論文での手法の名称]",
        "score": 85.2,
        "metric": "accuracy (%)"
      },
      "leaderboard": [
        {
          "rank": 1,
          "model": "GPT-4",
          "score": 86.4,
          "metric": "accuracy (%)",
          "source": "OpenAI Technical Report",
          "date": "2023-03"
        },
        {
          "rank": 2,
          "model": "Claude 3 Opus",
          "score": 86.8,
          "metric": "accuracy (%)",
          "source": "Anthropic Blog",
          "date": "2024-03"
        },
        ...
      ]
    },
    ...
  ]
}
```

5. **重要な注意事項**:
   - **モデル名は必須**（論文での手法名、商用モデル名等を必ず記録）
   - スコアは必ず数値で記録（パーセンテージは数値のみ、例: 85.2）
   - 同じベンチマークで異なる設定（few-shot数など）がある場合は注記
   - 情報源（論文やブログのURL）を必ず記録
   - 見つからなかったベンチマークは空配列で保存

完了後、結果JSONファイルのパスを出力してください。
```

---

### プロンプト5: 図表コンテキスト解析エージェント

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
    [arxiv_id] arxiv_[arxiv_id]_phase5_raw.json \
    --figures-summary arxiv_[arxiv_id]_figures/figures_summary.json
```

Readツールで `arxiv_[arxiv_id]_phase5_raw.json` を読み込んでください。

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

1. Readツールで各JSONファイルを読み込み：
   - `arxiv_[arxiv_id]_phase1.json`
   - `arxiv_[arxiv_id]_phase2.json`
   - `arxiv_[arxiv_id]_phase3.json`
   - `arxiv_[arxiv_id]_phase4.json`
   - `arxiv_[arxiv_id]_phase5.json`（図表コンテキスト情報）

2. Writeツールで `arxiv_[arxiv_id]_report.md` を生成：

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

phase5.jsonの各figureに対して、以下の形式で出力してください（全ての図を含める）：

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

### 1.5 ベンチマーク比較（Leaderboard）

各ベンチマークについて、主要モデルとの性能比較を表形式で表示：

#### [ベンチマーク名1]（例: MMLU）

| Rank | Model | Score | Metric | Source | Date |
|------|-------|-------|--------|--------|------|
| 1 | GPT-4o | 88.7 | accuracy (%) | OpenAI Report | 2024-05 |
| 2 | Claude 3.5 Sonnet | 88.3 | accuracy (%) | Anthropic Blog | 2024-06 |
| 3 | **[論文の手法名]** | **85.2** | **accuracy (%)** | This paper | 2025-01 |
| 4 | Gemini Pro | 84.1 | accuracy (%) | Google Report | 2024-03 |

**論文中の手法**: [論文での手法名] - **85.2%**

#### [ベンチマーク名2]（例: HumanEval）

| Rank | Model | Score | Metric | Source | Date |
|------|-------|-------|--------|--------|------|
...

**注**:
- 太字は論文中の提案手法のスコア
- 商用モデル（ChatGPT, Claude, Gemini）を優先的に掲載
- スコアは各情報源から取得した最新値

### 1.6 考察と限界
- 強み
- 弱み
- 今後の課題

### 1.7 関連研究
1. **[タイトル](arxiv_url)** - [説明]
2. ...
[5本程度]

---

## 2. 落合フォーマット

### どんなもの？
- 論文の核心を端的に説明
- 提案手法の概要
- 主要な貢献

### 先行研究と比べてどこがすごい？
- 新規性
- 優位性
- 技術的進歩

### 技術や手法のキモはどこ？
- 技術的核心
- 重要なアイデア
- 実装上の工夫

### どうやって有効だと検証した？
- 実験設定
- 評価方法
- 主要な結果

### 議論はある？
- 限界
- 課題
- 議論点

### 次に読むべき論文は？
- **[タイトル](url)** - [理由]
- **[タイトル](url)** - [理由]
[3-5本]

---

## 3. 実装コード解析

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
📊 **ベンチマーク**: Y個のベンチマークで比較表生成（商用モデル含む）
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
