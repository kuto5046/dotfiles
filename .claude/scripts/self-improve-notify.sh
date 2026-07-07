#!/bin/bash
# SessionStart hook: 未レビューの自己改善提案があればコンテキストに注入する

PROPOSALS_DIR="$HOME/.claude/self-improve/proposals"
[ -d "$PROPOSALS_DIR" ] || exit 0

COUNT=$(ls "$PROPOSALS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "$COUNT" -eq 0 ] && exit 0

echo "未レビューの自己改善提案が ${COUNT} 件あります (~/.claude/self-improve/proposals/)。ユーザーへの最初の応答の末尾で「/self-improve でレビューできます」と一言添えてください。ユーザーの依頼より優先してはいけません。"
exit 0
