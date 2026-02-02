# .claude

Claude Code configuration for the homestak-dev workspace.

## Overview

This repository contains shared Claude Code configuration including:

- **Skills** - Custom slash commands for lifecycle management workflows
- **Settings** - Workspace-level Claude Code settings
- **Status Line** - Custom status line script

## Skills

### Primary Skills

| Skill | Subcommands | Description |
|-------|-------------|-------------|
| `/sprint` | plan, init, validate, sync, merge, close | Sprint lifecycle management |
| `/release` | plan init, plan update, execute | Release lifecycle with gates |
| `/session` | save, resume, checkpoint | Context preservation across compactions |
| `/issues` | - | Gather GitHub issues across repos |

### Quick Reference

```bash
# Sprint lifecycle
/sprint plan "Theme" --release #N    # Create sprint issue
/sprint init [branch|issue#]         # Create branches
/sprint validate --host father       # Run validation
/sprint merge                        # Create PR (current repo)
/sprint merge --all                  # Create PRs (all sprint repos)
/sprint close                        # Wrap up sprint

# Release lifecycle
/release plan init "Theme"           # Create release issue
/release plan update                 # Update with sprint outcomes
/release execute                     # Run phases with gates

# Session management
/session save                        # Save before compaction
/session resume                      # Load in new session
/session checkpoint                  # Mid-session save

# Issue tracking
/issues                              # Show open issues
/issues closed                       # Show closed issues
```

## Structure

```
.claude/
├── settings.json       # Shared workspace settings
├── settings.local.json # Local settings (gitignored)
├── statusline.sh       # Custom status line script
└── skills/
    ├── sprint/         # Sprint lifecycle skill
    ├── release/        # Release lifecycle skill
    ├── session/        # Session management skill
    └── issues/         # GitHub issue tracking
```

## Installation

This repo is typically cloned as part of the homestak-dev workspace:

```bash
cd ~/homestak-dev
git clone https://github.com/homestak-dev/.claude.git .claude
```

## Documentation

See [CLAUDE.md](CLAUDE.md) for full skill documentation.

## Related Projects

Part of the [homestak-dev](https://github.com/homestak-dev) organization.

## License

Apache 2.0
