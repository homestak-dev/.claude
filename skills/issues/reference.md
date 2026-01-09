# Issues - Reference

## Helper Script Usage

The `gather-all-issues.sh` script provides quick command-line access. It runs all GitHub API calls **in parallel** for faster results:

```bash
# Get all open issues (default)
./.claude/skills/issues/scripts/gather-all-issues.sh

# Get all closed issues
./.claude/skills/issues/scripts/gather-all-issues.sh closed

# Filter by label
./.claude/skills/issues/scripts/gather-all-issues.sh open "bug"

# Export as JSON
./.claude/skills/issues/scripts/gather-all-issues.sh open "" json
```

## GitHub CLI Commands

### Basic issue listing

```bash
# List open issues for a single repo
gh issue list -R homestak-dev/ansible

# List all issues (open and closed)
gh issue list -R homestak-dev/ansible --state all

# Filter by label
gh issue list -R homestak-dev/ansible --label bug,critical

# Limit results
gh issue list -R homestak-dev/ansible --limit 50
```

### JSON output for processing

```bash
# Get issues as JSON
gh issue list -R homestak-dev/ansible --json number,title,url,state,labels,assignees

# Count issues
gh issue list -R homestak-dev/ansible --json number | jq 'length'

# Filter issues by label in JSON
gh issue list -R homestak-dev/ansible --json number,title,labels | \
  jq '[.[] | select(.labels[].name | contains("bug"))]'
```

### Multi-repo queries

```bash
# Loop through all repos
for repo in ansible bootstrap iac-driver packer site-config tofu .github; do
  echo "=== $repo ==="
  gh issue list -R "homestak-dev/$repo" --state open
done
```

## Common Use Cases

### Weekly Issue Review

```bash
# Get all open issues created in the last 7 days
for repo in ansible bootstrap iac-driver packer site-config tofu .github; do
  gh issue list -R "homestak-dev/$repo" --state open \
    --json number,title,createdAt,url | \
    jq --arg since "$(date -d '7 days ago' +%Y-%m-%d)" \
      '[.[] | select(.createdAt >= $since)]'
done
```

### Priority Tracking

```bash
# Find all high-priority issues
for repo in ansible bootstrap iac-driver packer site-config tofu .github; do
  gh issue list -R "homestak-dev/$repo" --label "priority:high,critical"
done
```

### Issue Metrics

```bash
# Count issues by state
echo "Open issues:"
for repo in ansible bootstrap iac-driver packer site-config tofu .github; do
  count=$(gh issue list -R "homestak-dev/$repo" --state open --json number | jq 'length')
  echo "  $repo: $count"
done

echo "Closed issues (last 30 days):"
for repo in ansible bootstrap iac-driver packer site-config tofu .github; do
  count=$(gh issue list -R "homestak-dev/$repo" --state closed \
    --json closedAt | \
    jq --arg since "$(date -d '30 days ago' +%Y-%m-%d)" \
      '[.[] | select(.closedAt >= $since)] | length')
  echo "  $repo: $count"
done
```

## Output Formats

### Table Format (default)

```
## issue            status description                                        tags
   .github#10      open   Epic: Define CI/CD strategy for homestak
   .github#13      open   Epic: Nested PVE architecture - bootstrap integ...
   ansible#11      open   Evaluate geerlingguy.ntp for time sync
   ansible#12      open   Evaluate ansible-postfix for mail relay configu...
   ...

Total: 37 issues
```

### JSON Format

```json
[
  {
    "number": 42,
    "title": "Fix ansible deployment script",
    "url": "https://github.com/homestak-dev/ansible/issues/42",
    "state": "OPEN",
    "labels": [{"name": "bug"}, {"name": "priority:high"}],
    "assignees": [],
    "createdAt": "2026-01-08T10:30:00Z",
    "updatedAt": "2026-01-09T14:20:00Z"
  }
]
```

## Environment Variables

You can set these in your shell profile for convenience:

```bash
export HOMESTAK_REPOS="ansible bootstrap iac-driver packer site-config tofu .github"
export HOMESTAK_ORG="homestak-dev"
```

## GitHub CLI Authentication

Ensure you're authenticated:

```bash
gh auth status
```

If not authenticated:

```bash
gh auth login
```

Select:
- GitHub.com
- HTTPS or SSH
- Authenticate via browser or paste token

## Tips and Best Practices

1. **Rate Limits**: GitHub API has rate limits. For frequent checks, cache results locally.

2. **Filtering**: Use labels consistently across repos for better filtering:
   - `bug`, `enhancement`, `documentation`
   - `priority:high`, `priority:medium`, `priority:low`
   - `status:blocked`, `status:in-progress`

3. **Automation**: Consider setting up a cron job for daily/weekly summaries:
   ```bash
   0 9 * * 1 /path/to/gather-all-issues.sh | mail -s "Weekly Issue Report" you@example.com
   ```

4. **Export**: Pipe JSON output to a file for further analysis:
   ```bash
   ./gather-all-issues.sh open "" json > issues-$(date +%Y%m%d).json
   ```

## See Also

- [GitHub CLI Manual](https://cli.github.com/manual/)
- [GitHub Issues API](https://docs.github.com/en/rest/issues)
- [jq Manual](https://stedolan.github.io/jq/manual/)
