## 3.1.0

### Chat Module Upgrade (8 new widgets)

WhatsApp-level chat experience with voice messages, reactions, media, and group management.

- `UiChatHeader` -- WhatsApp-style header with avatar, online status, call/video/more actions
- `UiChatMediaMessage` -- image/video message bubble with caption and delivery status
- `UiChatSearch` -- in-chat search bar with result navigation (up/down arrows)
- `UiChatEmpty` -- empty state widget with icon, title, subtitle
- `UiVoiceMessage` -- voice message bubble with play/pause, waveform visualization, progress
- `UiMessageReactions` -- emoji reaction pills below messages with count
- `UiMessageMenu` -- long-press context menu (reply, forward, copy, delete, pin)
- `UiGroupInfo` -- group info view with avatar, description, members list

### E-Commerce Module Upgrade (7 new widgets)

Full shopping experience with cart management, checkout flow, and shop layout.

- `UiCartController` -- reactive cart state management (add/remove, subtotal, total)
- `UiCartScreen` -- full cart screen with auto-rebuild on controller changes
- `UiCheckoutFlow` -- 3-step checkout (Address -> Payment -> Review) with order totals
- `UiProductDetail` -- full product detail page with image, badges, price, rating, description
- `UiProductBadge` -- pill-shaped badge (Sale, New, Bestseller, OutOfStock)
- `UiShopLayout` -- complete shop page with search, category chips, product grid, cart badge
- `UiWishlistButton` -- animated heart toggle with scale-bounce animation

### Dashboard Module Upgrade (6 new widgets)

Advanced data visualization with gauges, heatmaps, and interactive tables.

- `UiDataTable` -- sortable data table with themed styling
- `UiGauge` -- semi-circular gauge chart via CustomPaint
- `UiHeatmap` -- GitHub-style contribution heatmap with color interpolation
- `UiMetricCard` -- rich metric card with value, change indicator, optional chart
- `UiProgressList` -- labeled progress bars with optional trailing text
- `UiSparkline` -- tiny inline sparkline chart via CustomPaint

### Stats
- **21 new widgets** across 3 modules
- **~210 Dart files**, ~40K LOC

---

## 3.0.1

### Full Showcase Example App
- Complete Flutter example project with 3 tabs (Components, Effects, Modules)
- Live theme switcher through all 10 presets
- Interactive chat demo, chart demo, settings demo
- Runnable via `cd example && flutter run`

## 2.0.0

### 5 New Modules (Major Release)

**Auth Module** (8 files)
- `UiLoginScreen` -- email/password, social login, forgot password link
- `UiRegisterScreen` -- name/email/password/confirm, terms checkbox
- `UiForgotPasswordScreen` -- email reset with success banner
- `UiOtpScreen` -- PIN input with resend countdown timer
- `UiSocialButton` -- provider-specific social login buttons
- `UiAuthController` -- state management with async callbacks
- `UiAuthModels` -- UiAuthState, UiAuthResult, UiSocialProvider

**E-Commerce Module** (9 files)
- `UiProductCard` -- image, price, rating, sale badge, hover scale
- `UiProductGrid` -- responsive grid with skeleton loading
- `UiPriceDisplay` -- current/original price, discount badge, currency
- `UiCartItemTile` -- thumbnail, quantity +/-, remove, line total
- `UiCartSummary` -- subtotal/shipping/tax/total, checkout button
- `UiCartBadge` -- animated count badge on cart icon
- `UiOrderStatusTracker` -- horizontal stepper for order stages
- Models: UiProduct, UiCartItem, UiOrderStatus

**Dashboard Module** (8 files)
- `UiStatCard` -- KPI card with trend + mini sparkline
- `UiBarChart` -- animated vertical bars via CustomPaint
- `UiLineChart` -- smooth bezier curves, gradient fill, multiple series
- `UiPieChart` -- pie/donut with animated segments + legend
- `UiActivityFeed` -- event feed with type-colored dots
- `UiKpiRow` -- responsive stat cards row
- `UiDashboardLayout` -- responsive grid with colSpan/rowSpan

**Social Module** (8 files)
- `UiPostCard` -- avatar, content, image grid (1-4), action bar
- `UiCommentThread` -- nested replies with connector lines
- `UiSocialActionBar` -- animated like, comment, share, bookmark
- `UiStoryRow` -- horizontal story circles with gradient rings
- `UiUserProfileHeader` -- cover, avatar, stats, follow/message
- `UiMentionText` -- @mention + #hashtag parsing with tap callbacks
- Models: UiSocialUser, UiPost, UiComment, UiStory

