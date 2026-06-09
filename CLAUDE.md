# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.

## Project Overview

Klozy is a Flutter claims application with Firebase backend. Uses Clean Architecture with BLoC
state management. English localization only.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (routes, DI, JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Generate asset constants
fluttergen

# Run linting
flutter analyze lib

# Format code
dart format lib

# Scaffold a new feature using Mason (MANDATORY for new features)
cd mason && mason get && mason make feature --name <feature_name> -o ../lib/src/feature

# Generate localization files
flutter gen-l10n
```

**Global tools needed:** `dart pub global activate mason_cli` and
`dart pub global activate flutter_gen`

## Architecture

Clean Architecture with three layers per feature:

- **Domain** — repository interfaces, entities (Equatable), use cases (one per business operation)
- **Data** — repository implementations, remote/local data sources, response models (
  @JsonSerializable), mappers (response → entity). **Remote data sources must return response models
  (e.g. `ClaimResponse`, `PaginatedListResponse<T>`), never domain entities.** Mapping from response
  to entity happens in the repository implementation, not the data source.
- **Presentation** — BLoC (events/states as sealed classes), pages, state-specific widgets

Features live under `lib/src/feature/` and follow this structure:

```
feature/{name}/
├── data/
│   ├── datasource/
│   ├── mapper/
│   ├── response/
│   └── {name}_repository_impl.dart
├── domain/
│   ├── entity/
│   ├── usecase/
│   └── {name}_repository.dart
└── presentation/
    ├── bloc/ ({name}_bloc.dart, {name}_event.dart, {name}_state.dart)
    └── screen/
        ├── {name}_page.dart
        ├── states/ (idle, loading, error widgets)
        └── widgets/
```

**Shared vs feature domain:** Domain models (entities, use cases, repositories) used by multiple
features must live under `lib/src/domain/` (e.g. `claim/`, `authentication/`, `user/`), not inside a
single feature's `domain/` folder. Feature-local domain that is only used within that feature stays
under `lib/src/feature/{name}/domain/`.

## Creating New Features

**MANDATORY: Always use Mason to scaffold new features.** Never manually create feature directories
or boilerplate files.

Steps:

1. Run `cd mason && mason get && mason make feature --name <feature_name> -o ../lib/src/feature`
2. Mason generates: data layer (datasource, repository impl), domain layer (repository interface),
   presentation layer (BLoC with sealed classes, page, state widgets)
3. Edit the generated files to add feature-specific logic (use case, events, states, UI)
4. Create `domain/usecase/` directory manually if needed (Mason does not generate it)
5. Register the new route in `lib/src/router/app_router.dart`
6. Add l10n keys to `lib/l10n/app_en.arb`
7. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate routes and DI
8. Run `flutter analyze lib` and `dart format lib` to verify

## Key Architectural Decisions

- **DI:** GetIt + Injectable. Register with `@injectable`, `@lazySingleton`, or `@module`. DI setup
  in `lib/src/di/`. Modules: `AppModule` (EventBus, SecureStorage, SharedPreferences, AppUrls),
  `NetworkModule` (Dio with interceptors), `FirebaseModule` (FirebaseAuth, FirebaseMessaging).
- **Routing:** AutoRoute with code generation. Routes defined in `lib/src/router/app_router.dart`.
  Guards: `AuthenticationGuard` (redirects logged-in users away from login), `OtherScreensGuard` (
  requires auth). Both guards use `IsLoggedInUseCase`.
- **State management:** BLoC at feature level, `AppBloc` for global state (logout), `ChangeNotifier`
  for theme/locale via `AppConfigChangeNotifier`.
- **Network:** Dio with two interceptors: `AuthenticationInterceptor` (Bearer token from
  FlutterSecureStorage + 401 refresh) and `DefaultInterceptor` (Accept, Accept-Language,
  Content-Type headers). Base URL: `https://api.klozy.com/` (same for dev and prod).
- **Storage:** SharedPreferences for settings (locale, dark mode) via `Prefs` class.
  FlutterSecureStorage for auth tokens.
- **Firebase:** Auth (phone, Google, Apple, anonymous), Messaging, App Check. Initialized in
  `AppInitializer`.
- **Pagination:** Shared `PaginatedList` entity and `PaginatedListResponse` model in
  `lib/src/core/pagination/`.

## Navigation Structure

- **Home page** (`/claims`): `ClaimsPage` is the top-level authenticated route. It shows the claims
  list, a persistent full-width "Start a claim" button in the `bottomNavigationBar` slot, and a
  `PopupMenuButton` (`HomeAppBarMenu`) in the app bar actions that exposes the "More" settings
  (dark theme toggle, privacy, terms, logout, version).
- **Claim details**: `/claims/:id` is a top-level sibling route, not nested under `ClaimsRoute`
  (since `ClaimsPage` is a regular `@RoutePage`, not an `AutoRouter`).
- **Full-screen routes**: top-level routes like `/start-claim` with `OtherScreensGuard`
- **Login**: `/login` is the initial route, guarded by `AuthenticationGuard` which redirects
  logged-in users to `/claims`
- **More settings**: `MoreBloc` is consumed only by `HomeAppBarMenu` — there is no longer a
  standalone More page or tab.

## Code Conventions

- BLoC events and states must be **sealed classes** with **@immutable** annotation and **final**
  subclasses
- Always use **package imports** (not relative imports)
- Use **Equatable** for entities and BLoC states/events
- Use **trailing commas** everywhere
- Always declare return types
- Prefer const constructors
- **Context extensions** (from `lib/src/core/extensions/context_ext.dart`): always use
  `context.l10N` for localization, `context.colorScheme` for colors, `context.textTheme` for text
  styles, `context.showSnackBar()` for snackbars. **Never** use `Theme.of(context)` or
  `ScaffoldMessenger.of(context)` directly.
- Mappers transform data-layer responses to domain entities
- Cross-feature dependencies only through domain layer, never presentation/data
- **Design system** — Klozy is a single **dark** theme (black surface, gold `#E0CE7D` accent,
  Poppins via `google_fonts`). Tokens live in `lib/src/design/tokens/` (`DSColor`, `DSSpacing`,
  `DSBorderRadius`, `DSFontSize`/`DSFontWeight`/`DSFontHeight`, `dsFontFamily`) and the theme is
  built by `dsTheme()` (`tokens/ds_theme.dart`). Shared components are the `DS*` widgets in
  `lib/src/design/components/` (e.g. `DSButtonElevated`, `DSTextField`, `DSProductCard`,
  `DSAppBar`, `DSChip`). Reuse these before writing new UI.
- **No magic numbers** — use the DS tokens (`DSSpacing`, `DSBorderRadius`, `DSFontSize`) instead of
  inline numbers; add a token rather than hardcoding. There is **no** `Dimens`/`AppText`/light theme.
- **Platform APIs (image picker, camera, etc.) must be called in the widget layer**, not inside BLoC
  handlers. Pass results to the BLoC via events. BLoC emitters close when the handler completes, so
  awaiting platform UI inside a handler will fail silently.
- **Theme colors**: UI components should use `context.colorScheme` / `DSColor` tokens, not hardcoded
  colors. The app is single dark mode (no light/dark toggle).
- Pages implement `AutoRouteWrapper` and inject their BLoC via `BlocProvider` in `wrappedRoute()`
- Pages use `BlocConsumer` with separate `_builder`, `_listener`, `_buildWhen`, `_listenWhen`
  methods
- **No helper functions that return widgets.** Never create methods like `Widget _buildSomething()`
  inside a widget class. Instead, always extract the widget into its own `StatelessWidget` or
  `StatefulWidget` class in a separate file under the feature's `widgets/` directory, and use it as
  an object (e.g., `SomethingWidget()`). This applies to all widget code — pages, state widgets, and
  reusable components.
- **One class per file.** Every `.dart` file must contain at most one class. If you need multiple
  classes (e.g., a widget and its helper), put each in its own file. The only exception is sealed
  class hierarchies (e.g., BLoC events/states) where the sealed parent and its subclasses belong
  together.

## Localization

ARB files in `lib/l10n/` — `app_en.arb` (English only). Default locale is English. Group keys by
feature using `@_feature_name` comment separators. Config in `l10n.yaml`.

## After Every Change

After completing each task or change, you **must**:

1. Run `git status` and `git diff` to review all local changes
2. Write a comprehensive commit message summarizing the changes — include what was changed, why, and
   any notable details
3. Present the commit message to the user for review
4. **Do NOT commit the changes** — only propose the message

## CI

GitHub Actions (`.github/workflows/flutter_analyze.yml`) runs on pushes/PRs to main (Flutter
3.32.1):

1. `dart format --set-exit-if-changed lib`
2. `flutter analyze lib`


<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:ca08a54f -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

## Session Completion

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd dolt push
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
<!-- END BEADS INTEGRATION -->
