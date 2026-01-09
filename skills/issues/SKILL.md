---
name: issues
description: Gather and analyze GitHub issues across all homestak-dev repositories. Use when collecting issues inventory, filtering by labels or status, generating issue reports, or tracking open issues across the homestak-dev organization.
allowed-tools:
  - Bash(gh:*)
  - Bash(jq:*)
  - Read
  - Grep
---

# Issues

## Overview

Collect and analyze GitHub issues across all repositories in the homestak-dev organization using the GitHub CLI (`gh`).

## Repositories Covered

- .claude
- .github
- ansible
- bootstrap
- homestak-dev
- iac-driver
- packer
- site-config
- tofu

## When to use this Skill

- "Show me all open issues across homestak repos"
- "What's the issue count for each repository?"
- "Find all issues labeled 'bug' in homestak"
- "Generate a report of high-priority issues"
- "Export all issues to review"

## Quick Start

Just ask me to gather issues from homestak repos. You can optionally specify:
1. Filters (labels, state, assignee, milestone)
2. Output format (JSON if requested)
3. Specific repos (or I'll check all 9)

## Examples

### Simple inventory
```
Take inventory of open issues across homestak repos
```

### With filters
```
Find all issues labeled "bug" or "critical" in homestak
```

### Specific repos
```
Show me issues in ansible and iac-driver repos
```

### With counts
```
Count open vs closed issues by repository in homestak
```

## Supported filters

- **state**: open, closed, all (default: open)
- **labels**: comma-separated label names
- **assignee**: GitHub username
- **milestone**: milestone title
- **author**: issue creator

## Execution

Always use the helper script to gather issues (runs all repos in parallel):

```bash
# Default: open issues
./.claude/skills/issues/scripts/gather-all-issues.sh

# Closed issues
./.claude/skills/issues/scripts/gather-all-issues.sh closed

# Filter by label
./.claude/skills/issues/scripts/gather-all-issues.sh open "bug"

# JSON output
./.claude/skills/issues/scripts/gather-all-issues.sh open "" json
```

The script outputs the correct plain text format automatically. Do not make individual `gh` calls per repo.

## Prerequisites

GitHub CLI must be installed and authenticated:
```bash
gh auth status
```

If not authenticated, use `gh auth login`.

## Tips

- Default behavior is to check all 9 repos for open issues
- Use labels to filter by priority or type
- Combine with date filters for weekly/monthly reviews
- Export to JSON for custom analysis