**Settings Module** (10 files)
- `UiSettingsSection` -- grouped card with title
- `UiSettingsTile` -- base tile with icon, title, subtitle, trailing
- `UiSettingsToggle` -- toggle switch row
- `UiSettingsNavigation` -- chevron row with optional badge
- `UiSettingsSlider` -- slider with value label
- `UiSettingsSelect` -- inline expand/collapse selection
- `UiThemeSelector` -- grid of theme preview cards with color dots
- `UiAboutScreen` -- app info with logo, version, links
- `UiSettingsScreen` -- complete settings page template

### Stats
- **171 Dart files** (~30,000 LOC)
- **89 core components + 6 modules** (55 module files)
- **189 tests**
- **8 design presets** (16 themes)
- **7 visual effects**, **2 transition systems**

---

## 1.3.0

### Chat Module (NEW)

A complete, self-contained chat UI system with state management.

**Models**
- `UiChatUser` -- user with id, name, avatar, online status
- `UiChatMessage` -- message with type (text/image/system/voice), status, reply-to, metadata
- `UiChatRoom` -- room with participants, last message, unread count

**Controller**
- `UiChatController` -- ChangeNotifier managing messages, typing, loading, reply state, scroll

**Widgets**
- `UiChatRoomView` -- complete chat room (app bar + message list + typing + reply + input)
- `UiChatMessageWidget` -- message bubble with directional rounding, sender name, reply preview, image support
- `UiChatInputBar` -- input with send/attach buttons, reply preview, placeholder
- `UiChatList` -- conversation overview list
- `UiChatListTile` -- conversation row with avatar, preview, timestamp, unread badge
- `UiTypingIndicator` -- animated bouncing dots with "is typing" text
- `UiMessageStatusIcon` -- custom-painted sent/delivered/read/failed icons
- `UiChatDateSeparator` -- "Today"/"Yesterday"/date divider
- `UiChatReplyPreview` -- quoted message with accent border and dismiss

**Usage:**
```dart
UiChatRoomView(
  controller: chatController,
  currentUserId: 'me',
  roomName: 'General',
  onSend: (text) => sendToBackend(text),
)
```

### Stats
- **89 components + 12 chat module files** = 128 Dart files
- **189 tests** (up from 174)
- **~20,700 LOC**

---

## 1.2.0

### New Components (15) -- Tier 1/2/3

**Async & Data Patterns (Tier 1)**
- `UiAsyncBuilder<T>` -- themed FutureBuilder/StreamBuilder with auto loading spinner, error state + retry button
- `UiPullToRefresh` -- pull-to-refresh wrapper with overscroll detection and themed indicator
- `UiInfiniteList<T>` -- paginated lazy-loading list with auto load-more, empty state, separators
- `UiConfirmDialog` -- one-liner `await UiConfirmDialog.show(context, ...)` returning `bool`
- `UiActionSheet` -- iOS-style bottom action list with cancel button, returns selected index

**Input & Interaction (Tier 2)**
- `UiTagInput` -- chip-based tag input with inline text field, submit on Enter/comma
- `UiNumberInput` -- +/- stepper with min/max limits and glow
- `UiExpandableText` -- "Read more..." truncation with animated expand/collapse
- `UiResponsiveGrid` -- CSS-grid-like responsive column system with mobile/tablet/desktop spans
- `UiOnboarding` -- intro/walkthrough pages with dots, Skip/Next/Done navigation

**Display & Navigation (Tier 3)**
- `UiColorPicker` -- color grid with check indicator and glow on selected
- `UiSegmentedControl` -- iOS-style segmented control with animated sliding highlight
- `UiBreadcrumb` -- breadcrumb navigation with separator and clickable items
- `UiAvatarGroup` -- overlapping avatar stack with "+N" overflow badge
- `UiStatusPage` -- full-page status display (success/error/notFound/maintenance)

### Stats
- **64 components** (up from 49)
- **149 tests** (up from 133)
- **91 Dart files**, ~13,000 LOC

---

## 1.1.0

### New Components (16)

**Navigation & Layout**
- `UiBottomNav` -- bottom navigation bar with icon badges and glow
- `UiStepper` -- horizontal step indicator with completed/active/error states

**Input & Interaction**
- `UiRating` -- star rating with half-star support, custom painting
- `UiPinInput` -- PIN/OTP code input with themed cells and auto-advance
- `UiSearchBar` -- pill-shaped search input with clear button (moved to v1.0 but listed for completeness)

