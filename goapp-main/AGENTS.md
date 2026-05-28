## GoApp Agent Guide

This file is the single source of truth for how Codex agents should work in this repo.

### Architecture & Conventions
- **Clean Architecture**: `data` → `domain` → `presentation`.
- **State management**: BLoC/Cubit only. UI must be **pure** (no business logic).
- **DI**: GetIt in `/Users/kumaresanj/SybroxTech/Development/goapp/lib/core/di/injection.dart`.
- **API spec**: Update `/Users/kumaresanj/SybroxTech/Development/goapp/docs/api_spec.md` when adding endpoints.
- **Mocks**: Use mock data sources and repositories for now; keep code ready for real API integration.

### Feature Layout (Pattern)
```
lib/features/<feature>/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    bloc|cubit/
    pages/
    widgets/
```

### UI Rules
- UI pages **only render state** and **dispatch BLoC actions**.
- Put validation, formatting, timers, and async flows inside Cubits/UseCases.
- Use shared widgets in `/Users/kumaresanj/SybroxTech/Development/goapp/lib/core/widgets/` when reused.

### Testing
- Add unit tests for: datasources, repositories, usecases, cubits.
- Add widget tests for critical flows (navigation + key UI states).
- Run tests with:
```
flutter test
```

### Docs to Keep Updated
- `/Users/kumaresanj/SybroxTech/Development/goapp/README.md`
- `/Users/kumaresanj/SybroxTech/Development/goapp/CONTRIBUTING.md`
- `/Users/kumaresanj/SybroxTech/Development/goapp/docs/api_spec.md`
- `/Users/kumaresanj/SybroxTech/Development/goapp/TEAM_PROMPTS.md`
- `/Users/kumaresanj/SybroxTech/Development/goapp/ARCHITECTURE.md`

### Common Pitfalls
- Don’t use `BuildContext` across async gaps without `mounted`.
- Don’t add business logic inside widgets.
- Don’t bypass BLoC for navigation state changes.

