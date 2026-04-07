#!/usr/bin/env bash
# ============================================================================
# PreCompact hook: saves critical state before context window compaction.
#
# Writes a snapshot to .sdlc/context-snapshot.md so the agent can recover
# awareness of what was happening after compaction reduces context.
# ============================================================================

set -euo pipefail

SNAPSHOT_FILE=".sdlc/context-snapshot.md"
mkdir -p .sdlc
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

{
    echo "# Context Snapshot"
    echo "Generated: $TIMESTAMP"
    echo ""

    # --- Git State ---
    echo "## Git State"
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    echo "Branch: $BRANCH"
    echo ""
    echo "Recent commits:"
    git log --oneline -5 2>/dev/null || echo "(no git history)"
    echo ""

    # Uncommitted changes
    DIFF_STAT=$(git diff --stat 2>/dev/null || true)
    STAGED_STAT=$(git diff --cached --stat 2>/dev/null || true)
    if [[ -n "$DIFF_STAT" || -n "$STAGED_STAT" ]]; then
        echo "## Uncommitted Changes"
        if [[ -n "$STAGED_STAT" ]]; then
            echo "Staged:"
            echo '```'
            echo "$STAGED_STAT"
            echo '```'
        fi
        if [[ -n "$DIFF_STAT" ]]; then
            echo "Unstaged:"
            echo '```'
            echo "$DIFF_STAT"
            echo '```'
        fi
        echo ""
    fi

    # --- Active Milestones ---
    MILESTONE_DIRS=$(find .sdlc/milestones -maxdepth 1 -mindepth 1 -type d 2>/dev/null || true)
    if [[ -n "$MILESTONE_DIRS" ]]; then
        echo "## Active Milestones"
        for DIR in $MILESTONE_DIRS; do
            MILESTONE_ID=$(basename "$DIR")
            REGISTRY="$DIR/feature-registry.json"
            if [[ -f "$REGISTRY" ]]; then
                TOTAL=$(python3 -c "
import json
with open('$REGISTRY') as f:
    d = json.load(f)
acs = d.get('acceptance_criteria', [])
print(len(acs))
" 2>/dev/null || echo "?")
                PASSING=$(python3 -c "
import json
with open('$REGISTRY') as f:
    d = json.load(f)
acs = d.get('acceptance_criteria', [])
print(sum(1 for a in acs if a.get('passes')))
" 2>/dev/null || echo "?")
                APPROVED=$(python3 -c "
import json
with open('$REGISTRY') as f:
    d = json.load(f)
print('Yes' if d.get('spec_approved_at') else 'No')
" 2>/dev/null || echo "?")
                echo "- **$MILESTONE_ID**: $PASSING/$TOTAL ACs passing, spec approved: $APPROVED"
            else
                echo "- **$MILESTONE_ID**: no registry"
            fi
        done
        echo ""
    fi

    # --- Agent Log (last 10 entries) ---
    if [[ -f ".sdlc/agent-log.txt" ]]; then
        echo "## Recent Agent Activity"
        tail -10 .sdlc/agent-log.txt
        echo ""
    fi

    # --- Worktrees ---
    WORKTREES=$(git worktree list 2>/dev/null | grep -v "(bare)" | tail -5 || true)
    if [[ -n "$WORKTREES" ]]; then
        echo "## Active Worktrees"
        echo '```'
        echo "$WORKTREES"
        echo '```'
        echo ""
    fi

} > "$SNAPSHOT_FILE"

exit 0
