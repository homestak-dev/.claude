---
name: validate-run
description: Run iac-driver validation scenario and capture results. Use during validation phase to execute integration tests.
allowed-tools:
  - Bash(cd:*)
  - Bash(./run.sh:*)
  - Bash(cat:*)
  - Bash(ls:*)
  - Read
---

# Validate Run

## Overview

Execute an iac-driver validation scenario and:
1. Run the specified scenario
2. Capture the test report
3. Format results summary
4. Optionally post results to release issue

## When to Use

- "Run vm-roundtrip on father"
- "Execute validation tests"
- "Test the release on father"
- During validation phase before tagging

## Inputs

Required:
- **Scenario**: Test scenario name (e.g., `vm-roundtrip`, `nested-pve-roundtrip`)
- **Host**: Target PVE host (e.g., `father`, `mother`)

Optional:
- **Context file**: Path for context persistence between runs
- **Issue**: Release issue number to post results

## Available Scenarios

| Scenario | Duration | Purpose |
|----------|----------|---------|
| `vm-roundtrip` | ~2 min | Quick validation (provision → boot → verify → destroy) |
| `nested-pve-roundtrip` | ~9 min | Full stack (including PVE installation) |
| `vm-constructor` | ~1.5 min | Deploy VM only (no destroy) |
| `vm-destructor` | ~30 sec | Destroy existing VM |

## Execution Steps

### Step 1: Run Scenario

```bash
cd iac-driver
./run.sh --scenario <scenario> --host <host> --verbose
```

Example:
```bash
./run.sh --scenario vm-roundtrip --host father --verbose
```

### Step 2: Locate Report

Reports are generated in `iac-driver/reports/` with format:
```
YYYYMMDD-HHMMSS.{passed|failed}.{md|json}
```

```bash
# Find most recent report
ls -t iac-driver/reports/*.md | head -1
```

### Step 3: Read Report Content

```bash
cat iac-driver/reports/<latest-report>.md
```

### Step 4: Format Summary

Extract key information:
- Scenario name
- Pass/fail status
- Duration
- Phase breakdown

Example summary:
```
## Validation Results

**Scenario:** vm-roundtrip
**Host:** father
**Status:** PASSED
**Duration:** 1m 47s

### Phase Results
| Phase | Status | Duration |
|-------|--------|----------|
| ensure_image | passed | 2s |
| provision_vm | passed | 45s |
| start_vm | passed | 3s |
| wait_ip | passed | 32s |
| verify_ssh | passed | 5s |
| destroy_vm | passed | 20s |

**Report:** iac-driver/reports/20260119-143052.passed.md
```

### Step 5: Post to Issue (Optional)

If issue number provided:
```bash
gh issue comment <issue> --repo homestak-dev/homestak-dev --body "$(cat <<'EOF'
## Validation Results
...
EOF
)"
```

## Example Usage

**User:** Run vm-roundtrip validation on father and post to issue #131

**Assistant:**
1. Execute: `cd iac-driver && ./run.sh --scenario vm-roundtrip --host father --verbose`
2. Wait for completion
3. Read report from `reports/`
4. Format summary
5. Post to issue #131
6. Report: "Validation passed. Results posted to #131"

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| "API token not found" | Missing/wrong token | Run `/validate-prereqs` first |
| "Image not found" | Missing packer images | Publish images or download from release |
| "Connection refused" | PVE not accessible | Check network, PVE status |
| "Nested virt disabled" | Hardware config | Enable nested virt for nested-pve scenarios |

## Notes

- Always run `/validate-prereqs` before this skill
- Reports are retained in `iac-driver/reports/` for audit
- Use `--verbose` flag for detailed output during execution
- Context files enable running constructor/destructor separately
