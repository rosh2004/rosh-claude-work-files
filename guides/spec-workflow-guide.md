# Spec-Driven Development with Claude Code

---

## Core Rules

- One feature = one spec file. Never combine features.
- Tasks live IN the spec as phased checklists. No separate task tracker.
- Progress is tracked IN the spec. Claude checks off tasks as it goes.
- Planning and coding are ALWAYS separate sessions.
- One phase per session. New session = fresh context.

---

## File Structure

```
docs/
├── ARCHITECTURE.md           # How the system fits together (under 50 lines, rarely updated)
└── specs/
    ├── _template.md          # Copy this for each new feature
    ├── opener-library.md     # In progress
    ├── proposal-builder.md   # Not started
    └── client-dashboard.md   # Complete
```

No tasks/ directory. No progress/ directory. The spec IS the tracker.

Add to CLAUDE.md:
```markdown
## Workflow
- Feature specs live in docs/specs/
- Read the relevant spec before starting any feature work
- Update spec checkboxes and session log after completing work
```

---

## Spec Template (`docs/specs/_template.md`)

```markdown
# Feature: [Name]

## Status: [Not Started | In Progress | Complete]
Current Phase: [None | Phase N]
Branch: feature/[name]

## Context
Why this exists. 2-3 sentences. Link to relevant code or prior specs.

## Requirements
Testable statements. You should be able to answer "yes it does" or "no it doesn't."
- Requirement 1
- Requirement 2

## Out of Scope
Prevents Claude from over-engineering.
- Not building X
- Not handling Y yet

## Technical Design

### Data Model
sql definitions or schema changes

### API Routes
- METHOD /api/path -- what it does
  - Request/Response shapes
  - Error cases

### Components
- ComponentName -- what it renders, what props

### Key Decisions
Non-obvious choices. Why A over B. Prevents re-debating.

## Implementation Phases

### Phase 1: [Name] -- [one sentence]
- [ ] Task (specific, atomic)
- [ ] Task
- [ ] Verify: [exact test command]

### Phase 2: [Name] -- [one sentence]
- [ ] Task
- [ ] Verify: [exact test command]

## Session Log
<!-- Claude appends after each session -->
```

---

## Workflow: Step by Step

### Step 1: Plan (planning session -- no code)

```
You: I want to build [feature description].
     Read docs/specs/_template.md for the format.
     Interview me about this feature before writing anything.
     Use think hard mode.
```

Claude interviews you about requirements, edge cases, scope.
You answer, push back, add things Claude missed.

When done:
```
You: Write the full spec to docs/specs/[feature].md.
     Include phases with atomic tasks. Each phase verifiable
     with a single test command.
```

Review the spec. Fix anything wrong. Commit. **End session.**

---

### Step 2: Implement one phase (execution session)

```
You: Read docs/specs/[feature].md. Implement Phase 1 only.

     Rules:
     - Write tests first, then implement
     - Run tests after each function
     - If tests fail, fix before moving on
     - If ambiguous, add a TODO comment and keep going
     - Commit when all tests pass
     - Check off completed tasks in the spec
     - Add a session log entry
     - Do not start Phase 2
```

Or with slash command: `/project:implement [feature]`

**End session.** Review the diff.

---

### Step 3: Repeat

New session for each phase. Same prompt:
```
You: Read docs/specs/[feature].md. Implement the next unchecked phase.
```

Between phases:
1. Review the diff
2. Run the app yourself
3. If design needs to change, update the spec BEFORE starting next session

---

### Step 4: Close

```
You: Read docs/specs/[feature].md. All phases complete.
     Run full test suite, type checker, linter.
     Fix any issues. Resolve TODO comments.
     Update spec status to Complete. Commit.
```

---

## Task Sizing

### The test
Can Claude do it, test it, and you review the diff in under 5 minutes?

### Too big
```markdown
- [ ] Create database, API, components, and page
```

### Too small
```markdown
- [ ] Add the id column
- [ ] Add the content column
- [ ] Add the category column
```

### Right size
```markdown
- [ ] Create migration for openers table (id, content, category, tone, tags[], created_at)
- [ ] Generate TypeScript types from schema
- [ ] Write seed script to import 38 openers from CSV
- [ ] Verify: `supabase db reset && pnpm test src/lib/db/openers.test.ts`
```

### Phase boundaries (each independently verifiable)

```
Phase 1: Data layer       -- data exists, queries work
Phase 2: API layer        -- endpoints return correct responses
Phase 3: UI components    -- components render with mock data
Phase 4: Integration      -- full flow works end-to-end
Phase 5: Polish           -- error states, loading states, edge cases
```

Rule: Phase 2 (API) must be testable without Phase 3 (UI) existing.

---

## Troubleshooting

**Claude goes off-spec:**
```
You: Stop. That's Phase 2, we're on Phase 1. Revert and continue
     with the next unchecked task in Phase 1 only.
```
Then add to CLAUDE.md: `Never implement tasks from future phases.`

**Stuck in a fix loop (2+ failed attempts):**
```
You: Stop. Write what's failing to the session log. Commit what works.
```
Then `/clear` or end session.

**Spec was wrong:**
```
You: Stop implementing. Update the spec to [new approach].
     Update affected tasks. Commit spec change separately.
```

**Resuming after days away:**
```
You: Read docs/specs/[feature].md and the session log.
     Summarize: what's done, what's next, any open TODOs.
```

---

## Quick Reference

| Question | Answer |
|----------|--------|
| Where do specs live? | `docs/specs/feature-name.md` |
| One spec per feature? | Yes, always |
| Where are tasks? | In the spec, as phased checklists |
| Where is progress? | In the spec (checkboxes + session log) |
| Separate planning from coding? | Always separate sessions |
| How big is a phase? | Verifiable in one session |
| How big is a task? | Reviewable diff in under 5 min |
| When to start new session? | Between every phase |
| What does Claude read first? | The spec file |
| When is a feature done? | All phases checked, status = Complete |
