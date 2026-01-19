---
name: merge-pr
description: Create PR with template, linked issues, and checklist. Streamlines the merge phase by generating properly formatted PRs.
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Read
---

# Merge PR

## Overview

Create a pull request with:
1. Properly formatted title and description
2. Linked issues (Closes #N)
3. PR checklist from `50-merge.md`
4. Testing documentation

## When to Use

- "Create PR for this branch"
- "Open PR to close issue #45"
- When ready to merge validated changes
- After implementation and validation phases

## Inputs

Required:
- **Branch**: Feature branch name (or current branch)
- **Issues**: Issue number(s) to close (e.g., "#45" or "#45, #46")

Optional:
- **Title**: PR title (defaults to branch-derived title)
- **Summary**: Brief description of changes

## Execution Steps

### Step 1: Verify Branch State

```bash
# Check current branch
BRANCH=$(git branch --show-current)
echo "Current branch: $BRANCH"

# Verify not on master
if [ "$BRANCH" = "master" ]; then
  echo "ERROR: Cannot create PR from master"
  exit 1
fi

# Check if ahead of master
AHEAD=$(git rev-list master..$BRANCH --count)
if [ "$AHEAD" = "0" ]; then
  echo "ERROR: Branch has no commits ahead of master"
  exit 1
fi
echo "Branch is $AHEAD commits ahead of master"
```

### Step 2: Check Remote Status

```bash
# Ensure branch is pushed
git push -u origin $BRANCH 2>/dev/null || true

# Check for existing PR
EXISTING=$(gh pr list --head $BRANCH --json number --jq '.[0].number')
if [ -n "$EXISTING" ]; then
  echo "NOTE: PR #$EXISTING already exists for this branch"
fi
```

### Step 3: Generate PR Body

Use the PR template from `50-merge.md`:

```markdown
## Summary
<user-provided summary or generated from commits>

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Refactoring
- [ ] Documentation
- [ ] Other: <!-- describe -->

## Changes
<bullet list of key changes>

## Testing
<validation performed>

## Related Issues
Closes #<issue-number>

## Checklist
- [ ] Tests pass locally
- [ ] Integration test scenario identified and passes
- [ ] CHANGELOG.md updated (if user-facing change)
- [ ] CLAUDE.md updated (if architecture changed)
```

### Step 4: Create PR

```bash
gh pr create \
  --title "<type>(<scope>): <summary>" \
  --body "$(cat <<'EOF'
<generated body>
EOF
)"
```

### Step 5: Return PR URL

Output the created PR URL for reference.

## PR Title Format

Follow conventional commit format:
- `fix(<scope>): <summary>` - Bug fixes
- `feat(<scope>): <summary>` - New features
- `docs(<scope>): <summary>` - Documentation
- `refactor(<scope>): <summary>` - Refactoring
- `test(<scope>): <summary>` - Tests

Examples:
- `feat(cli): Add --dry-run flag to release command`
- `fix(config): Handle missing node config gracefully`
- `docs(lifecycle): Separate retrospective into Phase 70`

## Example Usage

**User:** Create PR for this branch, closes #129 and #130

**Assistant:**
1. Verify branch state (feature/129-130-lifecycle-skills)
2. Push branch if needed
3. Generate PR body with linked issues
4. Create PR:
   ```bash
   gh pr create \
     --title "feat(skills): Add lifecycle skills for all phases" \
     --body "..."
   ```
5. Return: "Created PR: https://github.com/homestak-dev/homestak-dev/pull/132"

## PR Checklist (from 50-merge.md)

Include in every PR description:

```markdown
## PR Readiness Checklist

- [ ] Feature tested end-to-end (not just unit tests)
- [ ] External tool assumptions verified (test actual CLI behavior)
- [ ] CHANGELOG entry in this PR
- [ ] CLAUDE.md updated if architecture changed
- [ ] Performance claims measured (before/after timing)
- [ ] Prerequisites documented (configs, artifacts, permissions)
- [ ] Integration test scenario identified
```

## Notes

- Always verify branch has commits before creating PR
- Link issues with "Closes #N" to auto-close on merge
- Don't link release planning issues in scope PRs (prevents premature close)
- PR title should match primary commit message format
