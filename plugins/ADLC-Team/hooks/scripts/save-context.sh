#!/bin/bash
# PreCompact + SessionEnd hook — snapshot project state before context loss.
set -euo pipefail

SDLC_DIR=".sdlc"
SNAPSHOT="$SDLC_DIR/context-snapshot.md"
mkdir -p "$SDLC_DIR/_active"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat > "$SNAPSHOT" << HEADER
# Context Snapshot
**Saved:** $TIMESTAMP

HEADER

# Git state
{
  echo "## Git State"
  BRANCH=$(git branch --show-current 2>/dev/null || echo "no git")
  echo "**Branch:** $BRANCH"
  echo ""
  echo "### Recent commits"
  echo '```'
  git log --oneline -10 2>/dev/null || echo "no git history"
  echo '```'
  echo ""
} >> "$SNAPSHOT"

# Uncommitted changes
{
  DIFF=$(git diff --stat 2>/dev/null || echo "")
  STAGED=$(git diff --cached --stat 2>/dev/null || echo "")
  if [[ -n "$DIFF" || -n "$STAGED" ]]; then
    echo "## Uncommitted Changes"
    if [[ -n "$STAGED" ]]; then
      echo "### Staged"
      echo '```'
      echo "$STAGED"
      echo '```'
    fi
    if [[ -n "$DIFF" ]]; then
      echo "### Unstaged"
      echo '```'
      echo "$DIFF"
      echo '```'
    fi
    echo ""
  fi
} >> "$SNAPSHOT"

# Active progress files
{
  echo "## Active Work"
  if [[ -d "$SDLC_DIR/_active" ]]; then
    for pf in "$SDLC_DIR/_active/"*.progress.md; do
      [[ -f "$pf" ]] || continue
      echo "### $(basename "$pf" .progress.md)"
      head -20 "$pf"
      echo "..."
      echo ""
    done
  else
    echo "No active work tracked."
  fi
  echo ""
} >> "$SNAPSHOT"

# GitHub Issues in progress (if gh available)
{
  if command -v gh &>/dev/null; then
    echo "## GitHub Issues (In Progress)"
    echo '```'
    gh issue list --label "adlc:in-progress" --limit 10 --json number,title,assignees --jq '.[] | "#\(.number) \(.title) [\(.assignees | map(.login) | join(", "))]"' 2>/dev/null || echo "Could not fetch issues"
    echo '```'
    echo ""
  fi
} >> "$SNAPSHOT"

# Agent log (last 10 entries)
{
  echo "## Recent Agent Activity"
  if [[ -f "$SDLC_DIR/agent-log.txt" ]]; then
    tail -10 "$SDLC_DIR/agent-log.txt"
  else
    echo "No agent log found."
  fi
} >> "$SNAPSHOT"

exit 0
