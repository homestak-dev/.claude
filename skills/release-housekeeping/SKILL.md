---
name: release-housekeeping
description: Clean up branches after release. Covers Release Phase 9.
allowed-tools:
  - Bash(git:*)
  - Bash(gita:*)
  - Bash(cd:*)
---

# Release Housekeeping

## Overview

Clean up branches after release (Phase 9 from `60-release.md`):
1. Delete merged local branches
2. Prune stale remote tracking refs
3. Check for unmerged branches

## When to Use

- "Clean up branches after release"
- "Run housekeeping"
- After AAR is posted, before retrospective

## Execution Steps

### Step 1: For Each Repository

```bash
for repo in .claude .github ansible bootstrap homestak-dev iac-driver packer site-config tofu; do
  echo "=== $repo ==="
  cd ~/homestak-dev/$repo

  # Delete merged local branches
  git branch --merged | grep -v master | xargs -r git branch -d

  # Prune stale remote tracking refs
  git remote prune origin

  # Check for unmerged branches
  for branch in $(git branch -r | grep -v HEAD | grep -v master); do
    if [[ -n "$(git diff master..$branch 2>/dev/null)" ]]; then
      echo "UNMERGED: $branch"
    fi
  done

  cd -
done
```

### Step 2: Using gita (Parallel)

```bash
# Check branch status across all repos
gita shell "git branch -a"

# Prune all repos
gita shell "git remote prune origin"
```

### Step 3: Verify Clean State

```bash
gita ll
# All repos should show clean status
```

## Output Format

```
## Release Housekeeping: v0.34

### Branch Cleanup
| Repo | Deleted | Pruned | Unmerged |
|------|---------|--------|----------|
| .github | 0 | 0 | 0 |
| .claude | 0 | 0 | 0 |
| homestak-dev | 1 (feature/129-130-lifecycle-skills) | 0 | 0 |
| ... | ... | ... | ... |

### Notes
- Branches may show as "ahead" after squash/rebase merge
- Use `git diff master..branch` to verify actual unmerged content

### Repository Settings Reminder
Enable "Automatically delete head branches" in GitHub repo settings
to auto-cleanup after PR merge.

### Next Steps
1. Branch cleanup complete
2. Proceed to Phase 70 (Retrospective)
```

## Important Notes

### Squash/Rebase Merged Branches

Branches may show as "ahead" by commit count even when content was merged via squash/rebase. Use `git diff` to verify:

```bash
# Check if branch has actual differences from master
git diff master..origin/feature-branch

# If empty output, branch can be safely deleted
git push origin --delete feature-branch
```

### Auto-Delete Setting

Recommend enabling repository setting:
- Settings → General → Pull Requests
- Check "Automatically delete head branches"

## Notes

- Housekeeping is done before Retrospective (moved in v0.24)
- This allows any cleanup issues to be captured in retrospective
- Remote branches deleted via PR merge won't appear locally until pruned
