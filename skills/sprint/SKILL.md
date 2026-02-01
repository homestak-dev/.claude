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
/sprint merge [--execute]
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
1. Read `docs/templates/sprint-issue.md`
2. Create issue with populated template
3. Recommend branch name: `sprint-{issue#}/{theme-kebab}`
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

Check prerequisites and run validation scenarios.

**Inputs:**
- `--scenario <name>`: Test scenario (default from sprint issue or `vm-roundtrip`)
- `--host <host>`: Target PVE host (default: `father`)
- `--prereqs-only`: Only check prerequisites, don't run scenario

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

**Actions:**
1. Check prerequisites for target host
2. If prereqs fail, report issues and remediation
3. Run iac-driver scenario: `./run.sh --scenario <name> --host <host> --verbose`
4. Locate and read report from `iac-driver/reports/`
5. Post results to sprint issue

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
- `--execute`: Also merge the PRs (requires approval)

**Actions:**
1. Verify branch state (not on master, has commits ahead)
2. Push branch if needed
3. Generate PR body with:
   - Summary from commits/sprint issue
   - Type of change checkboxes
   - Changes list
   - Testing documentation
   - Linked issues (Closes #N)
   - PR readiness checklist
4. Create PR with conventional commit title format
5. If `--execute`: merge after approval

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
- [40-validation.md](docs/lifecycle/40-validation.md)
- [50-merge.md](docs/lifecycle/50-merge.md)
- [55-sprint-close.md](docs/lifecycle/55-sprint-close.md)
- [sprint-issue.md](docs/templates/sprint-issue.md)
