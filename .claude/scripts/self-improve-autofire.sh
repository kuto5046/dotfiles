#!/bin/bash
# Stop hook: ユーザーの依頼が一段落したタイミングで、未レビューの
# 自己改善提案があれば /self-improve (inboxモード) を自動発火させる。
# セッションあたり1回のみ。

set -u

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# 自分のblockで継続した応答の終了時には再発火しない(無限ループ防止)
[ "$STOP_HOOK_ACTIVE" = "true" ] && exit 0

PROPOSALS_DIR="$HOME/.claude/self-improve/proposals"
COUNT=$(ls "$PROPOSALS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "$COUNT" -eq 0 ] && exit 0

# セッションあたり1回のスロットル
MARKER_DIR="$HOME/.claude/self-improve/.autofire"
mkdir -p "$MARKER_DIR"
MARKER="$MARKER_DIR/$SESSION_ID"
[ -f "$MARKER" ] && exit 0
touch "$MARKER"
find "$MARKER_DIR" -type f -mtime +7 -delete 2>/dev/null

cat <<EOF
{"decision": "block", "reason": "直前のユーザー依頼への対応は完了しています。未レビューの自己改善提案が ${COUNT} 件たまっているので、いまが区切りの良いタイミングです。Skillツールで self-improve スキルを inbox モードで実行し、提案のレビューと反映を行ってください。ユーザーが明らかにまだ作業の途中(質問への回答待ち・連続作業の合間)であれば、実行せず『自己改善提案が ${COUNT} 件あります。後で /self-improve でレビューできます』と一言添えるだけにしてください。"}
EOF
exit 0
