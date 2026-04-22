# Flutter UI Collection

A modular, design-system-agnostic Flutter UI component library. Ships with **4 built-in design presets** and **10 fully themed components** -- independent of Material Design.

---

**[English](#english)** | **[Deutsch](#deutsch)**

---

## English

### Overview

`flutter_ui_collection` gives you production-ready UI components that adapt their look and feel through a lightweight theme system. No Material dependency. Swap between Neon, Glass, Minimal, or Cyberpunk with a single line -- or create your own theme.

### Features

- **4 Design Presets** (each with dark + light variant)
  - **Neon** -- glowing accents, dark-first, vibrant
  - **Glass** -- frosted translucent surfaces, backdrop blur
  - **Minimal** -- clean, spacious, typography-focused
  - **Cyberpunk** -- angular, aggressive, monospace
- **10 Themed Components**
  - `UiButton` -- filled, outlined, ghost, glow variants
  - `UiCard` -- surface container with optional blur
  - `UiTextField` -- styled text input with focus glow
  - `UiBadge` -- status labels (primary, success, warning, error)
  - `UiToggle` -- switch with glow support
  - `UiChip` -- compact tags with select/delete
  - `UiAvatar` -- image, initials, or icon
  - `UiProgressBar` -- gradient and glow support
  - `UiDivider` -- with optional centered label
  - `UiAppBar` -- custom top navigation bar
- **Custom Theme Support** -- build your own `UiThemeData`
- **Context Extension** -- `context.uiTheme` for quick access
- **Zero Material dependency** in component rendering

### Installation

```yaml
dependencies:
  flutter_ui_collection: ^0.1.0
```

### Quick Start

```dart
import 'package:flutter_ui_collection/flutter_ui_collection.dart';

// Wrap your app (or any subtree) with UiTheme
UiTheme(
  data: NeonTheme.dark,
  child: MyApp(),
)

// Use components anywhere in the subtree
UiButton(
  label: 'Submit',
  variant: UiButtonVariant.glow,
  onPressed: () {},
)
```

### Theme System

```dart
// Use a built-in preset
UiTheme(data: GlassTheme.dark, child: ...)

// Customize a preset
UiTheme(
  data: NeonTheme.dark.copyWith(
    colorScheme: NeonTheme.dark.colorScheme.copyWith(
      primary: Color(0xFFFF6600),
    ),
  ),
  child: ...,
)

// Build a fully custom theme
final myTheme = UiThemeData(
  name: 'My Theme',
  colorScheme: UiColorScheme(...),
  typography: UiTypography.fromFont(
    fontFamily: 'Roboto',
    color: Color(0xFFFFFFFF),
  ),
);
```

### Access Theme in Widgets

```dart
// Via static method
final theme = UiTheme.of(context);

// Via context extension
final colors = context.uiTheme.colorScheme;
final typo = context.uiTheme.typography;
```

### Components Reference

| Component | Key Props |
|---|---|
| `UiButton` | `label`, `variant`, `size`, `icon`, `expand`, `loading` |
| `UiCard` | `child`, `blur`, `onTap`, `padding`, `color` |
| `UiTextField` | `label`, `placeholder`, `prefixIcon`, `suffixIcon`, `obscureText` |
| `UiBadge` | `label`, `type`, `outlined` |
| `UiToggle` | `value`, `onChanged`, `size` |
| `UiChip` | `label`, `selected`, `onTap`, `onDelete`, `icon` |
| `UiAvatar` | `imageProvider`, `initials`, `icon`, `size` |
| `UiProgressBar` | `value`, `height`, `showLabel`, `color` |
| `UiDivider` | `label`, `thickness`, `indent` |
| `UiAppBar` | `title`, `leading`, `actions`, `height` |

### Available Themes

| Theme | Dark | Light | Style |
|---|---|---|---|
| `NeonTheme` | `.dark` | `.light` | Glowing, vibrant, bold |
| `GlassTheme` | `.dark` | `.light` | Frosted, translucent, elegant |
| `MinimalTheme` | `.dark` | `.light` | Clean, spacious, flat |
| `CyberpunkTheme` | `.dark` | `.light` | Angular, aggressive, mono |

---

## Deutsch

### Uebersicht

`flutter_ui_collection` liefert produktionsfertige UI-Komponenten, die ihr Aussehen ueber ein leichtgewichtiges Theme-System anpassen. Keine Material-Abhaengigkeit. Wechsle zwischen Neon, Glass, Minimal oder Cyberpunk mit einer einzigen Zeile -- oder erstelle dein eigenes Theme.

### Features

- **4 Design-Presets** (jeweils mit Dark + Light Variante)
  - **Neon** -- leuchtende Akzente, Dark-first, lebendig
  - **Glass** -- gefrostete Oberflaechen, Backdrop-Blur
  - **Minimal** -- clean, grosszuegig, Typografie-fokussiert
  - **Cyberpunk** -- kantig, aggressiv, Monospace
- **10 Theme-faehige Komponenten**
  - `UiButton` -- Filled, Outlined, Ghost, Glow Varianten
  - `UiCard` -- Oberflaechencontainer mit optionalem Blur
  - `UiTextField` -- Texteingabe mit Fokus-Glow
  - `UiBadge` -- Statuslabel (Primary, Success, Warning, Error)
  - `UiToggle` -- Schalter mit Glow-Unterstuetzung
  - `UiChip` -- Kompakte Tags mit Select/Delete
  - `UiAvatar` -- Bild, Initialen oder Icon
  - `UiProgressBar` -- Gradient- und Glow-Unterstuetzung
  - `UiDivider` -- mit optionalem zentriertem Label
  - `UiAppBar` -- Eigene Top-Navigationsleiste
- **Eigene Themes** -- erstelle dein eigenes `UiThemeData`
- **Context Extension** -- `context.uiTheme` fuer schnellen Zugriff

### Installation

```yaml
dependencies:
  flutter_ui_collection: ^0.1.0
```

### Schnellstart

```dart
import 'package:flutter_ui_collection/flutter_ui_collection.dart';

// App (oder Subtree) mit UiTheme umschliessen
UiTheme(
  data: NeonTheme.dark,
  child: MeineApp(),
)

// Komponenten ueberall im Subtree verwenden
UiButton(
  label: 'Absenden',
  variant: UiButtonVariant.glow,
  onPressed: () {},
)
```

### Theme anpassen

```dart
// Preset anpassen
UiTheme(
  data: NeonTheme.dark.copyWith(
    colorScheme: NeonTheme.dark.colorScheme.copyWith(
      primary: Color(0xFFFF6600),
    ),
  ),
  child: ...,
)

// Komplett eigenes Theme
final meinTheme = UiThemeData(
  name: 'Mein Theme',
  colorScheme: UiColorScheme(...),
  typography: UiTypography.fromFont(
    fontFamily: 'Roboto',
    color: Color(0xFFFFFFFF),
  ),
);
```

---

## Architecture (LLM-readable)

```
flutter_ui_collection/
  lib/
    flutter_ui_collection.dart          # Barrel export (single import)
    src/
      theme/
        ui_theme.dart                   # InheritedWidget provider
        ui_theme_data.dart              # Immutable theme config
        ui_color_scheme.dart            # Color palette (18 colors + glow/gradient)
        ui_typography.dart              # 15-level text style hierarchy
        ui_spacing.dart                 # Spacing + border radius tokens
      designs/
        neon/neon_theme.dart            # NeonTheme.dark / .light
        glass/glass_theme.dart          # GlassTheme.dark / .light
        minimal/minimal_theme.dart      # MinimalTheme.dark / .light
        cyberpunk/cyberpunk_theme.dart  # CyberpunkTheme.dark / .light
      components/
        button/ui_button.dart           # UiButton (4 variants, 3 sizes)
        card/ui_card.dart               # UiCard (blur support)
        text_field/ui_text_field.dart   # UiTextField (focus glow)
        badge/ui_badge.dart             # UiBadge (6 types)
        toggle/ui_toggle.dart           # UiToggle (glow)
        chip/ui_chip.dart               # UiChip (select/delete)
        avatar/ui_avatar.dart           # UiAvatar (3 sizes)
        progress_bar/ui_progress_bar.dart # UiProgressBar (gradient)
        divider/ui_divider.dart         # UiDivider (label)
        app_bar/ui_app_bar.dart         # UiAppBar
      extensions/
        ui_extensions.dart              # BuildContext.uiTheme
  test/
    flutter_ui_collection_test.dart     # 34 widget + unit tests
  example/
    example.dart                        # Full showcase app
```

### Design Tokens Flow

```
UiThemeData
  +-- UiColorScheme    (primary, secondary, surface, glow, gradient...)
  +-- UiTypography     (display, headline, title, body, label)
  +-- UiSpacing        (xs/sm/md/lg/xl, borderRadius variants)
  +-- flags            (useGlow, useGradients, useShadows)
  +-- animation        (duration, curve)
```

Components read all visual properties from `UiTheme.of(context)` -- no hardcoded colors or sizes.

---

## License

MIT

## Contributing

Issues and pull requests are welcome.
