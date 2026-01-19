---
name: release-verify
description: Verify releases and generate After Action Report. Covers Release Phase 7-8. Fully automated.
allowed-tools:
  - Bash(./scripts/release.sh:*)
  - Bash(gh:*)
  - Bash(curl:*)
  - Read
---

# Release Verify

## Overview

Verify releases and generate AAR (Phase 7-8 from `60-release.md`):
1. Verify all releases exist
2. Check packer images (if applicable)
3. Run post-release smoke test
4. Generate and post After Action Report

This skill is **fully automated** - no human gate required.

## When to Use

- "Verify the release"
- "Check all releases exist"
- "Generate AAR for v0.34"
- After releases are published

## Execution Steps

### Step 1: Verify Releases Exist

```bash
./scripts/release.sh verify
```

Expected output:
```
Verifying v0.34 releases...

| Repo | Release | Assets |
|------|---------|--------|
| .github | v0.34 | 0 |
| .claude | v0.34 | 0 |
| homestak-dev | v0.34 | 0 |
| site-config | v0.34 | 0 |
| tofu | v0.34 | 0 |
| ansible | v0.34 | 0 |
| bootstrap | v0.34 | 0 |
| packer | v0.34 | 0 (images in 'latest') |
| iac-driver | v0.34 | 0 |

All releases verified.
```

### Step 2: Post-Release Smoke Test

Test bootstrap installation:

```bash
# On a clean system (or container)
curl -fsSL https://raw.githubusercontent.com/homestak-dev/bootstrap/v0.34/install.sh | bash
homestak --version
# Should show v0.34
```

If testing locally:
```bash
# Verify install.sh is accessible
curl -sI https://raw.githubusercontent.com/homestak-dev/bootstrap/v0.34/install.sh | head -1
# Should return: HTTP/2 200
```

### Step 3: Verify Scope Issues Closed

```bash
# Get scope from release issue
ISSUE=131
gh issue view $ISSUE --repo homestak-dev/homestak-dev --json body | \
  jq -r '.body' | grep -oE '#[0-9]+' | sort -u

# Check each issue is closed
# Close any that were missed
```

### Step 4: Generate After Action Report

Use data from release state and verification:

```markdown
## After Action Report: v0.34

### Summary
- **Version:** v0.34
- **Theme:** Lifecycle Skills
- **Started:** 2026-01-19 10:00
- **Completed:** 2026-01-19 15:30
- **Duration:** 5h 30m

### Planned vs Actual
| Aspect | Planned | Actual |
|--------|---------|--------|
| Scope items | 2 | 2 |
| Repos changed | 1 | 1 |
| Validation | vm-roundtrip | vm-roundtrip |

### Deviations
- None

### Issues Discovered
- None

### Artifacts Delivered
| Repo | Tag | Release | Assets |
|------|-----|---------|--------|
| homestak-dev | v0.34 | Yes | 0 |
| ... | ... | ... | ... |

### Validation Report
See comment above for full validation results.
```

### Step 5: Post AAR to Issue

```bash
ISSUE=131
gh issue comment $ISSUE --repo homestak-dev/homestak-dev --body "$(cat <<'EOF'
## After Action Report
[Generated AAR content]
EOF
)"
```

## Output Format

```
## Release Verification: v0.34

### Release Status
| Repo | Status | Assets |
|------|--------|--------|
| .github | OK | 0 |
| .claude | OK | 0 |
| ... | ... | ... |

### Smoke Test
- install.sh accessible: OK
- (Manual bootstrap test recommended on clean system)

### Scope Issues
- #129: Closed
- #130: Closed

### After Action Report
Posted to issue #131

### Next Steps
1. AAR posted
2. Proceed to `/release-housekeeping`
```

## Notes

- This phase is fully automated
- AAR uses data from release state file
- Smoke test on clean system is optional but recommended
- Always verify scope issues are closed before proceeding
