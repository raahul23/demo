# Contributing to GoApp

Thanks for helping improve GoApp. This guide explains how the team should work together: branching, syncing, testing, and PR flow.

## Ground Rules
- Pull latest changes before you start work.
- Work on a feature branch (never commit directly to `main`).
- Keep PRs small and focused.
- Run tests relevant to your change before asking for review.
- Follow existing architecture (Clean Architecture + BLoC).

## Branching Strategy
We use short‑lived feature branches.

**Branch name format**
```
feature/<short-description>
fix/<short-description>
chore/<short-description>
```

Examples:
```
feature/payment-flow
fix/location-permission-loader
chore/update-docs
```

## Daily Workflow
1. **Sync with main**
   ```
   git checkout main
   git pull
   ```

2. **Create a branch**
   ```
   git checkout -b feature/<name>
   ```

3. **Work + commit**
   ```
   git status
   git add .
   git commit -m "feat: <short summary>"
   ```

4. **Push branch**
   ```
   git push -u origin feature/<name>
   ```

5. **Open a PR** to `main`.

## Keeping Your Branch Up‑to‑Date
Rebase or merge from `main` regularly to avoid conflicts.

**Option A: Rebase**
```
git fetch origin
git rebase origin/main
```

**Option B: Merge**
```
git fetch origin
git merge origin/main
```

If conflicts happen, resolve them locally, then continue:
```
git add .
git rebase --continue
```

## Commit Message Style
Use conventional prefixes:
- `feat:` new feature
- `fix:` bug fix
- `chore:` tooling/infra
- `refactor:` internal changes
- `test:` test changes

Example:
```
feat: add booking service selector
```

## Code Quality Checklist
Before requesting review:
- Run unit tests for what you changed.
- Ensure formatting and linting follow existing project standards.
- Update or add tests if behavior changed.
- Keep UI logic in BLoC/Cubit (pages should be UI-only).

## Testing
Run all tests if you touched core flows:
```
flutter test
```

Run targeted tests if you touched specific features:
```
flutter test test/<file>_test.dart
```

## Pull Request Checklist
Include:
- What you changed (summary)
- Screenshots for UI changes
- Test output (at least relevant tests)

## API Update Checklist
If you add or change any networked feature:
- Update `docs/api_spec.md` with the new endpoint(s)
- Include request/response examples
- Note headers or auth requirements

## Team Prompt Templates
See `TEAM_PROMPTS.md` for recommended Codex prompts and team standards.

## Architecture Reference
See `ARCHITECTURE.md` for project structure, state management, and file purposes.

## Flutter Commands Reference
See `FLUTTER_COMMANDS.md` for dev/test/build commands.

## Conflict Avoidance Tips
- Don’t let branches live too long.
- Pull from `main` daily.
- Communicate when you’re editing shared files (routes, DI, core widgets).

## Code Ownership
If you’re changing shared core code, tag the team lead for review.
