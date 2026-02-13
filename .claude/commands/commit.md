Look at all the changes in the current git working tree (staged and unstaged) using `git status` and `git diff`. Also check `git log --oneline -5` to understand the recent commit style.

Then:

1. Stage all relevant changed files (prefer specific filenames over `git add -A`)
2. Write a concise commit message that follows the style of recent commits in the repo
3. The message should focus on the "why" not the "what"
4. Keep the subject line under 72 characters
5. Do NOT commit files that look like they contain secrets (e.g. `.env`, credentials)
6. Create the commit

If there are no changes to commit, say so and stop.
