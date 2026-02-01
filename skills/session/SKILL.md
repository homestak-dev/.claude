---
name: session
description: Session management for context preservation - save, resume, checkpoint. Use to maintain continuity across context compactions.
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Read
  - Glob
  - Write
---

# Session Skill

## Overview

Manage session context with subcommands:
- `save` - Pre-compact capture of session state
- `resume` - Load session state at start of new session
- `checkpoint` - Mid-session save

## Usage

```
/session save
/session resume [issue#]
/session checkpoint
```

## Subcommands

### save

Capture session state before compaction or ending work.

**Actions by tier:**

**Standard tier:**
1. Identify current sprint/work issue
2. Post structured comment with:
   - Completed items
   - Next steps
   - Decisions made
3. Confirm save location

**Complex/Exploratory tier:**
1. Identify sprint issue
2. Update handoff section:
   - Current state (phase, branch, repos)
   - Decisions made with rationale
   - Files modified
   - Open questions
   - Next steps
3. Confirm save location

**Example:**
```
/session save
```

### resume

Load session state when starting a new session.

**Inputs:**
- Issue number (optional): defaults to most recent

**Actions:**
1. Find sprint/work issue
2. Parse metadata (branch, repos, status)
3. Read handoff section or recent comments
4. Load relevant file context
5. Present current state and next steps

**Example:**
```
/session resume
/session resume 152
```

### checkpoint

Mid-session save without ending session.

**Actions:**
1. Update sprint log with progress
2. Save incremental handoff
3. Lighter weight than full save

**Example:**
```
/session checkpoint
```

## Session State in Issues

### Standard Tier (Issue Comments)

```markdown
## Session Update - YYYY-MM-DD HH:MM

**Completed:**
- Item 1
- Item 2

**Next:**
- Item 3

**Decisions:**
- Decision and rationale
```

### Complex/Exploratory Tier (Handoff Section)

```markdown
## Handoff - YYYY-MM-DD HH:MM

### Current State
- Phase: Implementation (30%)
- Branch: sprint-152/recursive-pve
- Repos: iac-driver, ansible

### Decisions Made
| Decision | Choice | Rationale |
|----------|--------|-----------|
| State storage | Issue | Self-describing |

### Files Modified
- `src/actions/recursive.py` - New action
- `roles/nested-pve/tasks/main.yml` - SSH handling

### Open Questions
- Timeout for N+1 nesting?

### Next Steps
1. Complete SSH key propagation
2. Test 2-level nesting
```

## Integration with Context Compaction

**Before `/compact`:**
```
/session save
/compact
/session resume
```

**During long sessions:**
```
# Work for a while...
/session checkpoint
# Continue working...
/session checkpoint
# Before ending...
/session save
```

## Best Practices

### Do
- Save before compaction
- Include "why" not just "what"
- Reference specific files and line numbers
- Note any blockers or open questions

### Don't
- Leave uncommitted changes
- Rely on Claude's memory across compactions
- Skip documentation for "obvious" decisions
- Defer saves until "later"

## Related Documents

- [05-session-management.md](docs/lifecycle/05-session-management.md)
- [sprint-issue.md](docs/templates/sprint-issue.md)
