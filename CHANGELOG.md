# Changelog

## Unreleased

## v0.45 - 2026-02-02

### Theme: Create Integration

Integrates create phase with config mechanism for automatic spec discovery on first boot.

### Added
- Add `--to` parameter to `/session save` and `/session checkpoint` for explicit target (#176)
  - `--to release` saves to linked release issue
  - `--to sprint` saves to current sprint issue
  - `--to <issue#>` saves to specific issue number

## v0.44 - 2026-02-02

### Theme: Specify Infrastructure

Completes the Specify phase infrastructure for the VM lifecycle architecture.

### Added
- Add phase doc loading guidance to sprint skill (#165)
- Add `--all` flag to `/sprint merge` for multi-repo sprints (#167)

## v0.43 - 2026-02-01

- Release alignment with homestak v0.43

## v0.42 - 2026-01-31

### Changed
- Update `/release-validate` skill with manifest-based scenario selection (#3)
  - Add `recursive-pve-roundtrip --manifest n1-basic` for recursive/manifest changes
  - Add `recursive-pve-roundtrip --manifest n2-quick` for PVE/nested/packer changes
  - Add decision process matching `docs/lifecycle/60-release.md` Phase 3

## v0.34 - 2026-01-19

### Added
- Add 13 lifecycle skills covering all development phases (#129, #130)
  - Planning: `/planning-init`, `/planning-deps`, `/planning-conflicts`
  - Validation: `/validate-prereqs`, `/validate-run`
  - Merge: `/merge-pr`
  - Release: `/release-preflight`, `/release-changelog`, `/release-validate`, `/release-tag`, `/release-publish`, `/release-verify`, `/release-housekeeping`

### Changed
- Update CLAUDE.md with complete skill documentation and usage examples

## v0.26 - 2026-01-17

- Release alignment with homestak v0.26

All notable changes to this project will be documented in this file.

## [v0.25] - 2026-01-16

- Release alignment with homestak v0.25

## [v0.24] - 2026-01-16

- Release alignment with homestak v0.24

## [v0.18] - 2026-01-13

- Release alignment with homestak v0.18

## [v0.16] - 2026-01-11

- Release alignment with homestak v0.16

## [v0.13] - 2026-01-10

- Release alignment with homestak-dev v0.13


## [v0.12] - 2025-01-09

### Added
- Initial repository setup
- `/issues` skill for gathering GitHub issues across homestak-dev repos
  - Parallel API calls for faster results
  - Sorted output with dot-repos first
  - Truncated descriptions
  - Issue count footer
- Workspace settings configuration
- Custom status line script

### Changed
- `/issues` skill now includes .claude and homestak-dev repos (9 total)