**Data Display**
- `UiStat` -- KPI/statistic display with trend indicators (up/down/neutral)
- `UiTimeline` -- vertical timeline with dot indicators and content
- `UiNotificationDot` -- badge dot/count wrapper for any widget (caps at 99+)
- `UiCodeBlock` -- monospace code display with line numbers and copy button
- `UiCalendar` -- monthly calendar with date selection and marked dates

**Feedback & Overlays**
- `UiAlert` -- inline alert banner (info/success/warning/error) with dismiss
- `UiPopoverMenu` -- contextual popup menu with items, dividers, destructive actions

**Media**
- `UiCarousel` -- horizontal page slider with dot indicators and auto-play
- `UiImageViewer` -- image with tap-to-fullscreen, pinch-to-zoom, double-tap reset
- `UiGallery` -- image grid with swipeable fullscreen viewer and counter

**Forms**
- `UiMultiStepForm` -- wizard form with step navigation, per-step validation, Back/Next/Submit

**Interaction**
- `UiSwipeAction` -- swipeable list item revealing leading/trailing action buttons
- `UiAccordion` -- expandable/collapsible sections (moved to v1.0 but listed for completeness)

### Bug Fixes
- Fixed `UiTooltip` timer memory leak (replaced Future.delayed with cancellable Timer)
- Consistent unused import cleanup across all components

### Stats
- **49 components** (up from 33)
- **133 tests** (up from 111)
- **76 Dart files**, ~10,000 LOC

---

## 1.0.0

First stable release. A complete, Material-free Flutter UI framework.

### Highlights

- **33 themed components** -- from buttons to forms to data tables
- **8 design presets** -- Neon, Glass, Minimal, Cyberpunk, Retro, Aurora, Terminal, Pastel
- **7 visual effects** -- Gradient text, shimmer, glow, pulse, typewriter, count-up, stagger
- **Full app scaffolding** -- UiApp + UiScaffold replace MaterialApp + Scaffold
- **Form validation** -- UiForm + UiFormField with built-in validators
- **Hero transitions** -- 4 flight styles including glow trails
- **Page transitions** -- 6 built-in styles (fade, slide, scale, etc.)
- **Responsive system** -- breakpoints, responsive builder, max-width body
- **111 tests**, 0 analyzer issues

### Theme System
- `UiTheme` -- InheritedWidget provider
- `UiThemeData` -- immutable config with color scheme, typography, spacing, animation, and feature flags (useGlow, useGradients, useShadows)
- `UiColorScheme` -- 18 semantic colors + optional glow + gradient
- `UiTypography` -- 15-level text style hierarchy with `fromFont()` factory
- `UiSpacing` -- spacing tokens + border radius presets
- `AnimatedUiTheme` -- smooth interpolated theme transitions
- `UiThemeMode` -- auto dark/light switch based on platform brightness
- `context.uiTheme` extension for quick access

### Design Presets (8 presets, each dark + light = 16 themes)
- **Neon** -- glowing cyan/magenta accents, dark-first, vibrant
- **Glass** -- frosted translucent surfaces, backdrop blur, elegant
- **Minimal** -- Apple-inspired, clean, flat, typography-focused
- **Cyberpunk** -- sharp corners, yellow/red neon, monospace, aggressive
- **Retro** -- 8-bit pixel aesthetic, zero border radius, blocky
- **Aurora** -- gradient-heavy, flowing, ethereal, soft roundings
- **Terminal** -- monochrome green/amber on black, zero animation, CLI-raw
- **Pastel** -- gentle muted tones, large radii, no borders, warm

### Components (33)

**App Shell**
- `UiApp` -- root widget replacing MaterialApp (Navigator, Overlay, routing, theme)
- `UiScaffold` -- AppBar + Body + Sidebar + BottomNav + FAB with responsive sidebar auto-hide
- `UiResponsiveBody` -- centered max-width content wrapper

**Input**
- `UiButton` -- 4 variants (filled, outlined, ghost, glow), 3 sizes, loading state, icon support
- `UiTextField` -- placeholder, error/helper text, character counter, prefix/suffix, selection, copy/paste, keyboard brightness auto-detection
- `UiCheckbox` -- with optional label, tristate support, custom check/indeterminate painting
- `UiRadio<T>` -- generic typed radio button with label
- `UiToggle` -- switch with glow support
- `UiSlider` -- drag + tap, label, live value display, glow thumb
- `UiDropdown<T>` -- generic overlay selector with placeholder
- `UiSearchBar` -- pill-shaped search input with clear button and search icon

