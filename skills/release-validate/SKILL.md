---
name: release-validate
description: Run integration tests before tagging. Covers Release Phase 3.
allowed-tools:
  - Bash(./scripts/release.sh:*)
  - Bash(cd:*)
  - Bash(./run.sh:*)
  - Bash(cat:*)
  - Bash(ls:*)
  - Read
---

# Release Validate

## Overview

Run integration tests before tagging (Phase 3 from `60-release.md`):
1. Ensure secrets are decrypted
2. Run validation scenario
3. Capture and attach report

## When to Use

- "Run validation for release"
- "Test before tagging"
- After CHANGELOGs are updated

## Prerequisite Check

Before validation:
- [ ] Preflight checks passed (`/release-preflight`)
- [ ] CHANGELOGs updated (`/release-changelog`)
- [ ] Secrets decrypted (`site-config/secrets.yaml` exists)

## Execution Steps

### Step 1: Verify Secrets Decrypted

```bash
if [ ! -f site-config/secrets.yaml ]; then
  echo "ERROR: Secrets not decrypted"
  echo "Run: cd site-config && make decrypt"
  exit 1
fi
```

### Step 2: Run Validation

**Using release.sh (recommended):**

```bash
./scripts/release.sh validate --scenario vm-roundtrip --host father
```

**Manual execution:**

```bash
cd iac-driver
./run.sh --scenario vm-roundtrip --host father --verbose
```

### Step 3: Check Results

```bash
# Find latest report
REPORT=$(ls -t iac-driver/reports/*.md 2>/dev/null | head -1)
if [ -n "$REPORT" ]; then
  echo "Report: $REPORT"
  cat "$REPORT"
fi
```

### Step 4: Attach to Release Issue

```bash
# Get issue number from release state
ISSUE=$(jq -r '.issue' .release-state.json)

# Post report as comment
gh issue comment $ISSUE --repo homestak-dev/homestak-dev --body "$(cat <<EOF
## Validation Report

**Scenario:** vm-roundtrip
**Host:** father
**Status:** PASSED

$(cat "$REPORT")
EOF
)"
```

## Validation Scenarios

| Scenario | When to Use | Duration |
|----------|-------------|----------|
| `vm-roundtrip` | Default, most releases | ~2 min |
| `nested-pve-roundtrip` | PVE install changes, full stack | ~9 min |
| Skip validation | Non-functional changes only | 0 min |

### Non-Functional Changes Pattern

When release scope is **purely non-functional** (test infrastructure, lint fixes, documentation only), validation can be skipped with explicit acknowledgment:

**Criteria for skipping:**
- No changes to iac-driver scenarios or actions
- No changes to tofu modules or environments
- No changes to ansible playbooks or roles
- No changes to packer templates
- No changes to bootstrap install process
- Changes limited to: test files, lint configs, documentation, CLAUDE.md

**How to skip:**
```bash
# Tag command will block - use --force with explicit reason
./scripts/release.sh tag --execute --force
```

**In the AAR, document:** "Validation skipped: scope limited to test/lint/docs changes"

## Output Format

```
## Release Validation: v0.34

**Scenario:** vm-roundtrip
**Host:** father
**Status:** PASSED
**Duration:** 1m 52s

### Phase Results
| Phase | Status | Duration |
|-------|--------|----------|
| ensure_image | passed | 2s |
| provision_vm | passed | 48s |
| start_vm | passed | 3s |
| wait_ip | passed | 35s |
| verify_ssh | passed | 4s |
| destroy_vm | passed | 20s |

### Report Location
`iac-driver/reports/20260119-150000.passed.md`

### Next Steps
1. Report attached to issue #131
2. Proceed to `/release-tag`
```

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| "Validation not initialized" | No release state | Run `release.sh init` first |
| "API token error" | Missing/wrong token | Check site-config secrets |
| "Image not found" | Missing packer image | Run `./publish.sh` in packer |
| Scenario fails | Infrastructure issue | Debug with `--verbose`, fix and retry |

## Notes

- Validation is a hard gate - do not proceed to tagging if it fails
- Always attach report to release issue for audit trail
- vm-roundtrip is sufficient for most releases
- Use nested-pve-roundtrip when PVE installation is in scope
