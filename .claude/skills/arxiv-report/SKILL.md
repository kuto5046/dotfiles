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
2. **落合フォーマット**でのまとめ（箇条書き形式）
3. **GitHub実装の解析**（コード抜粋付き）
4. **Notionへの自動投稿**（設定済みの場合）

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

**重要**: 以下の3つのエージェントを**同時に**Taskツールで並列起動してください（1つのメッセージで3つのTask呼び出し）：

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

3. **図表画像の取得**（重要）：
   - Bashツールで以下のコマンドを実行し、PDF内の画像を抽出：

   ```bash
   mkdir -p arxiv_[arxiv_id]_images
   # PDFから画像を抽出（ImageMagick使用）
   convert -density 150 "https://arxiv.org/pdf/[arxiv_id].pdf" -quality 90 "arxiv_[arxiv_id]_images/page_%03d.png"
   ```

   - または、主要な図表ページのスクリーンショットを取得
   - 各画像ファイルを `arxiv_[arxiv_id]_images/figure_X.png` として保存
   - 図表番号とファイル名のマッピングを記録

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
     "figures": [
       {"number": 1, "description": "...", "file": "arxiv_[arxiv_id]_images/figure_1.png"},
       ...
     ],
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

### 手順3: 結果の統合とレポート生成

すべてのバックグラウンドエージェントの完了を待ち、結果を統合：

1. Readツールで各JSONファイルを読み込み：
   - `arxiv_[arxiv_id]_phase1.json`
   - `arxiv_[arxiv_id]_phase2.json`
   - `arxiv_[arxiv_id]_phase3.json`

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

**Figure 1**: [説明]
![Figure 1](arxiv_[arxiv_id]_images/figure_1.png)

**Figure 2**: [説明]
![Figure 2](arxiv_[arxiv_id]_images/figure_2.png)

[すべての重要な図を含める - ローカル画像ファイルを参照]

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
   - タイトル: 論文タイトル（日本語訳）
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
   - arxiv_[arxiv_id]_images/ (図表画像)
🔗 **関連論文**: X本調査
💻 **GitHub**: [見つかった/見つからなかった]
📊 **Notion**: [投稿済みURL / 手動インポート必要]
```

---

## Notionセットアップ

Notion Remote MCPは既にセットアップ済みです（HTTP接続）。

### 保存先データベース設定

**データベースURL**: https://www.notion.so/35dd7cb2129c41feac4722d1aa9eab4b
**data_source_id**: `2153175b-5aa8-4ade-9ba4-ebcecc6ab7ae`

### データベースプロパティ

- **Title** (title型): 論文タイトル（日本語訳）
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
      "Title": "[論文タイトル日本語訳]",
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
