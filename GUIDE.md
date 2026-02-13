# Claude Code Cheatsheet: Minimal, Battle-Tested Configs

---

## 1. CLAUDE.md (Root) -- Keep Under 30 Lines

```markdown
# Project Name

## Commands
- Dev: pnpm dev
- Test: pnpm test
- Lint: pnpm lint
- Types: npx tsc --noEmit
- Single test: pnpm test -- path/to/file.test.ts

## Stack
Next.js 15 App Router, TypeScript strict, Supabase, Tailwind

## Key Directories
- src/app/ -- Routes and API endpoints
- src/components/ -- Shared React components
- src/lib/db/ -- All Supabase queries go here
- docs/specs/ -- Feature specs

## Conventions
- Named exports only, no default exports
- Server components by default, "use client" only when needed
- No `any` -- use `unknown` and narrow
- Colocate tests: ComponentName.test.tsx next to source

## On Mistakes
If a task fails twice, stop. Write what went wrong to a TODO comment
and move on. Do not loop.
```

**Why each section exists:**
- Commands: Claude guesses wrong build tools without this
- Stack: Prevents wrong framework patterns (Pages Router vs App Router)
- Key Dirs: Claude scatters files without guidance
- Conventions: Corrects Claude's known defaults (it loves `export default` and `any`)
- On Mistakes: Prevents infinite fix loops that burn context

---

## 2. settings.json -- Permission Allowlist

```json
{
  "permissions": {
    "allow": [
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git push *)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git checkout *)",
      "Bash(git branch *)",
      "Bash(git stash *)",
      "Bash(pnpm *)",
      "Bash(npx tsc *)",
      "Bash(npx jest *)",
      "Bash(cat *)",
      "Bash(ls *)",
      "Bash(find *)",
      "Bash(grep *)",
      "Bash(head *)",
      "Bash(tail *)",
      "Bash(wc *)"
    ],
    "deny": [
      "Bash(git push --force *)",
      "Bash(rm -rf *)",
      "Bash(pnpm publish *)"
    ]
  }
}
```

**What this does:** Claude never asks permission for read-only and
standard dev commands. Destructive commands still require approval.

---

## 3. Slash Commands

### `/project:implement` -- Execute a spec phase without discussion

```markdown
<!-- .claude/commands/implement.md -->
Read the spec at docs/specs/$ARGUMENTS.

Implement the next unchecked phase. Follow these rules:
1. Write tests first, then implement
2. Run tests after each function
3. If tests fail, fix before moving on
4. If ambiguous, add a TODO comment and keep moving
5. Commit after each passing phase
6. Check off completed tasks in the spec
7. Stop after one phase. Do not start the next.

Do not ask questions. Do not explain your approach. Just implement.
```

**Usage:** `/project:implement opener-library`
**Why:** Prevents Claude from having a design discussion when you want code.

---

### `/project:plan` -- Planning session with spec output

```markdown
<!-- .claude/commands/plan.md -->
I want to build: $ARGUMENTS

Interview me about this feature. Ask about:
- Core requirements and acceptance criteria
- Data model and API contracts
- Edge cases I haven't considered
- What's explicitly out of scope

Keep interviewing until we've covered everything.
Then write a complete spec to docs/specs/ with:
- Requirements (testable statements)
- Out of Scope section
- Technical Design (data model, API shapes, components)
- Implementation Phases with checkbox task lists
- Each phase must have a "Verify" step

Use think hard mode for the spec writing.
```

**Usage:** `/project:plan proposal opener library with filtering`
**Why:** Separates planning from execution. Spec becomes the handoff doc.

---

### `/project:review` -- Quick code review

```markdown
<!-- .claude/commands/review.md -->
Review the current git diff. Check for:
- Type safety issues
- Missing error handling
- Untested code paths
- Security concerns in auth/payment code
- Violations of conventions in CLAUDE.md

Be concise. List issues as: [file:line] issue description.
If everything looks good, say so in one line.
```

**Usage:** `/project:review`

---

### `/project:commit` -- Smart commit with conventional format

```markdown
<!-- .claude/commands/commit.md -->
Look at the staged changes (git diff --cached).
Write a conventional commit message:

Format: type(scope): description

Types: feat, fix, refactor, test, docs, chore
Scope: the main area affected (auth, ui, api, db)

Keep the subject line under 72 characters.
Add a body only if the "why" isn't obvious from the diff.
Stage all related unstaged changes first if they're part of the same unit of work.
Commit. Do not push.
```

**Usage:** `/project:commit`

---

### `/project:cleanup` -- End-of-session hygiene

```markdown
<!-- .claude/commands/cleanup.md -->
Before I end this session:
1. Run the type checker: npx tsc --noEmit
2. Run the linter: pnpm lint
3. Run the test suite: pnpm test
4. Check for uncommitted changes: git status
5. If there are failing tests or lint errors from our changes, fix them
6. If there are uncommitted changes from our work, stage and commit them
7. Update the spec (if we were working from one) -- check off completed tasks
8. List any TODO comments we added this session
```

**Usage:** `/project:cleanup` (run before ending any session)

---

## 4. Agents (Subagents)

### Researcher -- Explore without polluting main context

```yaml
# .claude/agents/researcher.md
---
name: Researcher
description: Explores codebase and documentation without affecting main context
tools:
  - Read
  - Glob
  - Grep
  - Bash(cat *)
  - Bash(find *)
  - Bash(wc *)
model: haiku
---

You explore code and docs and return concise summaries.

Rules:
- Never modify files
- Summarize findings in under 20 lines
- Include exact file paths for anything relevant
- If you find nothing relevant, say so in one line
```

