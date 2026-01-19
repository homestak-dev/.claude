---
name: planning-conflicts
description: Analyze file overlap between sprint issues to inform branch/merge strategy. Helps prevent rework from conflicting changes.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(gh:*)
---

# Planning Conflicts

## Overview

Analyze potential file conflicts between issues in the sprint scope to:
1. Identify files touched by multiple issues
2. Detect restructure/refactor issues that affect many files
3. Recommend implementation sequence to minimize rework
4. Suggest checkpoint/merge strategy

## When to Use

- "Will these issues conflict?"
- "What order should I implement these?"
- "Should I combine these into one PR?"
- When sprint has multiple issues in the same repo

## Inputs

The user should provide:
- List of issues with brief descriptions of expected changes
- Or issue numbers to fetch details from GitHub

## Execution Steps

### Step 1: Identify Expected File Changes

For each issue, determine which files will be modified:
- Read issue description for file references
- Check related PRs or commits
- Infer from issue scope (e.g., "add CLI flag" → likely touches main script)

### Step 2: Build Overlap Matrix

Create a matrix showing which issues touch which files:

| File | Issue #1 | Issue #2 | Issue #3 |
|------|----------|----------|----------|
| `src/cli.py` | ✓ | ✓ | |
| `CLAUDE.md` | ✓ | | ✓ |
| `templates/*.hcl` | | ✓ | ✓ |

### Step 3: Detect High-Impact Issues

Flag issues that are likely to cause conflicts:
- **Restructure issues**: Move/rename files, change directory structure
- **Refactor issues**: Touch many files for code quality
- **Schema changes**: Affect multiple consumers

These should typically be implemented first.

### Step 4: Recommend Sequence

Based on overlap analysis:

1. **Phase 1: Quick wins** - Issues with no overlap, can be done in parallel
2. **Phase 2: Foundation** - Restructure/refactor issues
3. **Phase 3: Dependent changes** - Issues that build on Phase 2

### Step 5: Suggest Merge Strategy

| Situation | Recommendation |
|-----------|----------------|
| No overlap | Parallel branches, merge independently |
| Minor overlap | Sequential branches, merge in order |
| Heavy overlap | Combined PR, implement together |
| Restructure + dependent | Restructure first, rebase others |

## Example Output

```
## Conflict Analysis for packer Sprint

### File Overlap

| File | #19 (restructure) | #6 (SSH keys) | #27 (AppArmor) |
|------|-------------------|---------------|----------------|
| templates/*.pkr.hcl | ✓ | ✓ | ✓ |
| scripts/cleanup.sh | ✓ | | |
| shared/cloud-init/* | | ✓ | |

### High-Impact Issues
- #19 (restructure) - Moves templates to per-template directories
  - **Must complete first** - others will need rebase

### Recommended Sequence

**Phase 1: Quick wins (no conflicts)**
- None - all issues touch template files

**Phase 2: Foundation**
1. #19 - Directory restructure → merge

**Phase 3: Dependent changes (on new structure)**
2. #6 - SSH key handling
3. #27 - AppArmor documentation

### Checkpoint Strategy
- Merge #19 before starting #6 and #27
- #6 and #27 can proceed in parallel after #19 merges
```

## Notes

- This analysis prevents scenarios where restructure invalidates parallel work
- Consider combining heavily-overlapping issues into single PR
- Update analysis if scope changes during sprint
