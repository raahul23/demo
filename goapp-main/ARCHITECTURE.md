# GoApp Architecture Overview

This document explains the project structure, state management, and the purpose of each major folder/file type. It is intended for all contributors working in Codex.

---

## 1) High‑Level Architecture
We follow **Clean Architecture** with **BLoC/Cubit** for state management:

```
Presentation (UI) → Domain (Usecases) → Data (Repositories/DataSources)
```

- **Presentation**: UI widgets only. No business logic.
- **Domain**: Entities + Use Cases + Domain Services.
- **Data**: Remote/Local data sources + Repositories (implement domain contracts).

---

## 2) State Management
We use **flutter_bloc**:

- **Cubit** for simple state flows.
- **Bloc** when explicit events are needed.

**Rule:** UI widgets do not contain business logic. All logic goes into cubits/blocs or domain services.

---

## 3) Folder Structure (Summary)
```
lib/
  core/                    # Cross‑feature utilities & infrastructure
  features/                # All features, isolated by domain
test/                      # Unit + widget tests
assets/                    # Images, icons, map styles, env files
```

---

## 4) Core Layer
`lib/core/` contains shared services and infrastructure:

| Folder | Purpose |
|--------|---------|
| `di/` | Dependency injection (GetIt registrations) |
| `network/` | API client, endpoints, Google APIs |
| `services/` | Native services (location, notifications, overlays) |
| `maps/` | Common map widgets + marker controllers |
| `onboarding/` | Onboarding state + persistence |
| `utils/` | Shared utilities (snackbar, env, map styles) |

---

## 5) Feature Structure
Each feature follows the same structure:

```
features/<feature_name>/
  data/
    datasources/           # Remote/Local APIs
    models/                # JSON/data models
    repositories/          # Repo implementations
  domain/
    entities/              # Pure domain models
    repositories/          # Abstract repo contracts
    usecases/              # Business usecases
    services/              # Domain helpers/validators
  presentation/
    bloc/ or cubit/         # State management
    pages/                  # UI pages/screens
    widgets/                # UI-only reusable widgets
```

---

## 6) Dependency Injection
All dependencies are registered in:
```
lib/core/di/injection.dart
```

When adding a feature:
1. Register data sources
2. Register repositories
3. Register usecases
4. Register bloc/cubit

---

## 7) Mock Data & API Layer
If backend isn’t ready:
- Use mock data in datasource implementations.
- Add new endpoint specs to `docs/api_spec.md`.

---

## 8) Testing Strategy
Tests live in `/test`:

- **Data source tests** (mock API)
- **Repository tests**
- **Usecase tests**
- **Cubit/Bloc tests**
- **Widget tests** (for UI changes)

---

## 9) Purpose of Key Files

| File | Purpose |
|------|---------|
| `README.md` | Project introduction |
| `CONTRIBUTING.md` | Team workflow |
| `TEAM_PROMPTS.md` | Codex prompt templates |
| `docs/api_spec.md` | API request/response contracts |
| `ARCHITECTURE.md` | System structure + conventions |

---

## 10) Golden Rules for Contributors
- UI is UI only — no business logic in widgets.
- Every feature goes through clean architecture.
- Always update tests and DI.
- Keep APIs documented in `docs/api_spec.md`.

