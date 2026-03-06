# Git Workflow

## Branches

- Always use feature branches; do not commit directly to `main`
- Name branches descriptively: `fix/auth-timeout`, `feat/api-pagination`, `chore/ruff-fixes`
- Keep one logical change per branch to simplify review and rollback

## Pull Requests

- Open a draft PR early for visibility; convert to ready when complete
- Ensure tests pass locally before marking ready for review
- Use PRs to trigger CI/CD and enable async reviews
- PR description: focus on the high-level problem and how it is solved, not code specifics

## Issues

- Before starting, reference an existing issue or create one
- Use commit/PR messages like `Fixes #123` for auto-linking and closure

## Commits

- Make atomic commits (one logical change per commit)
- Prefer conventional commit style: `type(scope): short description`
  - Examples: `feat(eval): group OBS logs per test`, `fix(cli): handle missing API key`
- Squash only when merging to `main`; keep granular history on the feature branch
- Check git status before committing

## Practical Workflow

1. Create or reference an issue
2. `git checkout -b feat/issue-123-description`
3. Commit in small, logical increments
4. `git push` and open a draft PR early
5. Convert to ready PR when functionally complete and tests pass
6. Merge after reviews and checks pass
