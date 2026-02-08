---
name: codex-review
description: Codex MCPを使用してプルリクエストの包括的なコードレビューを実行します。バグ検出とパフォーマンス改善に焦点を当てます。「このPRをレビューして」「PRをcodexでレビュー」「このプルリクエストをcodexで分析して」などのリクエスト時にトリガーされます。Codexの高度な分析機能を活用した詳細なコード検査を提供します。
---

# Codex Review

## 概要

Codex MCPを使用してプルリクエストの詳細なレビューを実行します。このスキルは、PR変更全体にわたるバグ、セキュリティ脆弱性、パフォーマンス最適化の機会を特定することに焦点を当てています。

## ワークフロー

### 1. PR情報の取得

まず、PRの詳細を特定して取得します:

```bash
# PR番号が指定されている場合
gh pr view <PR_NUMBER> --json number,title,body,headRefName,baseRefName

# 現在PRブランチにいる場合
gh pr view --json number,title,body,headRefName,baseRefName

# PRの差分を取得
gh pr diff <PR_NUMBER>
```

ユーザーがPR番号を指定しない場合は、現在のブランチを確認するか、明確化を求めます。

### 2. Codexレビューの実行

`mcp__codex__codex`ツールを使用してPR変更を分析します:

**重要なパラメータ:**
- `prompt`: バグとパフォーマンスに焦点を当てた詳細なレビュー依頼
- `cwd`: リポジトリのルートに設定
- `approval-policy`: `"on-request"`を使用してCodexが必要に応じてコマンドを提案できるようにする
- `sandbox`: `"read-only"`を使用して安全性を確保（Codexはファイルを変更しない）

**プロンプト構造の例:**
```
このプルリクエストをバグとパフォーマンスの問題についてレビューしてください。

PR: #<number> - <title>
Branch: <headRefName> -> <baseRefName>

変更内容:
<gh pr diffの出力を貼り付け>

以下に焦点を当ててください:
1. 潜在的なバグとロジックエラー
2. パフォーマンスのボトルネックや非効率性
3. セキュリティ脆弱性
4. 処理されていないエッジケース
5. リソースリークやメモリの問題

重要度レベル（Critical/High/Medium/Low）を含めた具体的な行ごとのフィードバックを提供してください。
```

### 3. 結果の提示

Codexがレビューを完了したら、発見事項を要約します:

- **Critical Issues**: 障害を引き起こすバグ
- **Performance Issues**: 最適化の機会
- **Security Concerns**: 潜在的な脆弱性
- **Best Practices**: コード品質の改善

各発見事項に対して具体的なファイルパスと行番号を含めます。

## 使用例

**User:** "このPRをレビューして"

**処理:**
1. `gh pr view`を実行して現在のPR詳細を取得
2. `gh pr diff`を実行して変更内容を取得
3. 差分とレビュープロンプトで`mcp__codex__codex`を呼び出し
4. 構造化されたフィードバックを提示

## 設定

**Codex設定:**
- `approval-policy: "on-request"` - Codexが読み取り専用コマンドを提案できるようにする
- `sandbox: "read-only"` - ファイルの変更を防止
- `model`: デフォルトを使用（通常は最新のGPTモデル）

**レビューの焦点:**
- バグ検出（最優先）
- パフォーマンス最適化（高優先）
- セキュリティ分析
- コード品質と保守性

## ヒント

- 大規模なPR（500行以上）の場合は、ファイルまたはセクションごとにレビューすることを検討
- Codexに重要度順に発見事項を優先順位付けするよう依頼
- 特定された問題に対する具体的な例や修正を要求
- 明確化のために`mcp__codex__codex-reply`でフォローアップ