**Forms**
- `UiForm` -- manages field registration, `validate()`, `submit()`, `reset()`, `values` map
- `UiFormField` -- form-aware text field with validator list, auto-revalidation
- `UiValidators` -- required, email, minLength, maxLength, pattern, matches, numeric

**Data Display**
- `UiCard` -- themed surface with optional backdrop blur (glassmorphism)
- `UiBadge` -- 6 semantic types, 3 sizes, outlined variant, optional icon
- `UiChip` -- select/delete, hover state, disabled support, glow
- `UiAvatar` -- image/initials/icon, 3 sizes, status indicator (online/offline/busy/away)
- `UiTable` -- columns with flex/fixed width, striped rows, row tap, header toggle
- `UiListTile` -- leading/title/subtitle/trailing, hover, selected state with accent border, dense mode
- `UiProgressBar` -- animated value transitions, gradient fill, glow, label
- `UiDivider` -- with optional centered label

**Navigation**
- `UiAppBar` -- title + leading + actions, themed border/shadow
- `UiTabBar` -- segmented tabs with animated indicator and glow
- `UiSidebar` -- vertical nav with icons, badges, collapsed mode
- `UiDrawer` -- slide-in overlay panel (left/right)
- `UiAccordion` -- expandable sections, single/multi-expand mode

**Overlays**
- `UiDialog` -- modal with title/content/actions, animated scale+fade entrance
- `UiBottomSheet` -- slide-up modal with handle and title
- `UiToast` -- auto-dismissing notification (4 severity levels, top/bottom position)
- `UiSnackbar` -- bottom notification with action button
- `UiTooltip` -- hover/long-press popup (4 positions), proper timer cleanup

**Feedback**
- `UiSkeleton` -- shimmer loading placeholder (rectangle/circle/rounded), configurable animation/colors
- `UiLoadingOverlay` -- full-screen spinner with themed glow, optional message
- `UiEmptyState` -- icon + title + description + action for empty data states

### Transitions
- `UiHero` -- shared-element transitions with 4 flight styles: standard, glow (neon trail), fade (cross-fade), scale
- `UiPageRoute` -- 6 page transition styles: fade, slideRight, slideUp, scale, slideFade, none
- `UiPageRoute.push()` / `.pushReplacement()` convenience methods

### Effects
- `UiGradientText` -- text with gradient fill (auto-uses theme gradient)
- `UiShimmerText` -- sweeping shine animation on text
- `UiGlowContainer` -- animated pulsing glow border around any widget
- `UiPulse` -- scale + glow pulse animation (e.g. for LIVE badges)
- `UiTypewriter` -- character-by-character text reveal with blinking cursor
- `UiCountUp` -- animated number counter with prefix/suffix/separator formatting
- `UiStagger` -- cascading entrance animation for lists (4 directions)

### Responsive
- `UiResponsive` -- builder widget with mobile/tablet/desktop/wide breakpoints
- `UiScreenInfo` -- value selector based on screen size
- `UiBreakpoints` -- customizable breakpoint thresholds

### Icons
- `UiIcon` -- themed icon with automatic glow effect
- `UiIcons` -- 45+ built-in Material icons (no extra package needed)

### Bug Fixes (since 0.1.0)
- Fixed TextField controller memory leak (created new controller every build)
- Fixed keyboard brightness hardcoded to dark (now auto-detects from theme)
- Fixed Avatar initials substring clamp logic
- Fixed Dropdown dispose crash (setState on defunct element)
- Fixed Tooltip timer leak (Future.delayed replaced with cancellable Timer)
- Fixed Hero flight shuttle force-unwrap safety
- Button disabled cursor changed from basic to forbidden

---

## 0.3.0

* **UiApp** -- Root widget replacing MaterialApp
* **UiScaffold** -- Layout system with responsive sidebar
* **UiForm + UiFormField** -- Form validation system
* **UiListTile** -- List item with hover + selected states
* **UiTextField rewrite** -- Placeholder, selection, copy/paste, counter
* Bug fixes and component improvements
* 84 tests

## 0.2.0

* 11 new components: Dialog, BottomSheet, Toast, Snackbar, TabBar, Sidebar, Drawer, Dropdown, Tooltip, Skeleton, Table
* 4 new design presets: Retro, Aurora, Terminal, Pastel
* AnimatedUiTheme, UiThemeMode, UiResponsive, UiIcon
* 60 tests

## 0.1.0

* Initial release
* Theme system, 4 design presets, 10 components, 34 tests
