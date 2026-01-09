# .claude

Claude Code configuration for the homestak-dev workspace.

## Structure

```
.claude/
├── settings.json       # Shared workspace settings
├── settings.local.json # Local settings (gitignored)
├── statusline.sh       # Custom status line script
└── skills/
    └── issues/         # /issues skill for GitHub issue tracking
```

## Skills

### /issues

Gathers and displays GitHub issues across all homestak-dev repositories.

**Usage:**
```
/issues              # Show all open issues
/issues closed       # Show closed issues
/issues open "bug"   # Filter by label
```

**Output format:**
```
## issue            status description                                        tags
   .github#10      open   Epic: Define CI/CD strategy for homestak
   ansible#11      open   Evaluate geerlingguy.ntp for time sync
   ...

Total: 37 issues
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
