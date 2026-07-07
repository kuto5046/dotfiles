---
name: sharing-skills-via-notion
description: >
  Publishes and imports Claude Code skills via a shared Notion database.
  Handles listing available skills, exporting local skills to Notion,
  and importing skills from Notion to the local .claude/skills/ directory.
  Triggers on: "share skill", "publish skill", "import skill from Notion",
  "list shared skills", "共有スキル", "スキルを共有", "スキルをインポート".
---

# Skills 共有 via Notion

## Notion DB 情報

- **DB ID**: `30bcdd370bae802d898ae13e175f200e`
- **data_source**: `collection://30bcdd37-0bae-804c-9fb8-000be82c8860`

## プロパティマッピング

| Notion プロパティ | 型 | SKILL.md frontmatter |
|---|---|---|
| name | title | name |
| description | rich_text | description |
| metadata | rich_text | metadata（JSON文字列） |
| allowed-tools | rich_text | allowed-tools |

SKILL.md の body（frontmatter 以降の markdown）→ Notion ページ本文に格納。

## 操作手順

### 一覧表示

`mcp__shepherd__notion_query_data_sources` を使用:

```
data_source_id: "collection://30bcdd37-0bae-804c-9fb8-000be82c8860"
```

結果をテーブル形式でユーザーに表示する。

### エクスポート（ローカル → Notion）

1. ユーザーにエクスポート対象のスキルを確認（名前で指定）
2. Read ツールでローカルの `SKILL.md` を読み込む
3. frontmatter をパース:
   - `---` で囲まれた YAML 部分を抽出
   - name, description, metadata, allowed-tools を取得
4. **機密情報のマスク処理**（Notion にアップロードする前に必ず実施）:
   - 本文と frontmatter の全フィールドを走査し、以下のパターンを検出・マスクする:
     - **絶対パス**: `/Users/xxx/...`, `/home/xxx/...`, `C:\\Users\\...` → 環境依存パスを `<YOUR_PATH>` に置換
     - **API キー・トークン**: `sk-...`, `ghp_...`, `xoxb-...`, `Bearer ...` 等のパターン → `<REDACTED>` に置換
     - **顧客名・組織名**: 会社名、プロジェクト固有名、内部コードネーム → `<ORG_NAME>` に置換
     - **URL のホスト名**: 内部ドメイン（`*.internal.*`, `*.corp.*`, ステージング環境等） → `<INTERNAL_HOST>` に置換
     - **メールアドレス**: → `<EMAIL>` に置換
     - **IP アドレス**: プライベート IP 含む → `<IP_ADDRESS>` に置換
   - マスク後の内容をユーザーに表示し、問題ないか AskUserQuestion で確認を取る
5. Notion ページを作成:

```
mcp__shepherd__notion_create_pages:
  parent_id: "30bcdd370bae802d898ae13e175f200e"
  parent_type: "database"
  title: <name>
  properties:
    description: <description>
    metadata: <metadata JSON文字列>
    allowed-tools: <allowed-tools>
  content: <マスク済み body（frontmatter 以降のマークダウン全文）>
```

6. 作成されたページ URL をユーザーに表示

### インポート（Notion → ローカル）

1. 一覧表示で共有スキルを表示
2. ユーザーが選択したスキルの page_id を取得
3. `mcp__shepherd__notion_fetch` でページ詳細を取得:

```
mcp__shepherd__notion_fetch:
  url: "https://www.notion.so/<page_id>"
  mode: "markdown"
```

4. レスポンスからプロパティと本文を抽出
5. frontmatter を再構築:

```yaml
---
name: <name>
description: >
  <description>
# metadata と allowed-tools があれば追加
---
```

6. **インポート内容の確認**: AskUserQuestion ツールで以下を確認する:
   - 「このスキルをインポートしますか？」（プレビューを表示）
   - 同名スキルが既に存在する場合は「既存スキルを上書きしますか？」
   - `<YOUR_PATH>`, `<ORG_NAME>` 等のプレースホルダがある場合は「以下のプレースホルダを実際の値に置き換えてください」と各プレースホルダの置換値を質問する
7. 確認後、`.claude/skills/<name>/SKILL.md` に Write ツールで書き込み

### 注意事項

- スキル名にはスペースの代わりにハイフンを使用する
- description の改行は YAML の `>` 記法で保持する
- metadata は JSON 文字列としてそのまま保存/復元する
- エクスポート時は絶対パスや環境固有の情報を含めないこと
- インポート時にプレースホルダが残っている場合は必ずユーザーに置換値を確認する
