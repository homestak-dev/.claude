---
name: release
description: Release lifecycle management - plan init, plan update, execute. Orchestrates release phases with human gates.
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Bash(gita:*)
  - Bash(./scripts/release.sh:*)
  - Read
  - Glob
  - Write
---

# Release Skill

## Overview

Manage release lifecycle with subcommands:
- `plan init` - Create release issue with theme
- `plan update` - Add sprint outcomes to release issue
- `execute` - Run release phases with gates

## Usage

```
/release plan init <theme>
/release plan update
/release execute [--yes]
```

## Subcommands

### plan init

Create a release issue early with theme.

**Inputs:**
- Theme: Release focus area (e.g., "Lifecycle Overhaul")

**Actions:**
1. Determine next version number
2. Read `docs/templates/release-issue.md`
3. Create issue with template and theme
4. Return issue URL

**Example:**
```
/release plan init "Lifecycle Overhaul"
```

### plan update

Update release issue with completed sprint outcomes.

**Actions:**
1. Find open release issue
2. Identify completed sprints (closed, linked)
3. Update "Completed Sprints" section
4. Update "Release Readiness" checklist

**Example:**
```
/release plan update
```

### execute

Run release phases with human gates.

**Inputs:**
- `--yes`: Auto-approve non-gate phases

**Actions:**
1. Phase 61: Preflight checks
2. Phase 62: CHANGELOG updates
3. Phase 63: Tags [GATE - pause for approval]
4. Phase 64: Packer check
5. Phase 65: Publish [GATE - pause for approval]
6. Phase 66: Verify
7. Prompt: "Complete AAR (67) and retrospective (70) manually"

**Example:**
```
/release execute
/release execute --yes
```

## Integration with release.sh

The skill uses `scripts/release.sh` for automation:

```bash
./scripts/release.sh init --version X.Y --issue N
./scripts/release.sh preflight
./scripts/release.sh tag --dry-run
./scripts/release.sh tag --execute
./scripts/release.sh publish --execute --workflow github
./scripts/release.sh verify
./scripts/release.sh close --execute
```

## Gates

Phases 63 (Tags) and 65 (Publish) are human gates:
- Skill pauses and presents summary
- Requires explicit approval to continue
- Allows abort without side effects

## Release Issue State

The release issue tracks:
- Theme and version
- Completed sprints with validation evidence
- Scope summary
- Release readiness checklist
- Phase checklists

## Related Documents

- [60-release.md](docs/lifecycle/60-release.md)
- [61-68 phase files](docs/lifecycle/)
- [release-issue.md](docs/templates/release-issue.md)
