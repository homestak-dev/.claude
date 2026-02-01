---
name: sprint
description: Sprint lifecycle management - plan, init, validate, sync, merge, close. Use for multi-issue work requiring coordination.
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Bash(gita:*)
  - Read
  - Glob
  - Write
---

# Sprint Skill

## Overview

Manage sprint lifecycle with subcommands:
- `plan` - Create sprint issue, recommend branch name
- `init` - Create branches in repos
- `validate` - Run validation on sprint branches
- `sync` - Merge master → sprint branches
- `merge` - Create PRs (optionally execute merge)
- `close` - Retrospective, update release, cleanup

## Usage

```
/sprint plan <theme> [--release #N]
/sprint init [branch-name|issue#]
/sprint validate [--scenario <name>]
/sprint sync
/sprint merge [--execute]
/sprint close
```

## Subcommands

### plan

Create a sprint issue and recommend branch name.

**Inputs:**
- Theme: Sprint focus area
- Release (optional): Link to release issue

**Actions:**
1. Read `docs/templates/sprint-issue.md`
2. Create issue with populated template
3. Recommend branch name: `sprint-{issue#}/{theme-kebab}`

**Example:**
```
/sprint plan "Recursive PVE Stabilization" --release 157
```

### init

Create sprint branches in affected repos.

**Inputs:**
- Branch name or sprint issue number

**Actions:**
1. Fetch sprint issue if given number
2. Parse metadata for repos
3. Create branch in each repo
4. Push with upstream tracking
5. Update issue to mark branches created

**Example:**
```
/sprint init sprint-152/recursive-pve
/sprint init 152
```

### validate

Run validation scenario on sprint branches.

**Inputs:**
- Scenario (optional): defaults from sprint issue

**Actions:**
1. Read sprint issue for scenario
2. Run iac-driver scenario
3. Post results to sprint issue

**Example:**
```
/sprint validate
/sprint validate --scenario vm-roundtrip
```

### sync

Merge master into sprint branches.

**Actions:**
1. Fetch latest master
2. Merge master into sprint branch in each repo
3. Report conflicts if any

**Example:**
```
/sprint sync
```

### merge

Create PRs for sprint branches.

**Inputs:**
- `--execute`: Also merge the PRs (requires approval)

**Actions:**
1. Create PR in each repo with sprint branch
2. Use sprint PR template
3. Link scope issues
4. If `--execute`: merge after approval

**Example:**
```
/sprint merge
/sprint merge --execute
```

### close

Complete sprint wrap-up.

**Actions:**
1. Verify scope issues closed
2. Prompt for retrospective
3. Update release issue with outcomes
4. Clean up sprint branches
5. Close sprint issue

**Example:**
```
/sprint close
```

## Sprint Issue State

The sprint issue IS the state. Key sections:

- **Metadata**: Branch, release, status, tier
- **Repos**: Checkbox for each repo with branch
- **Scope**: Issues with tier and status
- **Sprint Log**: Chronological updates
- **Retrospective**: Filled at close

## Related Documents

- [10-sprint-planning.md](docs/lifecycle/10-sprint-planning.md)
- [55-sprint-close.md](docs/lifecycle/55-sprint-close.md)
- [sprint-issue.md](docs/templates/sprint-issue.md)
