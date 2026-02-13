# Claude Code Work Files

My personal collection of configs, agents, commands, rules, and scripts for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Claude Code Guide

**Commands** are reusable prompt templates (`.md` files) you invoke with `/name`. They act like slash-command macros — great for repetitive workflows like committing, generating tests, or running multi-step processes. Keep them focused on a single task.

**Agents** are commands with a `model` and `tools` frontmatter — they spawn a sub-agent with restricted tool access and a specific model. Use agents for autonomous, scoped tasks (code review, migrations) where you want Claude to operate independently without full permissions.

**Rules** are context files that auto-inject into the prompt when you edit files matching their `paths` glob. They enforce project conventions (e.g. always use RLS with Supabase) without you having to repeat instructions. Best used for framework-specific or domain-specific guardrails.

## Quick Start

| What | How to install | How to use |
|------|---------------|------------|
| **Permissions** | Copy `settings/permission-setting.json` to your project as `.claude/settings.json` | Auto-approves safe commands, blocks destructive ones |
| **User settings** | Copy `user-settings/*` to `~/.claude/` | Statusline, Slack hooks, and plugins load automatically |
| **Commands** | Copy `commands/*.md` to `.claude/commands/` (project) or `~/.claude/commands/` (global) | Run `/commit`, `/implement <spec>` in Claude Code |
| **Agents** | Copy `agents/*.md` to `.claude/commands/` (project) or `~/.claude/commands/` (global) | Run `/code-reviewer` — agents are commands with `model` and `tools` frontmatter |
| **Rules** | Copy `.claude/rules/*.md` to your project's `.claude/rules/` | Auto-applied when editing files matching the `paths` glob in frontmatter |

## What's Inside

### Permissions Config (`settings/`)

Controls which Bash commands run without confirmation via `settings/permission-setting.json`.

| Category | Commands | Notes |
|----------|----------|-------|
| Git (read) | `git diff`, `git log` | Read-only |
| Git (write) | `git add`, `git commit`, `git checkout`, `git branch`, `git stash` | Standard workflow |
| Git (push) | `git push`, `git push origin *` | Force push still requires confirmation |
| Node | `npm test`, `npm run`, `pnpm` | Project scripts |
| npx | `jest`, `prettier`, `eslint`, `tsc` | Scoped to specific tools only |
| File inspection | `cat`, `ls`, `grep` | Read-only |

Anything not listed (e.g. `rm`, `sudo`, `curl`, `git push --force`) prompts for confirmation.

### User Settings (`user-settings/`)

- **`settings.json`** — Global config: custom statusline, enabled plugins (`frontend-design`, `rosh-profile-plugin`), Slack notification hooks
- **`statusline.sh`** — Shows current dir, git branch, context window usage, and lines changed
- **`slack-notify.sh`** — Sends Slack notifications when Claude Code finishes a task or needs attention

### Commands (`commands/`)

- **`commit.md`** — `/commit` — Stages and commits changes with a message matching the repo's existing style
- **`implement.md`** — `/implement <spec-name>` — Reads a spec from `docs/specs/`, implements the next phase using TDD, commits, and updates the spec

### Agents (`agents/`)

- **`code-reviewer.md`** — `/code-reviewer` — Reviews staged changes for type safety, error handling, and untested code paths (Sonnet, read-only)

### Rules (`.claude/rules/`)

- **`supabase.md`** — Auto-applies when editing `supabase/**`, `src/lib/supabase/**`, or `*.sql` — enforces RLS policies, generated types, and role-based testing
