# .claude

Claude Code configuration for the homestak-dev workspace.

## Structure

```
.claude/
├── settings.json       # Shared workspace settings
├── settings.local.json # Local settings (gitignored)
├── statusline.sh       # Custom status line script
└── skills/
    ├── issues/              # GitHub issue tracking
    ├── planning-init/       # Release planning initialization
    ├── planning-deps/       # Cross-repo dependency analysis
    ├── planning-conflicts/  # File conflict analysis
    ├── validate-prereqs/    # Validation prerequisites check
    ├── validate-run/        # Run validation scenarios
    ├── merge-pr/            # Create pull requests
    ├── release-preflight/   # Release preflight checks
    ├── release-changelog/   # CHANGELOG updates
    ├── release-validate/    # Release validation
    ├── release-tag/         # Git tag creation (gate)
    ├── release-publish/     # GitHub release creation (gate)
    ├── release-verify/      # Release verification + AAR
    └── release-housekeeping/ # Branch cleanup
```

## Skills

### Skill Overview

| Skill | Phase | Description |
|-------|-------|-------------|
| `/issues` | - | Gather GitHub issues across all repos |
| `/planning-init` | 10 | Initialize release planning, create issue |
| `/planning-deps` | 10 | Analyze cross-repo dependencies |
| `/planning-conflicts` | 10 | Analyze file overlap for branch strategy |
| `/validate-prereqs` | 40 | Check validation host readiness |
| `/validate-run` | 40 | Run iac-driver validation scenario |
| `/merge-pr` | 50 | Create PR with template and linked issues |
| `/release-preflight` | 60 | Check release prerequisites |
| `/release-changelog` | 60 | Update CHANGELOGs for release |
| `/release-validate` | 60 | Run integration tests |
| `/release-tag` | 60 | Create git tags (human gate) |
| `/release-publish` | 60 | Create GitHub releases (human gate) |
| `/release-verify` | 60 | Verify releases and generate AAR |
| `/release-housekeeping` | 60 | Clean up branches |

### /issues

Gathers and displays GitHub issues across all homestak-dev repositories.

**Usage:**
```
/issues              # Show all open issues
/issues closed       # Show closed issues
/issues open "bug"   # Filter by label
```

### Planning Skills

#### /planning-init

Initialize release planning by loading lifecycle context and creating the release planning issue.

**Usage:** "Initialize v0.35 release planning, theme 'CI/CD', scope #45, #46"

#### /planning-deps

Analyze cross-repo dependencies for sprint scope to identify implementation order.

**Usage:** "Analyze dependencies for iac-driver#45, tofu#12"

#### /planning-conflicts

Analyze file overlap between issues to inform branch/merge strategy.

**Usage:** "Check for conflicts between #19, #6, #27 in packer"

### Validation Skills

#### /validate-prereqs

Check validation host readiness: node config, API token, secrets, packer images, nested virt.

**Usage:** "Check if father is ready for validation"

#### /validate-run

Run iac-driver validation scenario and capture results.

**Usage:** "Run vm-roundtrip on father"

### Merge Skills

#### /merge-pr

Create PR with template, linked issues, and checklist.

**Usage:** "Create PR to close #129 and #130"

### Release Skills

#### /release-preflight

Check release prerequisites (Phase 0-1): repo health, tags, CHANGELOGs.

**Usage:** "Run preflight for v0.34"

#### /release-changelog

Update CHANGELOGs by moving Unreleased content to versioned headers (Phase 2).

**Usage:** "Update CHANGELOGs for v0.34"

#### /release-validate

Run integration tests before tagging (Phase 3).

**Usage:** "Run validation for v0.34 release"

#### /release-tag

Create and push git tags (Phase 4). **Requires human approval.**

**Usage:** "Create tags for v0.34"

#### /release-publish

Create GitHub releases (Phase 5-6). **Requires human approval.**

**Usage:** "Publish v0.34 releases"

#### /release-verify

Verify releases and generate After Action Report (Phase 7-8). Fully automated.

**Usage:** "Verify v0.34 release"

#### /release-housekeeping

Clean up branches after release (Phase 9).

**Usage:** "Run housekeeping for v0.34"

## Adding New Skills

1. Create a directory under `skills/` with the skill name
2. Add a `SKILL.md` file with frontmatter:
   ```yaml
   ---
   name: skill-name
   description: What the skill does
   allowed-tools:
     - Bash(command:*)
   ---
   ```
3. Add supporting scripts in a `scripts/` subdirectory
4. Optionally add `reference.md` for detailed documentation

## Local Settings

The `settings.local.json` file is gitignored and contains machine-specific settings that should not be shared.

## Related Projects

Part of the [homestak-dev](https://github.com/homestak-dev) organization.