**When to use:** Before implementation, to understand existing patterns.
"Use @researcher to find how we handle auth in the existing codebase"

**Why haiku:** Exploration is cheap work. No need for expensive models.
Subagent output stays in its own context, only the summary returns.

---

### Implementer -- Focused coding with no design discussion

```yaml
# .claude/agents/implementer.md
---
name: Implementer
description: Implements features from specs, writes tests, commits
tools:
  - Read
  - Write
  - Bash(pnpm *)
  - Bash(npx *)
  - Bash(git add *)
  - Bash(git commit *)
  - Bash(git diff *)
  - Bash(cat *)
  - Bash(ls *)
model: sonnet
---

You implement code based on specs. Rules:
- Read the spec first. Follow it exactly.
- Write tests before implementation
- Run tests after each function
- TypeScript strict mode, no `any`, named exports only
- If ambiguous, add a TODO comment and continue
- Commit after each passing test suite
- Do not refactor unrelated code
- Do not ask questions
- Do not start phases you weren't assigned
```

**When to use:** Delegating a well-defined spec phase.
"@implementer Read docs/specs/opener-library.md and implement Phase 2"

---

### Reviewer -- Isolated code review

```yaml
# .claude/agents/reviewer.md
---
name: Reviewer
description: Reviews code changes for bugs, type safety, and conventions
tools:
  - Read
  - Grep
  - Glob
  - Bash(git diff *)
  - Bash(git log *)
  - Bash(pnpm test *)
  - Bash(npx tsc --noEmit *)
model: sonnet
---

You review code. Never modify files.

Check for:
- Type safety (run tsc --noEmit)
- Missing error handling
- Untested code paths (run tests, check coverage)
- Security issues in auth/data access code
- Inconsistencies with project conventions

Output format:
🔴 [file:line] Critical: description
🟡 [file:line] Warning: description
🟢 Summary: one line overall assessment
```

**When to use:** After implementation, before merging.
"@reviewer Review the changes on this branch vs main"

---

## 5. Hooks -- Only the Essentials

### Commit-time test gate (the one hook everyone should have)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git commit*)",
        "hooks": [
          {
            "type": "command",
            "command": "pnpm test 2>&1 | tail -30",
            "blocking": true
          }
        ]
      }
    ]
  }
}
```

**What it does:** Every time Claude tries to commit, tests run first.
If tests fail, the commit is blocked and Claude sees the failure output.
Claude fixes the issue and tries again. Natural test-fix loop.

### Block commits to main (safety net)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git commit*)",
        "hooks": [
          {
            "type": "command",
            "command": "[ \"$(git branch --show-current)\" != \"main\" ] || { echo '{\"block\": true, \"message\": \"Cannot commit directly to main\"}' >&2; exit 2; }",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

---

## 6. How People Actually Use Subagents

### Pattern A: Explore then execute (most common)

```
You:   "I need to add search to the opener library"
       "@researcher Find how search/filtering is implemented anywhere
        in the current codebase. Check for existing Supabase text
        search patterns."

       [Researcher returns 10-line summary with file paths]

You:   "Good. Now implement search on the openers API route following
        the pattern in src/app/api/clients/route.ts"
```

Main session stays clean. Research output (which could be thousands
of lines of file contents) lived and died in the subagent's context.

### Pattern B: Parallel specialists

```
You:   "@implementer Read docs/specs/opener-library.md Phase 3.
        Build the OpenerCard and OpenerList components."

       [While that runs...]

You:   "@reviewer Check the Phase 2 API route we committed earlier.
        Make sure error handling is solid."
```

Two agents working independently, each in its own context window.

### Pattern C: Main as orchestrator (advanced)

```
You:   "Read docs/specs/opener-library.md. For each phase:
        1. Delegate to @implementer
        2. When done, delegate to @reviewer
        3. If reviewer finds issues, delegate back to @implementer
        4. Move to next phase only when reviewer approves
        Start with Phase 1."
```

You become the project manager. Claude's main session is lean because
all the heavy file reading/writing happens in subagent contexts.

---

## 7. What NOT to Add

Things that waste context with zero benefit:

- Don't add long coding style guides (use a linter instead)
- Don't add personality instructions ("be friendly", "use emojis")
- Don't restate things Claude already knows ("TypeScript is a typed JS")
- Don't copy-paste framework docs (Claude knows React/Next.js)
- Don't list every file in your project (Claude can explore)
- Don't add rules you haven't actually needed yet (add after a real mistake)
- Don't add multiple MCP servers you rarely use (each one eats context)

---

## 8. Starter Kit -- Copy This

```
your-project/
├── CLAUDE.md                          # 20-30 lines (see section 1)
├── docs/
│   └── specs/                         # Feature specs live here
│       └── _template.md               # Reusable spec template
├── .claude/
│   ├── settings.json                  # Permissions + hooks (see section 2)
│   ├── commands/
│   │   ├── implement.md               # /project:implement
│   │   ├── plan.md                    # /project:plan
│   │   ├── review.md                  # /project:review
│   │   ├── commit.md                  # /project:commit
│   │   └── cleanup.md                 # /project:cleanup
│   └── agents/
│       ├── researcher.md              # Cheap exploration (haiku)
│       ├── implementer.md             # Focused coding (sonnet)
│       └── reviewer.md                # Code review (sonnet)
└── src/
    └── ...
```

Total config: ~200 lines across all files. No rules directory needed
at this scale. No skills. No MCP servers. Add complexity only when
the simple setup measurably fails you.
