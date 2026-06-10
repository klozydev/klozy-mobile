# core_kosmos - Documentation AI

> Package fondamental de l'écosystème Kosmos Digital. Fournit l'architecture de base, la gestion des configurations, les thèmes et les utilitaires communs.

---

## 📋 Informations Rapides

| Attribut | Valeur |
|----------|--------|
| **Package** | `core_kosmos` |
| **Import** | `package:core_kosmos/core_kosmos.dart` |
| **Dépendances** | Aucun package Kosmos (package racine) |
| **Rôle** | Fondation de l'écosystème |

---

## 📁 Structure du Package

```
core/
├── lib/
│   ├── core_kosmos.dart          # Export principal (barrel file)
│   └── src/
│       ├── core/
│       │   └── launcher.dart     # Application.launch()
│       ├── config/
│       │   ├── config.dart       # PackageConfig, DependenciesConfig
│       │   ├── user_config.dart  # UserConfig
│       │   ├── event_config.dart # EventConfiguration
│       │   ├── firebase.dart     # FirebaseConfig
│       │   └── google_map.dart   # GoogleMapConfig
│       ├── model/
│       │   ├── app_model.dart    # AppModel
│       │   ├── user/             # UserModel
│       │   └── ...
│       ├── controller/
│       │   ├── metadata_controller.dart
│       │   ├── notif_controller.dart
│       │   ├── event_controller.dart
│       │   └── ...
│       ├── provider/
│       │   ├── user_provider.dart
│       │   └── notification_stream_status.dart
│       ├── theme/
│       │   ├── app_theme.dart    # AppTheme, loadThemeData()
│       │   └── color_scheme.dart # DefaultColor
│       ├── extension/
│       │   ├── list.dart, num.dart, color.dart
│       │   ├── datetime.dart, string.dart
│       │   └── context_ext.dart
│       ├── responsive/
│       │   └── responsive.dart   # sp(), formatW(), formatH()
│       └── utils/
│           ├── field_validator.dart
│           ├── platform.dart
│           └── ...
└── pubspec.yaml
```

---

## 🔑 Clés de Configuration

| Type | Clé | Constante | Description |
|------|-----|-----------|-------------|
| Config | `"kosmos_event_config"` | `EventConfiguration.key` | Push notifications |
| Config | `"google_map"` | `GoogleMapConfig.key` | Google Maps API |

---

## 🏗️ Classes Fondamentales

### AppModel

```dart
AppModel(
  appTitle: "MonApp",
  userConfig: UserConfig(fromJson: (json, type) => MyUser.fromJson(json)),
  firebase: FirebaseConfig(enabled: true),
  dependencies: DependenciesConfig(packages: {...}),
  excuteAfterFirebaseInitialized: () async { ... },
);
```

### Application.launch()

```dart
await Application.launch(
  initModel(),           // AppModel
  AppRouter(...),        // auto_route router
  initTheme: initTheme,  // (BuildContext, AppModel) => AppTheme
  onInit: () async { ... },
);
```

### PackageConfig

```dart
abstract class PackageConfig {
  final String packageName;
  const PackageConfig(this.packageName);
}

// Convention: toute config DOIT avoir une clé statique
class MyConfig extends PackageConfig {
  static const String key = "my-config";
  const MyConfig() : super(key);
}
```

### AppTheme & loadThemeData

```dart
// Enregistrement
appTheme.addTheme("button_primary", myButtonTheme);
appTheme.addThemeDark("button_primary", myDarkButtonTheme);

// Récupération
final theme = loadThemeData<MyThemeData>(
  widget.theme,           // Priorité 1: paramètre direct
  themeName ?? "my-key",  // Priorité 2: clé dans AppTheme
  () => kDefaultTheme,    // Priorité 3: fallback
  isDark: isDarkMode,
);
```

---

## 🔧 Fonctions Utilitaires

### Getters globaux

```dart
getAppModel()              // → AppModel (via GetIt)
getAppTheme()              // → AppTheme (via GetIt)
```

### Responsive

```dart
sp(16)                     // Scaled font size
formatW(100)               // Width responsive
formatH(50)                // Height responsive
```

### Providers (Riverpod)

```dart
ref.watch(userProvider).user           // UserModel?
ref.watch(isDarkModeProvider).isDarkMode  // bool
```

---

## ✅ Conventions Obligatoires

### 1. Clés statiques (Zéro inline keys)

```dart
// ❌ INTERDIT
packages["kosmos_event_config"]

// ✅ OBLIGATOIRE
packages[EventConfiguration.key]
```

### 2. Getter avec fallback

```dart
XConfig getXConfig() {
  final config = getAppModel().dependencies.packages[XConfig.key];
  assert(config == null || config is XConfig, 'Type mismatch');
  return (config as XConfig?) ?? const XConfig();
}
```

### 3. Theme avec fallback

```dart
final theme = loadThemeData<MyTheme>(
  widget.theme,
  MyThemeKeys.main,
  () => kDefaultMyTheme,  // TOUJOURS un fallback
  isDark: isDark,
);
```

---

## 🧪 Tests & Commandes

```bash
cd core
dart format .
dart analyze
dart test
```

---

## ✔️ Definition of Done (DoD)

- [ ] Aucune clé inline (utiliser `XConfig.key`)
- [ ] Fallback sur config (`?? const XConfig()`)
- [ ] `dart format .` OK
- [ ] `dart analyze` OK
- [ ] Tests passants

---

## 📚 Exports Principaux

```dart
// Core
export 'src/core/launcher.dart';              // Application

// Config
export 'src/config/config.dart';              // PackageConfig, DependenciesConfig
export 'src/config/event_config.dart';        // EventConfiguration
export 'src/config/firebase.dart';            // FirebaseConfig

// Model
export 'src/model/app_model.dart';            // AppModel
export 'src/model/user/user.dart';            // UserModel

// Provider
export 'src/provider/user_provider.dart';     // userProvider

// Theme
export 'src/theme/app_theme.dart';            // AppTheme, loadThemeData
export 'src/theme/color_scheme.dart';         // DefaultColor

// Responsive
export 'src/responsive/responsive.dart';      // sp, formatW, formatH

// Re-exports utiles
export 'package:easy_localization/easy_localization.dart';
export 'package:get_it/get_it.dart';
export 'package:hooks_riverpod/hooks_riverpod.dart';
export 'package:auto_route/auto_route.dart';
```
