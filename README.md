# Flutter UI Collection

A complete Flutter UI framework -- **89 core components**, **6 app modules**, **8 design presets**, **7 visual effects**, and **~30K LOC**. Fully independent of Material Design.

**One import. One theme. Done.**

```dart
import 'package:flutter_ui_collection/flutter_ui_collection.dart';
```

---

**[English](#english)** | **[Deutsch](#deutsch)**

---

## English

### Quick Start

```dart
void main() {
  runApp(UiApp(
    theme: NeonTheme.dark,
    darkTheme: NeonTheme.dark,
    home: UiScaffold(
      appBar: UiAppBar(title: Text('My App')),
      body: Center(child: UiButton(label: 'Hello', onPressed: () {})),
    ),
  ));
}
```

### Installation

```yaml
dependencies:
  flutter_ui_collection: ^2.0.0
```

### What's Inside

#### 89 Core Components

| Category | Components |
|---|---|
| **App Shell** | `UiApp`, `UiScaffold`, `UiResponsiveBody` |
| **Input** | `UiButton`, `UiTextField`, `UiCheckbox`, `UiRadio`, `UiToggle`, `UiSlider`, `UiDropdown`, `UiSearchBar`, `UiTagInput`, `UiNumberInput`, `UiPinInput`, `UiColorPicker`, `UiIconButton` |
| **Forms** | `UiForm`, `UiFormField`, `UiValidators`, `UiMultiStepForm` |
| **Data** | `UiCard`, `UiBadge`, `UiChip`, `UiAvatar`, `UiAvatarGroup`, `UiTable`, `UiListTile`, `UiProgressBar`, `UiProgressCircle`, `UiStat`, `UiCodeBlock`, `UiExpandableText`, `UiDescriptionList`, `UiKbd` |
| **Navigation** | `UiAppBar`, `UiTabBar`, `UiBottomNav`, `UiSidebar`, `UiDrawer`, `UiAccordion`, `UiBreadcrumb`, `UiStepper`, `UiSegmentedControl`, `UiPagination`, `UiTreeView` |
| **Overlays** | `UiDialog`, `UiConfirmDialog`, `UiBottomSheet`, `UiActionSheet`, `UiToast`, `UiSnackbar`, `UiTooltip`, `UiPopoverMenu`, `UiContextMenu`, `UiCommandPalette`, `UiHoverCard` |
| **Media** | `UiCarousel`, `UiImageViewer`, `UiGallery` |
| **Feedback** | `UiSkeleton`, `UiLoadingOverlay`, `UiEmptyState`, `UiStatusPage`, `UiNotificationDot` |
| **Async** | `UiAsyncBuilder`, `UiPullToRefresh`, `UiInfiniteList` |
| **Layout** | `UiDivider`, `UiResponsiveGrid`, `UiMasonryGrid`, `UiResizablePanel`, `UiCollapsible`, `UiWatermark` |
| **Interaction** | `UiSwipeAction`, `UiReorderableList`, `UiOnboarding`, `UiRating`, `UiTimeline`, `UiButtonGroup`, `UiFloatingActionButton`, `UiSpeedDial` |
| **Date/Time** | `UiCalendar`, `UiDatePicker`, `UiTimePicker` |
| **Text** | `UiAutoComplete`, `UiClipboardButton`, `UiMarquee`, `UiScrollIndicator`, `UiSignaturePad`, `UiChatBubble` |

#### 6 App Modules

Pre-built, self-contained modules for common app patterns:

| Module | Files | What it provides |
|---|---|---|
| **Auth** | 8 | Login, Register, Forgot Password, OTP, Social Login, Controller |
| **Chat** | 12 | Chat Room, Messages, Input Bar, Chat List, Typing Indicator, Status Icons, Date Separators, Reply Preview, Controller |
| **Dashboard** | 8 | Bar/Line/Pie Charts (pure CustomPaint), Stat Cards, KPI Row, Activity Feed, Dashboard Layout |
| **E-Commerce** | 9 | Product Cards/Grid, Price Display, Cart Item/Summary/Badge, Order Status Tracker |
| **Social** | 8 | Post Cards, Comment Threads, Action Bar, Story Row, Profile Header, @Mention/#Hashtag Parser |
| **Settings** | 10 | Sections, Toggle/Navigation/Slider/Select Tiles, Theme Selector, About Screen |

#### 8 Design Presets (each dark + light = 16 themes)

| Theme | Style |
|---|---|
| `NeonTheme` | Glowing cyan/magenta, vibrant, dark-first |
| `GlassTheme` | Frosted translucent surfaces, backdrop blur |
| `MinimalTheme` | Apple-inspired, clean, flat |
| `CyberpunkTheme` | Sharp corners, yellow/red neon, monospace |
| `RetroTheme` | 8-bit pixel, zero border radius, blocky |
| `AuroraTheme` | Gradient-heavy, flowing, ethereal |
| `TerminalTheme` | Green/amber on black, zero animation, CLI-raw |
| `PastelTheme` | Gentle muted tones, large radii, warm |

#### 7 Visual Effects

`UiGradientText`, `UiShimmerText`, `UiGlowContainer`, `UiPulse`, `UiTypewriter`, `UiCountUp`, `UiStagger`

#### Transitions

- `UiHero` -- 4 flight styles: standard, glow, fade, scale
- `UiPageRoute` -- 6 transition styles: fade, slideRight, slideUp, scale, slideFade, none

### Module Examples

#### Auth

```dart
final authCtrl = UiAuthController(
  onLogin: (args) async => await api.login(args.email, args.password),
);

UiLoginScreen(
  controller: authCtrl,
  title: 'Welcome Back',
  socialProviders: [UiSocialProvider.google, UiSocialProvider.apple],
  onRegister: () => navigateTo(RegisterPage()),
  onForgotPassword: () => navigateTo(ForgotPasswordPage()),
)
```

#### Chat

```dart
final chatCtrl = UiChatController(
  currentUser: UiChatUser(id: 'me', name: 'Tobias'),
  messages: existingMessages,
);

UiChatRoomView(
  controller: chatCtrl,
  currentUserId: 'me',
  roomName: 'Team Chat',
  onSend: (text) => api.sendMessage(text),
  onLoadMore: () => api.loadOlderMessages(),
)
```

#### Dashboard

```dart
UiDashboardLayout(tiles: [
  UiDashboardTile(colSpan: 2, child: UiLineChart(data: [
    UiLineChartData(points: [10, 25, 18, 30, 42], label: 'Revenue'),
  ])),
  UiDashboardTile(child: UiPieChart(data: [
    UiPieChartData(value: 40, label: 'Mobile'),
    UiPieChartData(value: 35, label: 'Desktop'),
    UiPieChartData(value: 25, label: 'Tablet'),
  ])),
  UiDashboardTile(child: UiStatCard(
    label: 'Users', value: '12,345', trend: UiStatTrend.up, trendValue: '+12%',
  )),
])
```

#### E-Commerce

```dart
UiProductGrid(products: products, onAddToCart: (p) => cart.add(p))

UiCartSummary(
  subtotal: 99.99, shipping: 5.99, tax: 8.50, total: 114.48,
  currency: '\$', onCheckout: () => checkout(),
)
```

#### Social

```dart
UiPostCard(
  post: post,
  onLike: () => api.toggleLike(post.id),
  onComment: () => openComments(post),
)

UiStoryRow(stories: stories, onStoryTap: (s) => viewStory(s))
```

#### Settings

```dart
UiSettingsScreen(sections: [
  UiSettingsSection(title: 'General', children: [
    UiSettingsToggle(title: 'Dark Mode', value: isDark, onChanged: toggleDark),
    UiSettingsNavigation(title: 'Language', subtitle: 'English', onTap: selectLanguage),
  ]),
  UiSettingsSection(title: 'Theme', children: [
    UiThemeSelector(themes: allThemes, selectedTheme: current, onChanged: setTheme),
  ]),
])
```

### Theme System

```dart
// Built-in preset
UiApp(theme: NeonTheme.dark, home: ...)

// Auto dark/light switch
UiApp(theme: NeonTheme.light, darkTheme: NeonTheme.dark, home: ...)

// Animated theme switching
AnimatedUiTheme(data: currentTheme, child: ...)

// Customize a preset
NeonTheme.dark.copyWith(
  colorScheme: NeonTheme.dark.colorScheme.copyWith(primary: Color(0xFFFF6600)),
)

// Access in widgets
final theme = context.uiTheme;
final colors = theme.colorScheme;
```

### Responsive Layouts

```dart
UiResponsive(
  mobile: (ctx) => MobileLayout(),
  tablet: (ctx) => TabletLayout(),
  desktop: (ctx) => DesktopLayout(),
)
```

---

## Deutsch

### Schnellstart

```dart
void main() {
  runApp(UiApp(
    theme: NeonTheme.dark,
    home: UiScaffold(
      appBar: UiAppBar(title: Text('Meine App')),
      body: Center(child: UiButton(label: 'Hallo', onPressed: () {})),
    ),
  ));
}
```

### Was drin ist

- **89 Core-Komponenten** -- Buttons, Inputs, Formulare, Tabellen, Dialoge, Navigation, Charts, Kalender, Media, Loading States
- **6 App-Module** -- Auth (Login/Register/OTP), Chat (Room/Messages/Input), Dashboard (Charts/Stats), E-Commerce (Products/Cart), Social (Posts/Comments/Stories), Settings (Sections/Theme Picker)
- **8 Design-Presets** -- Neon, Glass, Minimal, Cyberpunk, Retro, Aurora, Terminal, Pastel (je Dark + Light)
- **7 Visual Effects** -- Gradient-Text, Shimmer, Glow, Pulse, Typewriter, Counter, Stagger
- **Hero-Transitions** -- 4 Flight-Styles inkl. Neon-Glow-Trail
- **Page-Transitions** -- 6 Uebergangsstile
- **Formular-System** -- UiForm + UiFormField + UiMultiStepForm mit Validatoren
- **Dashboard-Charts** -- Bar, Line, Pie (reines CustomPaint, keine Dependencies)
- **Chat-System** -- Komplett mit Controller, Messages, Input, Typing, Status
- **App-Grundgeruest** -- UiApp + UiScaffold ersetzen MaterialApp + Scaffold
- **Responsive System** -- Breakpoints, Grid, Masonry, Max-Width Body
- **170+ Dart Files, ~30K LOC, 189 Tests**
- **Kein Material-Import noetig**

### Module nutzen

```dart
// Auth -- Kompletter Login in einer Zeile
UiLoginScreen(controller: authCtrl, onRegister: () => goToRegister())

// Chat -- Kompletter Chat-Raum
UiChatRoomView(controller: chatCtrl, onSend: (text) => sendMessage(text))

// Dashboard -- Charts ohne Dependencies
UiBarChart(data: [UiBarChartData(label: 'Jan', value: 100)])

// E-Commerce -- Produkt-Grid
UiProductGrid(products: products, onAddToCart: addToCart)

// Social -- Post-Feed
UiPostCard(post: post, onLike: () => toggleLike(post.id))

// Settings -- Theme-Auswahl
UiThemeSelector(themes: presets, selectedTheme: current, onChanged: setTheme)
```

---

## Architecture (LLM-readable)

```
flutter_ui_collection/ (171 files, ~30K LOC)
  lib/
    flutter_ui_collection.dart              # Single barrel export
    src/
      theme/                                # 6 files -- Theme system
      animation/                            # 1 file  -- AnimatedUiTheme
      responsive/                           # 1 file  -- UiResponsive + UiScreenInfo
      icons/                                # 1 file  -- UiIcon + 45+ UiIcons
      designs/                              # 8 dirs  -- Theme presets (neon/glass/minimal/cyberpunk/retro/aurora/terminal/pastel)
      transitions/                          # 2 files -- UiHero + UiPageRoute
      effects/                              # 7 files -- GradientText/ShimmerText/GlowContainer/Pulse/Typewriter/CountUp/Stagger
      extensions/                           # 1 file  -- context.uiTheme
      components/                           # 89 dirs -- All core UI components
        app/ scaffold/ app_bar/ button/ text_field/ checkbox/ radio/ toggle/
        slider/ dropdown/ search_bar/ tag_input/ number_input/ pin_input/
        color_picker/ icon_button/ form/ multi_step_form/ card/ badge/ chip/
        avatar/ avatar_group/ table/ list_tile/ progress_bar/ progress_circle/
        stat/ code_block/ expandable_text/ description_list/ kbd/ tab_bar/
        bottom_nav/ sidebar/ drawer/ accordion/ breadcrumb/ stepper/
        segmented_control/ pagination/ tree_view/ dialog/ confirm_dialog/
        bottom_sheet/ action_sheet/ toast/ snackbar/ tooltip/ popover_menu/
        context_menu/ command_palette/ hover_card/ carousel/ image_viewer/
        gallery/ skeleton/ loading_overlay/ empty_state/ status_page/
        notification_dot/ async_builder/ pull_to_refresh/ infinite_list/
        divider/ responsive_grid/ masonry_grid/ resizable_panel/ collapsible/
        watermark/ swipe_action/ reorderable_list/ onboarding/ rating/
        timeline/ button_group/ floating_action_button/ speed_dial/ calendar/
        date_picker/ time_picker/ auto_complete/ clipboard_button/ marquee/
        scroll_indicator/ signature_pad/ chat_bubble/
      auth/                                 # 8 files -- Auth module
      chat/                                 # 12 files -- Chat module
      dashboard/                            # 8 files -- Dashboard module
      ecommerce/                            # 9 files -- E-Commerce module
      social/                               # 8 files -- Social module
      settings/                             # 10 files -- Settings module
  test/
    flutter_ui_collection_test.dart         # 189 tests
  example/
    example.dart                            # Showcase app
```

### Design Tokens Flow

```
UiThemeData
  +-- UiColorScheme    (primary, secondary, surface, error, success, warning, glow, gradient...)
  +-- UiTypography     (display, headline, title, body, label -- 15 levels)
  +-- UiSpacing        (xs/sm/md/lg/xl/xxl + 5 border radius presets)
  +-- flags            (useGlow, useGradients, useShadows)
  +-- animation        (duration, curve)
  +-- borderWidth, elevation
```

All components resolve visual properties from `UiTheme.of(context)`. No hardcoded colors or sizes.

---

## License

MIT

## Contributing

Issues and pull requests are welcome.
