---
name: validate-prereqs
description: Verify validation host is ready for integration tests. Checks node config, API tokens, secrets, packer images, and nested virtualization.
allowed-tools:
  - Bash(ls:*)
  - Bash(cat:*)
  - Bash(grep:*)
  - Bash(test:*)
  - Read
---

# Validate Prerequisites

## Overview

Verify that a host is ready for integration testing by checking:
1. Node configuration exists
2. API token is configured
3. Secrets are decrypted
4. Packer images are available
5. Nested virtualization is enabled (if needed)

## When to Use

- Before running integration tests
- "Is the host ready for validation?"
- "Check prerequisites for testing on father"
- When validation fails with config errors

## Inputs

- **Hostname** (optional): Target host to check (defaults to current hostname)

## Prerequisites Checked

| Prerequisite | Check | Remediation |
|--------------|-------|-------------|
| Node config | `site-config/nodes/{host}.yaml` exists | Run `make node-config` on host |
| API token | Token in `secrets.yaml` for host | Run `pveum user token add`, update secrets |
| Secrets decrypted | `secrets.yaml` exists (not `.enc` only) | Run `make decrypt` in site-config |
| Packer images | Images in `/var/lib/vz/template/iso/` | Run `./publish.sh` or download from release |
| Nested virt | `/sys/module/kvm_intel/parameters/nested` = Y | Enable in BIOS/hypervisor |

## Execution Steps

### Step 1: Determine Target Host

```bash
HOST="${1:-$(hostname)}"
echo "Checking prerequisites for: $HOST"
```

### Step 2: Check Node Configuration

```bash
if [ -f "site-config/nodes/${HOST}.yaml" ]; then
  echo "OK: Node config exists"
else
  echo "FAIL: Missing site-config/nodes/${HOST}.yaml"
  echo "  Fix: Run 'make node-config' on the host"
fi
```

### Step 3: Check API Token

```bash
if [ -f "site-config/secrets.yaml" ]; then
  if grep -q "api_tokens:" site-config/secrets.yaml && \
     grep -q "${HOST}:" site-config/secrets.yaml; then
    echo "OK: API token found"
  else
    echo "FAIL: API token not found for $HOST"
    echo "  Fix: Run 'pveum user token add root@pam homestak --privsep 0'"
    echo "       Add token to site-config/secrets.yaml"
  fi
else
  echo "FAIL: secrets.yaml not found (not decrypted?)"
  echo "  Fix: Run 'make decrypt' in site-config/"
fi
```

### Step 4: Check Packer Images

```bash
IMAGES=$(ls /var/lib/vz/template/iso/debian-*-custom.img 2>/dev/null | wc -l)
if [ "$IMAGES" -gt 0 ]; then
  echo "OK: Found $IMAGES packer images"
  ls /var/lib/vz/template/iso/debian-*-custom.img
else
  echo "FAIL: No packer images found"
  echo "  Fix: Run './publish.sh' in packer/ or download from release"
fi
```

### Step 5: Check Nested Virtualization

```bash
if [ -f /sys/module/kvm_intel/parameters/nested ]; then
  NESTED=$(cat /sys/module/kvm_intel/parameters/nested)
  if [ "$NESTED" = "Y" ] || [ "$NESTED" = "1" ]; then
    echo "OK: Nested virtualization enabled"
  else
    echo "WARN: Nested virtualization disabled"
    echo "  Note: Only required for nested-pve scenarios"
  fi
else
  echo "WARN: Cannot check nested virtualization (not on Intel?)"
fi
```

### Step 6: Summary

Output overall status:

```
## Prerequisite Check Summary

Host: father
Status: READY / NOT READY

| Check | Status | Action |
|-------|--------|--------|
| Node config | OK | - |
| API token | OK | - |
| Secrets | OK | - |
| Packer images | OK | 3 images |
| Nested virt | OK | - |
```

## Example Output

```
Checking prerequisites for: father

OK: Node config exists (site-config/nodes/father.yaml)
OK: API token found
OK: Secrets decrypted
OK: Found 3 packer images
  - debian-12-custom.img
  - debian-13-custom.img
  - debian-13-pve.img
OK: Nested virtualization enabled

Status: READY for integration testing
```

## Notes

- Run this before `validate-run` to catch config issues early
- Nested virtualization only required for `nested-pve-*` scenarios
- API token issues are the most common cause of validation failures
