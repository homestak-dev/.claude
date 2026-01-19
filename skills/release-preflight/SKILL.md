---
name: release-preflight
description: Check release prerequisites including repo health, tags, CHANGELOGs, and CLAUDE.md files. Covers Release Phase 0-1.
allowed-tools:
  - Bash(git:*)
  - Bash(gh:*)
  - Bash(gita:*)
  - Bash(ls:*)
  - Bash(grep:*)
  - Read
---

# Release Preflight

## Overview

Verify release prerequisites (Phase 0-1 from `60-release.md`):
1. Release plan refresh (Phase 0)
2. Pre-flight checks (Phase 1)

## When to Use

- Starting a release
- "Check if repos are ready for release"
- "Run preflight for v0.34"
- After `release.sh init`

## Execution Steps

### Phase 0: Release Plan Refresh

1. **Verify prerequisite releases** - Check previous version tags exist
2. **Compare against methodology** - Reference `60-release.md`
3. **Update checklists** - Ensure alignment with current process

### Phase 1: Pre-flight Checks

#### 1.1 Identify Release Issue

```bash
# Find open release issues
gh issue list --repo homestak-dev/homestak-dev --label release --state open
```

#### 1.2 Git Fetch All Repos

```bash
gita fetch
```

#### 1.3 Check Working Trees Clean

```bash
gita shell "git status --porcelain"
# Should return empty for all repos
```

#### 1.4 Check No Existing Tags

```bash
VERSION=0.34  # Set target version
for repo in .claude .github ansible bootstrap homestak-dev iac-driver packer site-config tofu; do
  gh api repos/homestak-dev/$repo/git/refs/tags/v${VERSION} 2>/dev/null && \
    echo "WARNING: $repo has tag v${VERSION}" || echo "OK: $repo no tag"
done
```

#### 1.5 Check Secrets Decrypted

```bash
ls site-config/secrets.yaml 2>/dev/null && echo "OK: secrets decrypted" || \
  echo "FAIL: secrets.yaml missing - run 'make decrypt' in site-config"
```

#### 1.6 CLAUDE.md Review

Check each repo's CLAUDE.md reflects current state:

**Meta repos:**
- [ ] .github - org templates, PR defaults
- [ ] .claude - skills, settings
- [ ] homestak-dev - workspace structure, documentation index

**Core repos:**
- [ ] site-config - schema, defaults, file structure
- [ ] iac-driver - scenarios, actions, ConfigResolver
- [ ] tofu - modules, variables, workflow
- [ ] packer - templates, build workflow
- [ ] ansible - playbooks, roles, collections
- [ ] bootstrap - CLI, installation

#### 1.7 Check CHANGELOGs

Verify each repo has unreleased content or is unchanged:

```bash
for repo in .claude .github ansible bootstrap homestak-dev iac-driver packer site-config tofu; do
  echo "=== $repo ==="
  head -20 $repo/CHANGELOG.md 2>/dev/null | grep -A5 "Unreleased"
done
```

## Output Format

```
## Release Preflight: v0.34

### Phase 0: Release Plan Refresh
- [x] Previous release (v0.33) tags exist
- [x] Checklist aligned with 60-release.md

### Phase 1: Pre-flight
| Check | Status | Notes |
|-------|--------|-------|
| Release issue | OK | #131 |
| Git fetch | OK | All repos fetched |
| Working trees | OK | All clean |
| No existing tags | OK | v0.34 not found |
| Secrets decrypted | OK | secrets.yaml exists |
| CLAUDE.md review | PENDING | Manual review needed |
| CHANGELOGs | OK | Unreleased content found |

### Next Steps
1. Review CLAUDE.md files for accuracy
2. Proceed to `/release-changelog`
```

## Using release.sh

This skill wraps `release.sh preflight`:

```bash
./scripts/release.sh preflight
```

The CLI performs the same checks programmatically.

## Notes

- Run this after `release.sh init --version X.Y --issue N`
- CLAUDE.md review requires manual verification
- Packer build smoke test only needed if images changed
