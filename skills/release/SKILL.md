---
name: release
description: Release lifecycle management - plan init, plan update, execute, close. Orchestrates release phases with human gates.
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
- `close` - Close release issue after retrospective

## Usage

```
/release plan init <theme>
/release plan update
/release execute [--yes]
/release close
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
     - `docs/lifecycle/67-release-housekeeping.md` for Phase 67
     - `docs/lifecycle/68-release-aar.md` for Phase 68
     - `docs/lifecycle/69-release-retro.md` for Phase 69
     - `docs/templates/aar.md` for AAR template
     - `docs/templates/retrospective.md` for Retrospective template
     - `docs/lifecycle/75-lessons-learned.md` for existing lessons context
2. Execute phases in order:
   - Phase 61: Preflight checks
   - Phase 62: CHANGELOG updates
   - Phase 63: Tags [GATE - pause for approval]
   - Phase 64: Packer check
   - Phase 65: Publish [GATE - pause for approval]
   - Phase 66: Verify
   - Phase 67: Housekeeping
   - Phase 68: AAR [draft for user review]
   - Phase 69: Retrospective [draft for user review]

**Example:**
```
/release execute
/release execute --yes
```

#### Phase 67: Housekeeping

- Read `docs/lifecycle/67-release-housekeeping.md`
- Delete merged local branches across all repos
- Prune stale remote tracking refs (`git remote prune origin`)
- Check release count, prompt for sunset if >5

#### Phase 68: AAR

- Read `docs/lifecycle/68-release-aar.md` and `docs/templates/aar.md`
- Draft AAR from release execution data:
  - Delivered items (from release issue scope)
  - Deviations from plan
  - Issues encountered during release execution
  - Release artifacts table (all 9 repos with version)
  - Validation evidence references (from sprint issues)
- Present draft to user for review
- Post as comment on release issue

#### Phase 69: Retrospective

- Read `docs/lifecycle/69-release-retro.md`, `docs/templates/retrospective.md`, and `docs/lifecycle/75-lessons-learned.md`
- Review release issue, sprint issues, and AAR
- Draft retrospective using template:
  - What worked well / what could improve
  - Suggestions for next release
  - Follow-up issues (create if needed)
  - Lessons learned
- Present draft to user for review and additions
- Post as comment on release issue
- Update `docs/lifecycle/75-lessons-learned.md` with new lessons under version heading
- Commit: `docs: Update 75-lessons-learned.md with vX.Y lessons`
- Prompt user: "Retrospective posted. When ready, run `/release close` to close the release issue."

### close

Close the release issue after retrospective review.

**Actions:**
1. Run `release.sh close --execute --yes`
2. Confirm issue closed

**Example:**
```
/release close
```

## Integration with release.sh

The skill uses `scripts/release.sh` for automation:

```bash
./scripts/release.sh init --version X.Y --issue N
./scripts/release.sh preflight
./scripts/release.sh tag --dry-run
./scripts/release.sh tag --execute
./scripts/release.sh publish --execute --yes
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
- [67-release-housekeeping.md](docs/lifecycle/67-release-housekeeping.md)
- [68-release-aar.md](docs/lifecycle/68-release-aar.md)
- [69-release-retro.md](docs/lifecycle/69-release-retro.md)
- [75-lessons-learned.md](docs/lifecycle/75-lessons-learned.md)
- [release-issue.md](docs/templates/release-issue.md)
- [aar.md](docs/templates/aar.md)
- [retrospective.md](docs/templates/retrospective.md)
