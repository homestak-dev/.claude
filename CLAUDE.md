# .claude

Claude Code configuration for the homestak-dev workspace.

## Structure

```
.claude/
├── settings.json       # Shared workspace settings
├── settings.local.json # Local settings (gitignored)
├── statusline.sh       # Custom status line script
└── skills/
    ├── sprint/              # Sprint lifecycle
    ├── release/             # Release lifecycle
    ├── session/             # Session management
    └── issues/              # GitHub issue tracking
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
/sprint plan <theme> [--release #N] [--issues ...]  # Create sprint issue, analyze deps/conflicts
/sprint init [branch|issue#]                         # Create branches in repos
/sprint validate [--scenario <name>] [--host <host>] # Check prereqs, run validation
/sprint sync                                         # Merge master → sprint branches
/sprint merge [--execute]                            # Create/merge PRs
/sprint close                                        # Retrospective and cleanup
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
/session save [--to release|sprint|<issue#>]  # Pre-compact capture
/session resume [issue#]                       # Load state in new session
/session checkpoint [--to ...]                 # Mid-session save
```

**Target resolution:** Defaults to sprint issue when on sprint branch, otherwise release issue.

### `/issues` - Issue Tracking

Gather GitHub issues across repositories.

```
/issues              # Show all open issues
/issues closed       # Show closed issues
/issues open "bug"   # Filter by label
```

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
