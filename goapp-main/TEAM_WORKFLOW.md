# Team Workflow (Step‑by‑Step)

This guide is for all team members working on GoApp.

## 1) First‑time setup
1. Clone the repo.
2. Run `flutter pub get`.
3. Run `flutter test` once to confirm setup.

### GitHub Account Setup (Required)
1. Each member must have a GitHub account and share their username with the lead.
2. The lead adds them as collaborators:
   - **Repo → Settings → Collaborators → Add people**
3. Authenticate locally using **one** method:

**Option A: Personal Access Token (HTTPS)**
- Username = GitHub username
- Password = PAT

**Option B: SSH (Recommended)**
```bash
ssh-keygen -t ed25519 -C "email@example.com"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```
Add the key in GitHub → **Settings → SSH Keys**

4. Set the correct remote:

**HTTPS:**
```bash
git remote set-url origin https://github.com/sybgodev-ctrl/goapp.git
```

**SSH:**
```bash
git remote set-url origin git@github.com:sybgodev-ctrl/goapp.git
```

## 2) Daily work cycle
1. **Start from `development`**
   ```bash
   git checkout development
   git pull
   ```
2. **Create a feature/bugfix branch**
   ```bash
   git checkout -b feature/<short-name>
   # or
   git checkout -b bugfix/<short-name>
   ```
3. **Work using project rules**
   - Clean Architecture (`data → domain → presentation`)
   - UI pages are **pure** (BLoC actions only)
   - Update `docs/api_spec.md` for new endpoints
   - Add tests for new logic
4. **Run tests locally**
   ```bash
   flutter test
   ```
5. **Commit**
   ```bash
   git add .
   git commit -m "feat: <short summary>"
   ```
6. **Push your branch**
   ```bash
   git push -u origin feature/<short-name>
   ```
7. **Open a PR**
   - Target branch: **development**
   - Fill in summary + test results

## 3) Review & merge
- Only the team lead merges to `development`.
- PR must have:
  - ✅ 1 approval
  - ✅ CI checks passing

## 4) Release flow
- `main` is production.
- Only team lead merges `development → main`.
- No auto‑merge.

## 5) Quick rules (non‑negotiable)
- No direct pushes to `development` or `main`.
- No business logic inside UI widgets.
- Keep BLoC/Cubit as the single source of UI state.
- Add/adjust tests for every feature or bug fix.
