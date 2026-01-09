#!/bin/bash
# Gather issues from all homestak-dev repositories
# Runs GitHub API calls in parallel for faster results

set -e

REPOS=(
  "homestak-dev/ansible"
  "homestak-dev/bootstrap"
  "homestak-dev/iac-driver"
  "homestak-dev/packer"
  "homestak-dev/site-config"
  "homestak-dev/tofu"
  "homestak-dev/.claude"
  "homestak-dev/.github"
  "homestak-dev/homestak-dev"
)

STATE="${1:-open}"
LABEL="${2:-}"
FORMAT="${3:-table}"

# Create temp directory for parallel results
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT


# Function to fetch issues for a single repo
fetch_issues() {
  local repo="$1"
  local state="$2"
  local label="$3"
  local outfile="$4"

  if [ -n "$label" ]; then
    gh issue list -R "$repo" --state "$state" --label "$label" \
      --json number,title,url,state,labels,assignees,createdAt,updatedAt 2>/dev/null > "$outfile" || echo "[]" > "$outfile"
  else
    gh issue list -R "$repo" --state "$state" \
      --json number,title,url,state,labels,assignees,createdAt,updatedAt 2>/dev/null > "$outfile" || echo "[]" > "$outfile"
  fi
}

# Launch all fetches in parallel
pids=()
for repo in "${REPOS[@]}"; do
  repo_name=$(basename "$repo")
  outfile="$TMPDIR/${repo_name}.json"
  fetch_issues "$repo" "$STATE" "$LABEL" "$outfile" &
  pids+=($!)
done

# Wait for all background jobs to complete
for pid in "${pids[@]}"; do
  wait "$pid" 2>/dev/null || true
done

if [ "$FORMAT" = "json" ]; then
  # JSON output - combine all repo results (use find to include dotfiles)
  find "$TMPDIR" -name "*.json" -exec cat {} + | jq -s 'add // []'
else
  # Plain table format (no borders)
  printf "## %-16s %-6s %-50s %s\n" "issue" "status" "description" "tags"

  # Max description length before truncation
  MAX_DESC=50

  # Collect all issues, sort by repo then issue number, and output
  # Repos starting with "." are sorted first (prefix with 0), others with 1
  for repo in "${REPOS[@]}"; do
    repo_name=$(basename "$repo")
    outfile="$TMPDIR/${repo_name}.json"

    # Output with sortable format: sort_prefix|repo|number|status|title|tags
    jq -r --arg repo "$repo_name" '.[] |
      (if ($repo | startswith(".")) then "0" else "1" end) + "|\($repo)|\(.number)|\(.state | ascii_downcase)|\(.title)|\([.labels[].name] | join(", "))"
    ' "$outfile" 2>/dev/null
  done | sort -t'|' -k1,1 -k2,2 -k3,3n | while IFS='|' read -r _ repo num status desc tags; do
    # Truncate description if too long
    if [ ${#desc} -gt $MAX_DESC ]; then
      desc="${desc:0:$((MAX_DESC-3))}..."
    fi
    printf "   %-15s %-6s %-50s %s\n" "$repo#$num" "$status" "$desc" "$tags"
  done

  # Count total issues
  total=$(find "$TMPDIR" -name "*.json" -exec cat {} + | jq -s 'add // [] | length')
  echo ""
  echo "Total: ${total} issues"
fi
