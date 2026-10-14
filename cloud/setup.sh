#!/bin/bash
# rules 2026-10-14  ← claude-rules を push したら5分ほど待ってから、この日付を書き換える（次の新しいセッションから取り直す）
# claude.ai/code の環境の「初期化スクリプト」に、このファイルの中身をそのまま貼る（正本はこのファイル＝README.md）。
BASE=https://raw.githubusercontent.com/NJ163/claude-rules/master
NOW=$(TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M')
mkdir -p ~/.claude/agents
T=$(mktemp -d); ok=1
for f in CLAUDE.md agents/coder.md agents/coder-medium.md agents/coder-xhigh.md agents/verifier.md; do
  mkdir -p "$T/$(dirname "$f")"
  curl -fsSL --max-time 30 "$BASE/$f" -o "$T/$f" || ok=0
done
if [ "$ok" = 1 ]; then
  { echo "（共通規則 NJ163/claude-rules を $NOW JST に取得）"; echo; cat "$T/CLAUDE.md"; } > ~/.claude/CLAUDE.md
  cp "$T"/agents/*.md ~/.claude/agents/
else
  echo "# 共通規則を読み込めていない（$NOW JST の取得に失敗）。作業を始める前に、このことをユーザーへ知らせる。" > ~/.claude/CLAUDE.md
fi
rm -rf "$T"; exit 0
