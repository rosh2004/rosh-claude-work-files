# CLAUDE.md

## Commands
- Dev: pnpm dev
- Test: pnpm test
- Lint: pnpm lint
- Types: npx tsc --noEmit

## Stack
- Next.js 15 App Router, TypeScript strict
- Supabase (Postgres + Auth + RLS)
- Tailwind CSS

## Conventions
- Named exports only
- Server components by default, "use client" only when needed
- All Supabase queries go through src/lib/db/
- Never use `any` — use `unknown` and narrow

## Testing
- Colocate tests next to source files
- Test file naming: *.test.ts
