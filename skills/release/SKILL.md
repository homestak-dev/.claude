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
1. **Load context:**
   - Read `docs/lifecycle/60-release.md` for release overview and guidelines
   - Read `docs/templates/release-issue.md` for issue template
2. Determine next version number
3. Create issue with template and theme
4. Return issue URL

**Example:**
```
/release plan init "Lifecycle Overhaul"
```

### plan update

Update release issue with completed sprint outcomes.

**Actions:**
1. **Load context:**
   - Read `docs/lifecycle/60-release.md` for release guidelines
2. Find open release issue
3. Identify completed sprints (closed, linked)
4. Update "Completed Sprints" section
5. Update "Release Readiness" checklist

**Example:**
```
/release plan update
```

### execute

Run release phases with human gates.

**Inputs:**
- `--yes`: Auto-approve non-gate phases

**Actions:**
1. **Load context:**
   - Read `docs/lifecycle/60-release.md` for release overview
   - Read phase files as each phase begins:
     - `docs/lifecycle/61-release-preflight.md` for Phase 61
     - `docs/lifecycle/62-release-changelog.md` for Phase 62
     - `docs/lifecycle/63-release-tag.md` for Phase 63 (GATE)
     - `docs/lifecycle/64-release-packer.md` for Phase 64
     - `docs/lifecycle/65-release-publish.md` for Phase 65 (GATE)
     - `docs/lifecycle/66-release-verify.md` for Phase 66
     - `docs/lifecycle/67-release-aar.md` for Phase 67
     - `docs/lifecycle/68-release-housekeeping.md` for Phase 68
2. Execute phases in order:
   - Phase 61: Preflight checks
   - Phase 62: CHANGELOG updates
   - Phase 63: Tags [GATE - pause for approval]
   - Phase 64: Packer check
   - Phase 65: Publish [GATE - pause for approval]
   - Phase 66: Verify
3. Prompt: "Complete AAR (67) and retrospective (70) manually"

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
- [61-release-preflight.md](docs/lifecycle/61-release-preflight.md)
- [62-release-changelog.md](docs/lifecycle/62-release-changelog.md)
- [63-release-tag.md](docs/lifecycle/63-release-tag.md)
- [64-release-packer.md](docs/lifecycle/64-release-packer.md)
- [65-release-publish.md](docs/lifecycle/65-release-publish.md)
- [66-release-verify.md](docs/lifecycle/66-release-verify.md)
- [67-release-aar.md](docs/lifecycle/67-release-aar.md)
- [68-release-housekeeping.md](docs/lifecycle/68-release-housekeeping.md)
- [release-issue.md](docs/templates/release-issue.md)
