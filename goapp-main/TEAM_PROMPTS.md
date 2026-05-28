# Codex Team Prompt Templates

Use these prompts when working on features, bugs, or UI changes. They are aligned with this repo’s Clean Architecture + BLoC structure and test practices.

---

## 1) New Feature (Clean Architecture + BLoC)
```
Implement <feature name> using Clean Architecture + BLoC.

Requirements:
- Domain: entities + usecases
- Data: datasource + repository + mock data
- Presentation: cubit/bloc + state + UI
- DI updates in core/di/injection.dart
- Tests for datasource/repo/usecase/cubit + widget tests if UI changed
- Keep UI stateless, logic only in BLoC/Cubit

Follow existing project structure.
```

---

## 2) Bug Fix
```
Fix the following bug(s) and update tests if needed.

Bug:
- <paste exact error / stack trace / failing test>

Constraints:
- Don’t change UI design unless required to fix.
- Keep logic in cubit/bloc.
- Re-run tests and report failures.
```

---

## 3) UI Addition (No Logic in Widgets)
```
Add/modify UI for <screen>.
Keep UI-only in widget.
Move any new logic into cubit/bloc or service.
Update widget tests if UI changes.
```

---

## 4) API + Mock Data
```
Add mock API layer for <feature>.
Provide datasource + repository + usecase.
Include mock request/response shapes in docs/api_spec.md.
```

---

## 5) Tests Only
```
Write tests for <file/feature>:
- datasource
- repository
- usecase
- cubit
- widget (if UI changes)
```

---

## 6) Performance / SOLID Refactor
```
Refactor <feature> to follow SOLID:
- Move logic into usecases/services
- UI becomes pure widget
- Split responsibilities (progress, notification, persistence)
- Update tests
```

---

## Team Standards (include in all prompts)
- Use clean architecture + BLoC.
- UI only in widgets.
- Mock API if backend not ready.
- Update DI + tests.
- Keep existing UI unchanged unless specified.

