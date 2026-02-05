---
name: sprint
description: Sprint lifecycle management - plan, init, validate, sync, merge, close. Use for multi-issue work requiring coordination.
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Bash(gita:*)
  - Bash(cd:*)
  - Bash(./run.sh:*)
  - Bash(ls:*)
  - Bash(cat:*)
  - Bash(grep:*)
  - Bash(test:*)
  - Read
  - Glob
  - Grep
  - Write
---

# Sprint Skill

## Overview

Manage sprint lifecycle with subcommands:
- `plan` - Create sprint issue, analyze dependencies and conflicts
- `init` - Create branches in repos
- `validate` - Check prerequisites and run validation scenarios
- `sync` - Merge master → sprint branches
- `merge` - Create PRs with proper formatting
- `close` - Retrospective, update release, cleanup

## Usage

```
/sprint plan <theme> [--release #N]
/sprint init [branch-name|issue#]
/sprint validate [--scenario <name>] [--host <host>] [--prereqs-only]
/sprint sync
/sprint merge [--execute] [--all]
/sprint close
```

## Subcommands

### plan

Create a sprint issue, analyze dependencies, and recommend branch name.

**Inputs:**
- Theme: Sprint focus area
- Release (optional): Link to release issue
- Issues (optional): Scope issues for dependency/conflict analysis

**Actions:**
1. **Load context:**
   - Read `docs/lifecycle/10-sprint-planning.md` for workflow guidance
   - Read `docs/templates/sprint-issue.md` for issue template
   - Read `docs/ISSUE-GUIDELINES.md` for title and label conventions
2. Create issue with populated template
3. Recommend branch name: `sprint/{theme-kebab}`
4. If scope issues provided:
   - Analyze cross-repo dependencies
   - Detect file conflicts
   - Recommend implementation sequence

**Dependency Analysis:**

Map issues against repo dependency order:
```
.github → .claude → homestak-dev → site-config → tofu → ansible → bootstrap → packer → iac-driver
```

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

**Conflict Analysis:**

Build overlap matrix for files touched by multiple issues:

| File | Issue #1 | Issue #2 | Issue #3 |
|------|----------|----------|----------|
| `src/cli.py` | ✓ | ✓ | |
| `CLAUDE.md` | ✓ | | ✓ |

Flag high-impact issues (restructure, refactor, schema changes) that should be implemented first.

**Example:**
```
/sprint plan "Recursive PVE Stabilization" --release 157
/sprint plan "Config Overhaul" --issues "site-config#45, iac-driver#67, tofu#12"
```

### init

Create sprint branches in affected repos.

**Inputs:**
- Branch name or sprint issue number

**Actions:**
1. **Load context:**
   - Read `docs/lifecycle/10-sprint-planning.md` for branch workflow
2. Fetch sprint issue if given number
3. Parse metadata for repos
4. Create branch in each repo
5. Push with upstream tracking
6. Update issue to mark branches created

**Example:**
```
/sprint init sprint/recursive-pve
/sprint init   # Uses branch from current sprint issue
```

### validate

Check prerequisites and run validation scenarios.

**Inputs:**
- `--scenario <name>`: Test scenario (default from sprint issue or `vm-roundtrip`)
- `--host <host>`: Target PVE host (default: `father`)
- `--prereqs-only`: Only check prerequisites, don't run scenario

**Actions:**
1. **Load context:**
   - Read `docs/lifecycle/40-validation.md` for validation requirements
2. Check prerequisites for target host
3. If prereqs fail, report issues and remediation
4. Run iac-driver scenario: `./run.sh --scenario <name> --host <host> --verbose`
5. Locate and read report from `iac-driver/reports/`
6. Post results to sprint issue

**Prerequisites Checked:**

| Prerequisite | Check | Remediation |
|--------------|-------|-------------|
| Node config | `site-config/nodes/{host}.yaml` exists | Run `make node-config` on host |
| API token | Token in `secrets.yaml` for host | Run `pveum user token add`, update secrets |
| Secrets decrypted | `secrets.yaml` exists (not `.enc` only) | Run `make decrypt` in site-config |
| Packer images | Images in `/var/lib/vz/template/iso/` | Run `./publish.sh` or download from release |
| Nested virt | `/sys/module/kvm_intel/parameters/nested` = Y | Enable in BIOS/hypervisor |

**Available Scenarios:**

| Scenario | Duration | Purpose |
|----------|----------|---------|
| `vm-roundtrip` | ~2 min | Quick validation (provision → boot → verify → destroy) |
| `nested-pve-roundtrip` | ~9 min | Full stack (including PVE installation) |
| `vm-constructor` | ~1.5 min | Deploy VM only (no destroy) |
| `vm-destructor` | ~30 sec | Destroy existing VM |

