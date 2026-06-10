# ui_kosmos_v4 - Documentation AI

> Bibliothèque de composants UI réutilisables avec système de thèmes personnalisables.

---

## 📋 Informations Rapides

| Attribut | Valeur |
|----------|--------|
| **Package** | `ui_kosmos_v4` |
| **Import** | `package:ui_kosmos_v4/ui_kosmos_v4.dart` |
| **Dépendances Kosmos** | `core_kosmos` |
| **Rôle** | Composants UI de base |

---

## 📁 Structure du Package

```
ui/
├── lib/
│   ├── ui_kosmos_v4.dart         # Export principal
│   ├── button/                   # KosmosButton, BackButton, AuthTiersButton
│   │   └── theme/button_theme.dart
│   ├── field/                    # FormFields (text, phone, date, dropdown, etc.)
│   │   ├── form_item.dart
│   │   ├── field/                # Tous les types de champs
│   │   └── theme/form_field_theme.dart
│   ├── card/                     # KosmosCard
│   ├── alert/                    # Alertes et popups
│   ├── switch/                   # KosmosSwitch
│   ├── checkbox/
│   ├── slider/                   # KosmosSlider, RangeSlider
│   ├── picker/                   # Date pickers
│   ├── loader/                   # Loaders
│   ├── settings/                 # SettingsCellule
│   │   └── theme/cellule_theme.dart
│   ├── research/                 # Recherche avec filtres
│   ├── selector/
│   ├── toggle_switch/
│   ├── player/                   # Media player
│   ├── bottom_bar/               # Navigation bottom bar
│   ├── multiImagePicker/
│   └── items/                    # UserRow, DateRow, AddressRow, etc.
└── pubspec.yaml
```

---

## 🔑 Clés de Thème

| Clé | Constante | Type | Composant |
|-----|-----------|------|-----------|
| `"button_primary"` | `UiThemeKeys.buttonPrimary` | `KosmosButtonThemeData` | Boutons principaux |
| `"button_secondary"` | `UiThemeKeys.buttonSecondary` | `KosmosButtonThemeData` | Boutons secondaires |
| `"button_text"` | `UiThemeKeys.buttonText` | `KosmosButtonThemeData` | Boutons texte |
| `"button_icon"` | `UiThemeKeys.buttonIcon` | `KosmosButtonThemeData` | Boutons icône |
| `"form_field"` | `UiThemeKeys.formField` | `FormFieldThemeData` | Champs de formulaire |
| `"settings_cellule"` | `UiThemeKeys.settingsCellule` | `SettingsCelluleThemeData` | Cellules settings |

---

## 🧩 Composants Principaux

### KosmosButton

```dart
KosmosButton(
  text: "Valider",
  onPressed: () {},
  themeName: UiThemeKeys.buttonPrimary,  // ou theme: myCustomTheme
  isLoading: false,
  isEnabled: true,
);
```

### KosmosFormField

```dart
KosmosFormField(
  fieldName: "Email",
  hintText: "Entrez votre email",
  controller: _controller,
  validator: (v) => v.isEmpty ? "Requis" : null,
  themeName: UiThemeKeys.formField,
);
```

### SettingsCellule

```dart
SettingsCellule(
  title: "Notifications",
  subtitle: "Gérer les notifications",
  leading: Icon(Icons.notifications),
  trailing: KosmosSwitch(value: true, onChanged: (_) {}),
  onTap: () {},
  themeName: UiThemeKeys.settingsCellule,
);
```

### Autres composants

- **KosmosSwitch** - Interrupteur on/off
- **KosmosSlider** - Slider avec valeurs
- **KosmosCard** - Carte avec ombre
- **DatePicker** - Sélecteur de date
- **BottomBarWidget** - Barre de navigation
- **MediaPlayer** - Lecteur vidéo/audio

---

## 🎨 Système de Thèmes

### Enregistrement dans l'app

```dart
// Dans app/lib/config/theme.dart
appTheme.addTheme(UiThemeKeys.buttonPrimary, KosmosButtonThemeData(
  backgroundColor: Colors.blue,
  textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  borderRadius: BorderRadius.circular(8),
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
));

appTheme.addTheme(UiThemeKeys.formField, FormFieldThemeData(
  fieldNameStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  inputDecoration: kDefaultInputDecoration.copyWith(fillColor: Colors.grey[100]),
));
```

### Fallbacks par défaut

Chaque composant a un thème par défaut (`kDefault*`) utilisé si aucun thème n'est enregistré :
- `kDefaultButtonThemeData`
- `kDefaultFormFieldThemeData`
- `kDefaultInputDecoration`
- `kDefaultCelluleThemeData`

---

## ✅ Conventions Obligatoires

### Zéro inline keys

```dart
// ❌ INTERDIT
themeName: "button_primary"

// ✅ OBLIGATOIRE
themeName: UiThemeKeys.buttonPrimary
```

### Toujours un fallback

```dart
final theme = loadThemeData<KosmosButtonThemeData>(
  widget.theme,
  widget.themeName ?? UiThemeKeys.buttonPrimary,
  () => kDefaultButtonThemeData,  // Fallback obligatoire
  isDark: isDark,
);
```

---

## 🧪 Tests & Commandes

```bash
cd ui
dart format .
dart analyze
flutter test
```

---

## ✔️ Definition of Done (DoD)

- [ ] Utiliser `UiThemeKeys.*` pour les clés thème
- [ ] Fallback theme défini (`kDefault*`)
- [ ] `dart format .` OK
- [ ] `dart analyze` OK

---

## 📚 Exports Principaux

```dart
// Buttons
export 'button/button.dart';
export 'button/theme/button_theme.dart';

// Form Fields
export 'field/form_item.dart';
export 'field/field/classic_field.dart';
export 'field/field/phone_number_field.dart';
export 'field/field/date/date_field.dart';
export 'field/field/dropdown_field.dart';
export 'field/theme/form_field_theme.dart';

// Settings
export 'Settings/cellule.dart';
export 'Settings/theme/cellule_theme.dart';

// Other components
export 'switch/switch.dart';
export 'card/card.dart';
export 'loader/loader_classique.dart';
export 'picker/single_date.dart';
export 'slider/slider.dart';
export 'bottom_bar/bottom_bar.dart';
export 'player/media_player.dart';
```
