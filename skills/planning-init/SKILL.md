---
name: planning-init
description: Initialize release planning by loading lifecycle context and creating or linking to a release planning issue. Use at the start of each sprint/release cycle.
allowed-tools:
  - Bash(gh:*)
  - Read
  - Glob
---

# Planning Init

## Overview

Initialize the planning phase for a new release by:
1. Loading lifecycle documentation into context
2. Creating OR linking to a release planning issue
3. Outputting the planning checklist for reference

This skill addresses context compaction issues by ensuring lifecycle docs are fresh in context at sprint start.

## When to Use

- Starting a new release cycle
- "Initialize v0.X release planning"
- "Start planning for the next sprint"
- "Create release issue for v0.X"
- "Link to existing issue #N for v0.X planning"

## Inputs

The user should provide:
- **Version**: Release version (e.g., "0.36")
- **Mode**: Create new issue OR link to existing (default: create)

**For new issues:**
- **Theme**: Release theme/title (e.g., "Lifecycle Skills")
- **Scope**: List of issues to include (e.g., "#129, #130")

**For existing issues:**
- **Issue**: Existing issue number (e.g., "#125")

## Execution Steps

### Step 1: Load Lifecycle Context

Read the following files to ensure process documentation is in context:

```
docs/lifecycle/00-overview.md   # Work types, phase matrix, multi-repo structure
docs/lifecycle/10-planning.md   # Planning activities, checklist
```

### Step 2: Create or Link Issue

**Mode A: Create new issue**

Read the template and create issue:

```bash
# Read template
docs/templates/release-issue.md

# Create issue
gh issue create --repo homestak-dev/homestak-dev \
  --title "vX.Y Release Planning - Theme" \
  --label "release" \
  --body "$(cat <<'EOF'
# Populated template content here
EOF
)"
```

**Mode B: Link to existing issue**

Fetch and display the existing issue:

```bash
gh issue view <issue-number> --repo homestak-dev/homestak-dev
```

This loads the existing scope and context without creating a duplicate.

### Step 3: Output Planning Checklist

Output the planning checklist from `10-planning.md`:

```
## Checklist: Planning Complete

- [ ] Release plan issue created/identified with scope
- [ ] All items classified by work type
- [ ] Acceptance criteria identified for each item
- [ ] Effort estimates assigned
- [ ] Dependencies mapped
- [ ] Branch/merge strategy analyzed (if multi-issue sprint)
- [ ] Issue-level planning documented
- [ ] Sprint backlog reviewed and approved by human
```

### Step 4: Return Issue Reference

Provide the issue URL for reference.

## Examples

### Example A: New Issue

**User:** Initialize planning for v0.35 release, theme "CI/CD Improvements", scope is iac-driver#45, bootstrap#23

**Assistant actions:**
1. Read `docs/lifecycle/00-overview.md`
2. Read `docs/lifecycle/10-planning.md`
3. Read `docs/templates/release-issue.md`
4. Create issue with populated template
5. Output planning checklist
6. Return: "Created release issue: https://github.com/homestak-dev/homestak-dev/issues/132"

### Example B: Existing Issue

**User:** Initialize planning for v0.36, issue #125 already exists

**Assistant actions:**
1. Read `docs/lifecycle/00-overview.md`
2. Read `docs/lifecycle/10-planning.md`
3. Fetch and display issue #125 content
4. Output planning checklist
5. Return: "Linked to existing issue: https://github.com/homestak-dev/homestak-dev/issues/125"

## Notes

- This skill only creates the release issue; it does not perform planning activities
- The user must still complete the planning checklist items manually
- Loading lifecycle docs ensures process documentation is fresh in context