**Example:**
```
/sprint validate
/sprint validate --scenario nested-pve-roundtrip --host mother
/sprint validate --prereqs-only --host father
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

Create PRs for sprint branches with proper formatting.

**Inputs:**
- `--execute`: Merge PRs after human approval (do NOT use without explicit approval)
- `--all`: Create PRs in all repos listed in sprint issue

> **⚠️ HUMAN GATE:** This command creates PRs, then STOPS for human review.
> Do NOT use `--execute` or merge PRs without explicit human approval.
> Ruleset failures are checkpoints, not obstacles to bypass.

**Default behavior (no --execute):**
1. Create PRs in affected repos
2. **STOP and present PRs for human review**
3. Output: "Awaiting human review and approval before merge."
4. Wait for explicit user approval before proceeding

**With --execute (only after human approval):**
- Merge PRs using merge commit strategy (not squash)
- Clean up branches after merge
- Update sprint issue

**Actions:**
1. **Load context:**
   - Read `docs/lifecycle/50-merge.md` for PR requirements and checklist
   - Read `docs/ISSUE-GUIDELINES.md` for PR title format conventions
2. If `--all`:
   a. Fetch current sprint issue (from branch name or prompt)
   b. Parse `## Repos` section for checked repos
   c. For each repo with `[x]` branch created:
      - Navigate to repo directory
      - Run merge flow (steps 3-6 below)
   d. Report summary of all PRs created
3. Verify branch state (not on master, has commits ahead)
4. Push branch if needed
5. Generate PR body with:
   - Summary from commits/sprint issue
   - Type of change checkboxes
   - Changes list
   - Testing documentation
   - Linked issues (Closes #N)
   - PR readiness checklist
6. Create PR with conventional commit title format
7. **STOP: Present PRs and await human approval**
8. Only if `--execute` AND human approved: merge PRs

**Repo detection for --all:**
Parse sprint issue body for:
```markdown
## Repos

- [x] bootstrap - branch created
- [x] homestak-dev - branch created
- [ ] ansible - not created (skip)
```

Only repos with `[x]` are included.

**PR Title Format:**
- `fix(<scope>): <summary>` - Bug fixes
- `feat(<scope>): <summary>` - New features
- `docs(<scope>): <summary>` - Documentation
- `refactor(<scope>): <summary>` - Refactoring

**PR Readiness Checklist:**
```markdown
- [ ] Feature tested end-to-end (not just unit tests)
- [ ] External tool assumptions verified (test actual CLI behavior)
- [ ] CHANGELOG entry in this PR
- [ ] CLAUDE.md updated if architecture changed
- [ ] Performance claims measured (before/after timing)
- [ ] Prerequisites documented (configs, artifacts, permissions)
- [ ] Integration test scenario identified
```

**Example (two-step flow):**
```
# Step 1: Create PRs (always do this first)
/sprint merge --all        # Creates PRs, then STOPS for review

# Step 2: After human reviews and approves PRs
/sprint merge --all --execute  # Merges the approved PRs
```

**Never do this:**
```
# WRONG: Don't use --execute without prior approval
/sprint merge --execute    # Skips human review gate
```

### close

Complete sprint wrap-up.

**Actions:**
1. **Load context:**
   - Read `docs/lifecycle/55-sprint-close.md` for close requirements
2. Verify scope issues closed
3. Prompt for retrospective
4. Update release issue with outcomes
5. Clean up sprint branches
6. Close sprint issue

**Example:**
```
/sprint close
```

## Phase Transitions

After completing each phase, load the next phase's documentation before proceeding:

| After | Before Starting | Load |
|-------|-----------------|------|
| `plan` | Design | `docs/lifecycle/20-design.md` |
| `init` | Design | `docs/lifecycle/20-design.md` |
| Design approved | Implementation | `docs/lifecycle/30-implementation.md` |
| Implementation done | Validation | `docs/lifecycle/40-validation.md` |
| `validate` passed | Merge | `docs/lifecycle/50-merge.md` |
| `merge` complete | Close | `docs/lifecycle/55-sprint-close.md` |

**Process discipline:** Always read the phase doc before starting that phase. This ensures process requirements are fresh in context.

**Example workflow:**
```
/sprint init 163
→ Read 20-design.md
→ Complete design, get approval
→ Read 30-implementation.md
→ Implement changes
→ Read 40-validation.md
/sprint validate
→ Read 50-merge.md
/sprint merge
→ Read 55-sprint-close.md
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

- [ISSUE-GUIDELINES.md](docs/ISSUE-GUIDELINES.md)
- [10-sprint-planning.md](docs/lifecycle/10-sprint-planning.md)
- [40-validation.md](docs/lifecycle/40-validation.md)
- [50-merge.md](docs/lifecycle/50-merge.md)
- [55-sprint-close.md](docs/lifecycle/55-sprint-close.md)
- [sprint-issue.md](docs/templates/sprint-issue.md)
