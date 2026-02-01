# .claude

Claude Code configuration for the homestak-dev workspace.

## Structure

```
.claude/
├── settings.json       # Shared workspace settings
├── settings.local.json # Local settings (gitignored)
├── statusline.sh       # Custom status line script
└── skills/
    ├── sprint/              # Sprint lifecycle (NEW)
    ├── release/             # Release lifecycle (NEW)
    ├── session/             # Session management (NEW)
    ├── issues/              # GitHub issue tracking
    ├── planning-init/       # Release planning (→ /release plan init)
    ├── planning-deps/       # Cross-repo dependency analysis
    ├── planning-conflicts/  # File conflict analysis
    ├── validate-prereqs/    # Validation prerequisites check
    ├── validate-run/        # Run validation scenarios
    ├── merge-pr/            # Create pull requests
    ├── release-preflight/   # Release preflight (→ /release execute)
    ├── release-changelog/   # CHANGELOG updates (→ /release execute)
    ├── release-validate/    # Release validation (→ /release execute)
    ├── release-tag/         # Git tag creation (→ /release execute)
    ├── release-publish/     # GitHub release creation (→ /release execute)
    ├── release-verify/      # Release verification (→ /release execute)
    └── release-housekeeping/ # Branch cleanup (→ /release execute)
```

## Skills

### Primary Skills (Recommended)

| Skill | Subcommands | Description |
|-------|-------------|-------------|
| `/sprint` | plan, init, validate, sync, merge, close | Sprint lifecycle management |
| `/release` | plan init, plan update, execute | Release lifecycle with gates |
| `/session` | save, resume, checkpoint | Context preservation |
| `/issues` | - | Gather GitHub issues across repos |

### `/sprint` - Sprint Lifecycle

Manage multi-issue work with coordinated branches.

```
/sprint plan <theme> [--release #N]   # Create sprint issue
/sprint init [branch|issue#]           # Create branches in repos
/sprint validate [--scenario <name>]   # Run validation
/sprint sync                           # Merge master → sprint branches
/sprint merge [--execute]              # Create/merge PRs
/sprint close                          # Retrospective and cleanup
```

### `/release` - Release Lifecycle

Orchestrate release phases with human gates.

```
/release plan init <theme>    # Create release issue early
/release plan update          # Update with sprint outcomes
/release execute [--yes]      # Run phases 61-68 with gates
```

### `/session` - Session Management

Preserve context across compactions.

```
/session save        # Pre-compact capture
/session resume      # Load state in new session
/session checkpoint  # Mid-session save
```

### `/issues` - Issue Tracking

Gather GitHub issues across repositories.

```
/issues              # Show all open issues
/issues closed       # Show closed issues
/issues open "bug"   # Filter by label
```

### Supporting Skills

| Skill | Phase | Description |
|-------|-------|-------------|
| `/planning-deps` | 10 | Analyze cross-repo dependencies |
| `/planning-conflicts` | 10 | Analyze file overlap for branch strategy |
| `/validate-prereqs` | 40 | Check validation host readiness |
| `/validate-run` | 40 | Run iac-driver validation scenario |
| `/merge-pr` | 50 | Create PR with template and linked issues |

### Legacy Skills (Still Available)

Individual release phase skills remain available but are superseded by `/release execute`:

| Legacy Skill | Superseded By |
|--------------|---------------|
| `/planning-init` | `/release plan init` |
| `/release-preflight` | `/release execute` |
| `/release-changelog` | `/release execute` |
| `/release-validate` | `/release execute` |
| `/release-tag` | `/release execute` |
| `/release-publish` | `/release execute` |
| `/release-verify` | `/release execute` |
| `/release-housekeeping` | `/release execute` |

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
