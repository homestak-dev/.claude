---
name: planning-deps
description: Analyze cross-repo dependencies for sprint scope. Use during planning to identify implementation order and dependency chains.
allowed-tools:
  - Bash(gh:*)
  - Read
  - Grep
  - Glob
---

# Planning Dependencies

## Overview

Analyze cross-repository dependencies for issues in the sprint scope to:
1. Map dependency chains between repos
2. Identify correct implementation order
3. Flag blocking dependencies

## When to Use

- "What's the dependency order for these issues?"
- "Which repo should I implement first?"
- "Are there cross-repo dependencies in this sprint?"
- During planning phase when multiple repos are involved

## Inputs

The user should provide:
- List of issues to analyze (e.g., "iac-driver#45, bootstrap#23, tofu#12")
- Or repos to examine (e.g., "iac-driver, bootstrap")

## Repository Dependency Order

Per `docs/lifecycle/00-overview.md`, releases follow this dependency order:

```
.github → .claude → homestak-dev → site-config → tofu → ansible → bootstrap → packer → iac-driver
```

**Downstream depends on upstream.** Changes to `site-config` may affect all repos to its right.

## Execution Steps

### Step 1: Identify Repos Involved

From the issue list, determine which repos are affected.

### Step 2: Check Cross-Repo References

For each repo, look for:
- Import statements referencing sibling repos
- ConfigResolver usage (iac-driver depends on site-config schema)
- Ansible collection references
- Tofu module references

```bash
# Example: Check if iac-driver references site-config schema
grep -r "site-config" iac-driver/src/
```

### Step 3: Map to Dependency Order

Compare affected repos against the canonical order:

| Position | Repo | Depends On |
|----------|------|------------|
| 1 | .github | - |
| 2 | .claude | .github |
| 3 | homestak-dev | .github, .claude |
| 4 | site-config | homestak-dev |
| 5 | tofu | site-config |
| 6 | ansible | site-config, tofu |
| 7 | bootstrap | ansible, tofu |
| 8 | packer | bootstrap |
| 9 | iac-driver | all above |

### Step 4: Identify Implementation Sequence

Report:
1. Which repo changes should be implemented first
2. Any blocking dependencies
3. Whether PRs can be merged in parallel or must be sequential

## Example Output

```
## Dependency Analysis for v0.35

### Repos Affected
- site-config (schema change)
- iac-driver (ConfigResolver update)
- tofu (new variable)

### Implementation Order
1. site-config#45 - Schema change (no dependencies)
2. tofu#12 - New variable (depends on site-config schema)
3. iac-driver#67 - ConfigResolver (depends on both)

### Notes
- site-config PR must merge before tofu PR
- iac-driver can be developed in parallel but merge last
```

## Notes

- This is an analysis skill; it doesn't make changes
- Focus on functional dependencies, not just file overlap
- Consider ConfigResolver as a key integration point
