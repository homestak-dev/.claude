---
name: release-publish
description: Create GitHub releases and handle packer images. Covers Release Phase 5-6. GATE - requires human approval.
allowed-tools:
  - Bash(./scripts/release.sh:*)
  - Bash(gh:*)
---

# Release Publish

## Overview

Create GitHub releases and handle packer images (Phase 5-6 from `60-release.md`):
1. Handle packer images (if changed)
2. Preview release creation (dry-run)
3. **GATE: Get human approval**
4. Create GitHub releases

## When to Use

- "Create GitHub releases"
- "Publish v0.34"
- After tags are created

## IMPORTANT: Human Gate

This operation creates public releases. Always:
1. Show dry-run output first
2. Wait for explicit human approval
3. Only then execute with `--execute`

## Execution Steps

### Step 1: Check Packer Images

```bash
./scripts/release.sh packer --check
```

Determine if images changed:
- **No changes**: Skip image handling, add note to release
- **Changes**: Build and update `latest` release

### Step 2: Handle Packer Images (if needed)

If images changed:
```bash
# Build and fetch images
cd iac-driver
./run.sh --scenario packer-build-fetch --remote father

# Copy to new release
./scripts/release.sh packer --copy --source v0.34 --execute
```

If images NOT changed:
```
Note: Images unchanged. Releases will reference 'latest' release.
```

### Step 3: Dry Run

```bash
./scripts/release.sh publish --dry-run
```

Expected output:
```
Publish dry-run for v0.34

Would create releases:
  .github:      v0.34 (prerelease)
  .claude:      v0.34 (prerelease)
  homestak-dev: v0.34 (prerelease)
  site-config:  v0.34 (prerelease)
  tofu:         v0.34 (prerelease)
  ansible:      v0.34 (prerelease)
  bootstrap:    v0.34 (prerelease)
  packer:       v0.34 (prerelease, note: images in 'latest')
  iac-driver:   v0.34 (prerelease)
```

### Step 4: Human Approval Gate

Present the dry-run output and ask:

```
## Release Creation Preview

The following GitHub releases will be created:

| Repo | Version | Prerelease | Images |
|------|---------|------------|--------|
| .github | v0.34 | Yes | - |
| packer | v0.34 | Yes | See 'latest' |
| ... | ... | ... | ... |

Proceed with release creation? (yes/no)
```

### Step 5: Execute (After Approval)

**Recommended (fast, server-side):**
```bash
./scripts/release.sh publish --execute --workflow github --yes
```

**Alternative (local, slower):**
```bash
./scripts/release.sh publish --execute --workflow local --yes
```

### Step 6: Verify Releases

```bash
./scripts/release.sh verify
```

## Repository Order

Releases are created in dependency order:
1. .github
2. .claude
3. homestak-dev
4. site-config
5. tofu
6. ansible
7. bootstrap
8. packer
9. iac-driver

## Packer Release Notes

Include image status in packer release notes:

**If images NOT changed:**
```
Images: See `latest` release for current images.
```

**If images changed:**
```
Images: Included in this release.
- debian-12-custom.qcow2
- debian-13-custom.qcow2
- debian-13-pve.qcow2
```

## Output Format

```
## Release Publish: v0.34

### Packer Images
Status: No changes (using 'latest')

### Dry Run
[Show dry-run output]

### Human Approval
**Awaiting approval to proceed...**

### Execution (after approval)
| Repo | Status | URL |
|------|--------|-----|
| .github | Created | https://github.com/homestak-dev/.github/releases/tag/v0.34 |
| ... | ... | ... |

### Next Steps
1. Releases created
2. Proceed to `/release-verify`
```

## Notes

- **Always use `--workflow github`** for faster server-side processing
- **Always use `--prerelease`** until v1.0
- **Never skip the dry-run step**
- **Never proceed without human approval**
- Packer images >2GB must be split due to GitHub limits
