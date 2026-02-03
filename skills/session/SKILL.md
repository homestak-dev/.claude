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
/session save [--to release|sprint|<issue#>]
/session resume [issue#]
/session checkpoint [--to release|sprint|<issue#>]
```

## Subcommands

### save

Capture session state before compaction or ending work.

**Inputs:**
- `--to <target>` (optional): Explicit save target
  - `release` → Save to the linked release issue
  - `sprint` → Save to the current sprint issue
  - `<issue#>` → Save to a specific issue number (e.g., `--to 154`)
  - (omitted) → Infer from context (default: sprint if active, else release)

**Actions:**
1. **Load context:**
   - Read `docs/lifecycle/05-session-management.md` for tier-based save strategies
2. Resolve target issue:
   - If `--to` specified, use that target
   - If sprint branch active, default to sprint issue
   - Otherwise, use release issue or prompt
3. Determine work tier (Simple, Standard, Complex, Exploratory)
4. Save according to tier:

**Standard tier:**
- Post structured comment with:
  - Completed items
  - Next steps
  - Decisions made
- Confirm save location

**Complex/Exploratory tier:**
- Update handoff section:
  - Current state (phase, branch, repos)
  - Decisions made with rationale
  - Files modified
  - Open questions
  - Next steps
- Confirm save location

**Examples:**
```
/session save                  # Infer target (sprint if active, else release)
/session save --to sprint      # Save to current sprint issue
/session save --to release     # Save to linked release issue
/session save --to 154         # Save to specific issue #154
```

### resume

Load session state when starting a new session.

**Inputs:**
- Issue number (optional): defaults to most recent

**Actions:**
1. **Load context:**
   - Read `docs/lifecycle/05-session-management.md` for resume strategies
2. Find sprint/work issue
3. Parse metadata (branch, repos, status)
4. Read handoff section or recent comments
5. Load relevant file context
6. Present current state and next steps

**Example:**
```
/session resume
/session resume 152
```

### checkpoint

Mid-session save without ending session.

**Inputs:**
- `--to <target>` (optional): Same as `save` - explicit target issue

**Actions:**
1. **Load context:**
   - Read `docs/lifecycle/05-session-management.md` for checkpoint guidance
2. Resolve target issue (same logic as `save`)
3. Update sprint log with progress
4. Save incremental handoff
5. Lighter weight than full save

**Examples:**
```
/session checkpoint            # Checkpoint to inferred target
/session checkpoint --to 177   # Checkpoint to specific issue
```

## Target Resolution

When `--to` is not specified, the target is inferred:

| Context | Default Target | Rationale |
|---------|----------------|-----------|
| On sprint branch | Sprint issue | Active work unit |
| No sprint branch | Release issue (if linked) | Parent tracking |
| Neither | Prompt user | Avoid ambiguity |

**Recommendation:** Use explicit `--to sprint` during sprint work to ensure session state stays with the sprint issue. Sprint close will summarize to the release issue.

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
- Branch: sprint/recursive-pve
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
