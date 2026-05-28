# goapp

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## API Keys
- Flutter env key (Places/Geocoding/Routes): set via `--dart-define=GOOGLE_MAPS_API_KEY=...` (preferred) or in `assets/env/dev.env` and keep real keys out of version control.
- Android Maps key: set `GOOGLE_MAPS_API_KEY` in `android/local.properties` or an environment variable during build.
- iOS Maps key: set `GOOGLE_MAPS_API_KEY` in `ios/Flutter/Keys.local.xcconfig` (ignored) or via Xcode build settings.

## API Specification
See `docs/api_spec.md` for current and planned API endpoints used by the app.

## Team Prompts
See `TEAM_PROMPTS.md` for Codex prompt templates and team standards.

## Architecture
See `ARCHITECTURE.md` for project structure, state management, and file purposes.

## Flutter Commands
See `FLUTTER_COMMANDS.md` for dev/test/build commands.
