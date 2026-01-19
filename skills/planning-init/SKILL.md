---
name: planning-init
description: Initialize release planning by loading lifecycle context and creating the release planning issue. Use at the start of each sprint/release cycle.
allowed-tools:
  - Bash(gh:*)
  - Read
  - Glob
---

# Planning Init

## Overview

Initialize the planning phase for a new release by:
1. Loading lifecycle documentation into context
2. Creating a release planning issue from template
3. Outputting the planning checklist for reference

This skill addresses context compaction issues by ensuring lifecycle docs are fresh in context at sprint start.

## When to Use

- Starting a new release cycle
- "Initialize v0.X release planning"
- "Start planning for the next sprint"
- "Create release issue for v0.X"

## Inputs

The user should provide:
- **Version**: Release version (e.g., "0.34")
- **Theme**: Release theme/title (e.g., "Lifecycle Skills")
- **Scope**: List of issues to include (e.g., "#129, #130")

## Execution Steps

### Step 1: Load Lifecycle Context

Read the following files to ensure process documentation is in context:

```
docs/lifecycle/00-overview.md   # Work types, phase matrix, multi-repo structure
docs/lifecycle/10-planning.md   # Planning activities, checklist
```

### Step 2: Load Release Issue Template

Read the template:

```
docs/templates/release-issue.md
```

### Step 3: Create Release Issue

Use `gh issue create` with the populated template:

```bash
gh issue create --repo homestak-dev/homestak-dev \
  --title "vX.Y Release Planning - Theme" \
  --label "release" \
  --body "$(cat <<'EOF'
# Populated template content here
EOF
)"
```

### Step 4: Output Planning Checklist

After creating the issue, output the planning checklist from `10-planning.md`:

```
## Checklist: Planning Complete

- [ ] Release plan issue created with scope
- [ ] All items classified by work type
- [ ] Acceptance criteria identified for each item
- [ ] Effort estimates assigned
- [ ] Dependencies mapped
- [ ] Branch/merge strategy analyzed (if multi-issue sprint)
- [ ] Issue-level planning documented
- [ ] Sprint backlog reviewed and approved by human
```

### Step 5: Return Issue Number

Provide the created issue URL for reference.

## Example

**User:** Initialize planning for v0.35 release, theme "CI/CD Improvements", scope is iac-driver#45, bootstrap#23

**Assistant actions:**
1. Read `docs/lifecycle/00-overview.md`
2. Read `docs/lifecycle/10-planning.md`
3. Read `docs/templates/release-issue.md`
4. Create issue with populated template
5. Output planning checklist
6. Return: "Created release issue: https://github.com/homestak-dev/homestak-dev/issues/132"

## Notes

- This skill only creates the release issue; it does not perform planning activities
- The user must still complete the planning checklist items manually
- Loading lifecycle docs ensures process documentation is fresh in context
