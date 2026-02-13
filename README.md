# Claude Code Work Files

My personal collection of configs, scripts, and settings I use with [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## What's in this repo

### Permissions Config

- **`setting.json`** / **`setting.example.json`** - Allowlist of auto-approved Bash commands for Claude Code. Controls what runs without manual confirmation.
- **`.claude/settings.json`** - Same permissions config, active for this project.

| Category | Commands | Notes |
|----------|----------|-------|
| Git (read) | `git diff`, `git log` | Read-only |
| Git (write) | `git add`, `git commit`, `git checkout`, `git branch`, `git stash` | Standard workflow |
| Git (push) | `git push`, `git push origin *` | Force push still requires confirmation |
| Node | `npm test`, `npm run`, `pnpm` | Project scripts |
| npx | `jest`, `prettier`, `eslint`, `tsc` | Scoped to specific tools only |
| File inspection | `cat`, `ls`, `grep` | Read-only |

Anything not in the allowlist (e.g. `rm`, `sudo`, `curl`, `git push --force`) prompts for confirmation.

### Global Settings

Located in `global-settings/` — these go in `~/.claude/`.

- **`global-settings/settings.json`** - Global Claude Code config including:
  - Custom statusline command
  - Enabled plugins (`frontend-design`, `rosh-profile-plugin`)
  - Hooks for Slack notifications on `Stop` and `Notification` events

- **`global-settings/statusline.sh`** - Custom statusline script that displays:
  - Current directory and git branch
  - Context window usage (percentage and token count)
  - Lines added/removed in the session

- **`global-settings/slack-notify.sh`** - Slack webhook script that sends notifications when Claude Code finishes a task or needs attention.

### Slash Commands

Located in `commands/` — copy to `.claude/commands/` in a project or `~/.claude/commands/` for global use.

- **`commands/commit.md`** (`/commit`) - Stages and commits changes with a concise message that matches the repo's existing commit style.
- **`commands/implement.md`** (`/implement <spec-name>`) - Reads a spec from `docs/specs/`, implements the next unchecked phase using TDD (tests first, fix before moving on), commits, and updates the spec.

## Usage

**Project-level permissions:** Copy `setting.json` to your project as `.claude/settings.json`.

**Global settings:** Copy files from `global-settings/` to `~/.claude/`.
