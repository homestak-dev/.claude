---
name: release-changelog
description: Update CHANGELOGs for release by moving Unreleased content to versioned headers. Covers Release Phase 2.
allowed-tools:
  - Edit
  - Read
  - Bash(git:*)
  - Bash(date:*)
---

# Release CHANGELOG

## Overview

Update CHANGELOGs for the release (Phase 2 from `60-release.md`):
1. Move `## Unreleased` content to versioned header
2. Add release date
3. Follow repository dependency order

## When to Use

- "Update CHANGELOGs for v0.34"
- "Prepare CHANGELOGs for release"
- After preflight checks pass

## Repository Order

Update CHANGELOGs in dependency order:

1. .github
2. .claude
3. homestak-dev
4. site-config
5. tofu
6. ansible
7. bootstrap
8. packer
9. iac-driver

## CHANGELOG Format

Transform from:
```markdown
## Unreleased

### Features
- Add foo capability (#123)

### Bug Fixes
- Fix bar issue (#124)
```

To:
```markdown
## Unreleased

## v0.34 - 2026-01-19

### Features
- Add foo capability (#123)

### Bug Fixes
- Fix bar issue (#124)
```

## Execution Steps

### Step 1: Get Current Date

```bash
DATE=$(date +%Y-%m-%d)
echo "Release date: $DATE"
```

### Step 2: For Each Repository

Read the CHANGELOG.md and identify content under `## Unreleased`.

If there is content:
1. Keep the `## Unreleased` header (empty)
2. Add new versioned header below: `## vX.Y - YYYY-MM-DD`
3. Move all content under the versioned header

If no content under Unreleased:
- No changes needed (repo unchanged this release)

### Step 3: Use Edit Tool

For each repo with changes:

```
Edit: CHANGELOG.md
old_string: |
  ## Unreleased

  ### Features
  - Add foo capability (#123)
new_string: |
  ## Unreleased

  ## v0.34 - 2026-01-19

  ### Features
  - Add foo capability (#123)
```

### Step 4: Verify Changes

```bash
git diff */CHANGELOG.md
```

## Example Output

```
## CHANGELOG Updates for v0.34

| Repo | Status | Changes |
|------|--------|---------|
| .github | No changes | - |
| .claude | Updated | Added skills table |
| homestak-dev | Updated | Lifecycle restructure |
| site-config | No changes | - |
| tofu | No changes | - |
| ansible | No changes | - |
| bootstrap | No changes | - |
| packer | No changes | - |
| iac-driver | No changes | - |

### Next Steps
1. Review changes: `git diff */CHANGELOG.md`
2. Proceed to `/release-validate`
```

## CHANGELOG Entry Guidelines

Per `30-implementation.md`:

- **Add** - New feature or capability
- **Fix** - Bug fix
- **Change** - Modification to existing behavior
- **Remove** - Removed feature
- **Deprecate** - Feature marked for future removal

Always include issue reference: `(#123)`

## Notes

- Don't commit yet - changes will be committed with tags
- Repos with no Unreleased content are skipped
- Empty Unreleased section is intentional (ready for next release)
- Use Edit tool for precise changes (not file overwrites)
