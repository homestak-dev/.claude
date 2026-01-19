---
name: release-tag
description: Create and push git tags for release. Covers Release Phase 4. GATE - requires human approval.
allowed-tools:
  - Bash(./scripts/release.sh:*)
  - Bash(git:*)
  - Bash(gh:*)
---

# Release Tag

## Overview

Create and push git tags (Phase 4 from `60-release.md`):
1. Preview tag creation (dry-run)
2. **GATE: Get human approval**
3. Create and push tags

## When to Use

- "Create tags for v0.34"
- "Tag the release"
- After validation passes

## IMPORTANT: Human Gate

This is an **irreversible operation**. Always:
1. Show dry-run output first
2. Wait for explicit human approval
3. Only then execute with `--execute`

## Execution Steps

### Step 1: Dry Run

```bash
./scripts/release.sh tag --dry-run
```

Expected output:
```
Tag dry-run for v0.34

Would create tags:
  .github:      v0.34
  .claude:      v0.34
  homestak-dev: v0.34
  site-config:  v0.34
  tofu:         v0.34
  ansible:      v0.34
  bootstrap:    v0.34
  packer:       v0.34
  iac-driver:   v0.34

Commands that would run:
  git tag -a v0.34 -m "Release v0.34"
  git push origin v0.34
```

### Step 2: Human Approval Gate

Present the dry-run output and ask:

```
## Tag Creation Preview

The following tags will be created:

| Repo | Tag | Current HEAD |
|------|-----|--------------|
| .github | v0.34 | abc1234 |
| .claude | v0.34 | def5678 |
| ... | ... | ... |

**This operation cannot be easily undone for stable releases.**

Proceed with tag creation? (yes/no)
```

### Step 3: Execute (After Approval)

```bash
./scripts/release.sh tag --execute --yes
```

Or without `--yes` for interactive confirmation:
```bash
./scripts/release.sh tag --execute
```

### Step 4: Verify Tags

```bash
for repo in .claude .github ansible bootstrap homestak-dev iac-driver packer site-config tofu; do
  echo "=== $repo ==="
  gh api repos/homestak-dev/$repo/git/refs/tags/v0.34 --jq '.ref' 2>/dev/null || echo "NOT FOUND"
done
```

## Repository Order

Tags are created in dependency order:
1. .github
2. .claude
3. homestak-dev
4. site-config
5. tofu
6. ansible
7. bootstrap
8. packer
9. iac-driver

## Output Format

```
## Release Tags: v0.34

### Dry Run
[Show dry-run output]

### Human Approval
**Awaiting approval to proceed...**

### Execution (after approval)
| Repo | Status | Tag |
|------|--------|-----|
| .github | Created | v0.34 |
| .claude | Created | v0.34 |
| homestak-dev | Created | v0.34 |
| ... | ... | ... |

### Next Steps
1. Tags created and pushed
2. Proceed to `/release-publish`
```

## Error Recovery

If tag creation fails partway through:

```bash
# Check which tags exist
for repo in .claude .github ansible bootstrap homestak-dev iac-driver packer site-config tofu; do
  gh api repos/homestak-dev/$repo/git/refs/tags/v0.34 2>/dev/null && echo "$repo: EXISTS" || echo "$repo: MISSING"
done

# For v0.x releases, tags can be reset:
./scripts/release.sh tag --reset
```

## Notes

- **Never skip the dry-run step**
- **Never proceed without human approval**
- For v0.x releases, tags can be deleted/recreated if needed
- For v1.0+, tags are permanent
- Use `--yes` flag only when user has explicitly approved
