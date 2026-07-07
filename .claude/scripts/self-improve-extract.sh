#!/bin/bash
# SessionEnd hook: セッションのトランスクリプトから「学び」を抽出して
# ~/.claude/self-improve/proposals/ に提案ファイルとして保存する。
# 反映は /self-improve スキルでユーザー確認のうえ行う。

set -u

# 再帰防止: このスクリプトが起動した headless claude のセッションでは何もしない
if [ "${CLAUDE_SELF_IMPROVE_HEADLESS:-0}" = "1" ]; then
  exit 0
fi

INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

[ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ] && exit 0

# ユーザー発話が少ないセッション(挨拶だけ等)はスキップ
USER_MSG_COUNT=$(jq -r 'select(.type == "user") | .message.content | if type == "string" then . else (map(select(.type == "text")) | .[0].text // empty) end' "$TRANSCRIPT_PATH" 2>/dev/null | grep -cv '^\s*$' || true)
[ "${USER_MSG_COUNT:-0}" -lt 3 ] && exit 0

PROPOSALS_DIR="$HOME/.claude/self-improve/proposals"
LOG_DIR="$HOME/.claude/self-improve/logs"
mkdir -p "$PROPOSALS_DIR" "$LOG_DIR"

OUT_FILE="$PROPOSALS_DIR/$(date +%Y%m%d-%H%M%S)-${SESSION_ID:0:8}.md"

PROMPT="あなたはClaude Codeセッションの振り返り分析者です。
以下のトランスクリプト(JSONL)を読み、次を抽出してください:

1. **ユーザーからの訂正・指摘**: Claudeの出力ややり方をユーザーが直した箇所
2. **手戻り・迷走**: 探索の空振り、誤った前提、やり直しが発生した箇所
3. **ユーザーの好み・暗黙のルール**: 明示されていないが読み取れる期待

それぞれについて「再発防止としてどこに反映すべきか」を分類してください:
- global-claude-md: ~/.claude/CLAUDE.md (全プロジェクト共通のプロセス)
- project-claude-md: 対象リポジトリのCLAUDE.md (プロジェクト固有知識)
- skill: 既存スキルの改善 (スキル名を明記)
- memory: 事実の記録 (ユーザー情報・プロジェクト状況)
- none: 記録不要 (このセッション限りの話)

学びが無ければ「NO_LEARNINGS」とだけ出力してください。
学びがあれば、各項目を以下の形式で出力:

## [分類] 短いタイトル
- 何があったか: ...
- 提案する反映内容: (CLAUDE.mdなら追記文案、スキルなら修正方針)

作業ディレクトリ: $CWD
出力はこのファイル内容そのものになるので、前置き・後書きは不要です。"

# バックグラウンドで headless 分析 (セッション終了をブロックしない)
(
  RESULT=$(CLAUDE_SELF_IMPROVE_HEADLESS=1 claude -p "$PROMPT

--- TRANSCRIPT ---
$(tail -c 400000 "$TRANSCRIPT_PATH")" \
    --model claude-sonnet-5 \
    --disallowedTools "Bash,Edit,Write,WebFetch,WebSearch" \
    2>>"$LOG_DIR/extract.log")

  if [ -n "$RESULT" ] && ! echo "$RESULT" | grep -q "NO_LEARNINGS"; then
    {
      echo "---"
      echo "session_id: $SESSION_ID"
      echo "cwd: $CWD"
      echo "date: $(date +%Y-%m-%d)"
      echo "status: pending"
      echo "---"
      echo ""
      echo "$RESULT"
    } > "$OUT_FILE"
  fi
) >/dev/null 2>&1 &

exit 0
