---
name: sharing-schedules-via-notion
description: >
  Publishes and imports Shepherd schedules via a shared Notion database.
  Handles listing available schedules, exporting local schedules to Notion,
  and importing schedules from Notion into Shepherd.
  Triggers on: "share schedule", "publish schedule", "import schedule from Notion",
  "list shared schedules", "共有スケジュール", "スケジュールを共有", "スケジュールをインポート".
---

# Schedules 共有 via Notion

## Notion DB 情報

- **DB ID**: `30bcdd370bae805cb465edb6f52a5ca9`
- **data_source**: 一覧取得時に DB ID を使って検索する

## プロパティマッピング

| Notion プロパティ | 型 | Schedule フィールド | agent_schedule_create パラメータ |
|---|---|---|---|
| 名前 | title | name | name |
| slug | rich_text | slug | slug |
| schedule_type | select | schedule_type | schedule_type |
| schedule_config | rich_text | schedule_config（JSON） | schedule_config |
| timeout_seconds | number | timeout_seconds | timeout_seconds |

**Notion に保存しないフィールド**（ローカル環境固有）:
- cli_path, cli_type, cli_flags（CLI 設定）
- working_directory（作業ディレクトリ）
- timezone（タイムゾーン）
- notify_on_completion, notify_on_error（通知設定）

prompt はページ本文に格納（rich_text の 2000 文字制限回避）。

## 操作手順

### 一覧表示

`mcp__shepherd__notion_query_data_sources` を使用して Schedules DB の内容を取得:

```
mcp__shepherd__notion_query_data_sources:
  database_id: "30bcdd370bae805cb465edb6f52a5ca9"
```

結果をテーブル形式でユーザーに表示する。

### エクスポート（ローカル → Notion）

1. `mcp__shepherd__agent_schedule_list` でローカルスケジュール一覧を取得
2. ユーザーにエクスポート対象を確認
3. `mcp__shepherd__agent_schedule_get` で詳細を取得
4. **機密情報のマスク処理**（Notion にアップロードする前に必ず実施）:
   - prompt の全文を走査し、以下のパターンを検出・マスクする:
     - **絶対パス**: `/Users/xxx/...`, `/home/xxx/...`, `C:\\Users\\...` → `<YOUR_PATH>` に置換
     - **API キー・トークン**: `sk-...`, `ghp_...`, `xoxb-...`, `Bearer ...` 等 → `<REDACTED>` に置換
     - **顧客名・組織名**: 会社名、プロジェクト固有名、内部コードネーム → `<ORG_NAME>` に置換
     - **内部 URL**: `*.internal.*`, `*.corp.*`, ステージング環境等 → `<INTERNAL_HOST>` に置換
     - **メールアドレス**: → `<EMAIL>` に置換
     - **IP アドレス**: → `<IP_ADDRESS>` に置換
   - マスク後の prompt をユーザーに表示し、AskUserQuestion で「この内容で公開してよいか」確認を取る
5. Notion ページを作成（共有対象のフィールドのみ）:

```
mcp__shepherd__notion_create_pages:
  parent: {"data_source_id": "30bcdd37-0bae-8005-a5f1-000b0c782ffd"}
  pages:
    - properties:
        名前: <name>
        slug: <slug>
        schedule_type: <schedule_type>
        schedule_config: <JSON文字列>
        timeout_seconds: <timeout_seconds>
      content: <マスク済み prompt テキスト>
```

6. 作成されたページ URL をユーザーに表示

### インポート（Notion → ローカル）

1. 一覧表示で共有スケジュールを表示
2. ユーザーが選択したスケジュールの page_id を取得
3. `mcp__shepherd__notion_fetch` でページ詳細を取得:

```
mcp__shepherd__notion_fetch:
  url: "https://www.notion.so/<page_id>"
  mode: "markdown"
```

4. レスポンスからプロパティと本文（prompt）を抽出
5. **インポート内容の確認**: AskUserQuestion ツールで以下を確認する:
   - まず取得した内容のプレビューを表示
   - prompt 内に `<YOUR_PATH>`, `<ORG_NAME>`, `<REDACTED>` 等のプレースホルダがある場合:
     各プレースホルダについて「実際の値を入力してください」と質問する
   - slug が既に存在する場合は「既存スケジュールを上書きしますか？」と確認する
6. 確認後、`mcp__shepherd__agent_schedule_create` でスケジュールを作成:
   - Notion から取得したフィールド（name, slug, schedule_type, schedule_config, timeout_seconds, prompt）を設定
   - ローカル固有フィールドはデフォルト値を使用:
     - timezone: "Asia/Tokyo"
     - cli_type: "claude"
     - cli_flags, cli_path, working_directory: 省略

```
mcp__shepherd__agent_schedule_create:
  name: <名前>
  slug: <slug>
  prompt: <プレースホルダ置換済み prompt>
  schedule_type: <schedule_type>
  schedule_config: <schedule_config（JSONオブジェクト）>
  timeout_seconds: <timeout_seconds or 3600>
```

7. slug が既に存在する場合は `mcp__shepherd__agent_schedule_update` で更新

### 注意事項

- schedule_config は JSON オブジェクトとして保存・復元する
  - daily: `{"time": "09:00"}`
  - weekly: `{"day": "monday", "time": "09:00"}`
  - interval: `{"minutes": 60}`
- timeout_seconds のデフォルトは 3600（1時間）
- エクスポート前に必ず機密情報のマスク処理を行い、ユーザー確認を取ること
