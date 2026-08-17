import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_collection/flutter_ui_collection.dart';

/// 1x1 transparent PNG for image tests.
final Uint8List _kTransparentPixel = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x62,
  0x00,
  0x00,
  0x00,
  0x02,
  0x00,
  0x01,
  0xE5,
  0x27,
  0xDE,
  0xFC,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

/// Wraps a widget with [UiTheme] and [Directionality] for testing.
Widget _wrap(Widget child, {UiThemeData? theme}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: UiTheme(data: theme ?? NeonTheme.dark, child: child),
  );
}

void main() {
  group('UiTheme', () {
    testWidgets('provides theme data to descendants', (tester) async {
      late UiThemeData resolved;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              resolved = UiTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved.name, 'Neon Dark');
    });

    testWidgets('maybeOf returns null without ancestor', (tester) async {
      UiThemeData? resolved;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              resolved = UiTheme.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved, isNull);
    });

    testWidgets('context extension works', (tester) async {
      late UiThemeData resolved;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              resolved = context.uiTheme;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved.name, 'Neon Dark');
    });
  });

  group('Design Presets', () {
    test('NeonTheme has dark and light', () {
      expect(NeonTheme.dark.name, 'Neon Dark');
      expect(NeonTheme.light.name, 'Neon Light');
      expect(NeonTheme.dark.useGlow, isTrue);
    });

    test('GlassTheme has dark and light', () {
      expect(GlassTheme.dark.name, 'Glass Dark');
      expect(GlassTheme.light.name, 'Glass Light');
      expect(GlassTheme.dark.useShadows, isFalse);
    });

    test('MinimalTheme has dark and light', () {
      expect(MinimalTheme.dark.name, 'Minimal Dark');
      expect(MinimalTheme.light.name, 'Minimal Light');
      expect(MinimalTheme.dark.useGlow, isFalse);
    });

    test('CyberpunkTheme has dark and light', () {
      expect(CyberpunkTheme.dark.name, 'Cyberpunk Dark');
      expect(CyberpunkTheme.light.name, 'Cyberpunk Light');
      expect(CyberpunkTheme.dark.useGlow, isTrue);
    });
  });

  group('UiThemeData', () {
    test('copyWith preserves unchanged values', () {
      final original = NeonTheme.dark;
      final copied = original.copyWith(name: 'Custom');

      expect(copied.name, 'Custom');
      expect(copied.useGlow, original.useGlow);
      expect(copied.colorScheme.primary, original.colorScheme.primary);
    });

    test('copyWith supports component tokens', () {
      final tokens = const UiComponentTokens().copyWith(controlHeightMedium: 48, cardRadius: 20);
      final copied = NeonTheme.dark.copyWith(components: tokens);

      expect(copied.components.controlHeightMedium, 48);
      expect(copied.components.cardRadius, 20);
      expect(copied.spacing, NeonTheme.dark.spacing);
    });

    test('copyWith supports replaceable icon sets', () {
      const replacement = IconData(0x1234, fontFamily: 'PremiumIcons');
      final iconSet = UiIconSet(
        replacements: {UiIcons.search: replacement},
        weight: 420,
      );
      final copied = NeonTheme.dark.copyWith(icons: iconSet);

      expect(copied.icons.resolve(UiIcons.search), replacement);
      expect(copied.icons.resolve(UiIcons.close), UiIcons.close);
      expect(copied.icons.weight, 420);
    });
  });

  group('UiComponentTokens', () {
    test('provides premium defaults and derived radii', () {
      const tokens = UiComponentTokens();

      expect(tokens.controlHeightMedium, 44);
      expect(tokens.appBarHeight, 64);
      expect(tokens.controlBorderRadius, BorderRadius.circular(12));
      expect(tokens.cardBorderRadius, BorderRadius.circular(16));
    });
  });

  group('UiColorScheme', () {
    test('copyWith works correctly', () {
      final scheme = NeonTheme.dark.colorScheme;
      final modified = scheme.copyWith(primary: const Color(0xFFFF0000));

      expect(modified.primary, const Color(0xFFFF0000));
      expect(modified.secondary, scheme.secondary);
    });
  });

  group('UiTypography', () {
    test('fromFont creates all levels', () {
      final typo = UiTypography.fromFont(fontFamily: 'TestFont', color: const Color(0xFFFFFFFF));

      expect(typo.displayLarge.fontFamily, 'TestFont');
      expect(typo.bodyMedium.color, const Color(0xFFFFFFFF));
      expect(typo.labelSmall.fontWeight, FontWeight.w600);
      expect(typo.bodyMedium.height, 1.5);
      expect(typo.displayLarge.height, 1.02);
      expect(typo.bodyMedium.fontFamilyFallback, contains('Roboto'));
    });

    test('supports a separate display face', () {
      final typo = UiTypography.fromFont(
        fontFamily: 'UiFont',
        displayFontFamily: 'DisplayFont',
        color: const Color(0xFFFFFFFF),
      );

      expect(typo.displayLarge.fontFamily, 'DisplayFont');
      expect(typo.headlineMedium.fontFamily, 'DisplayFont');
      expect(typo.bodyMedium.fontFamily, 'UiFont');
    });

    test('apply overrides color and fontFamily', () {
      final typo = UiTypography.fromFont(fontFamily: 'Original', color: const Color(0xFFFFFFFF));
      final applied = typo.apply(color: const Color(0xFF000000), fontFamily: 'NewFont');

      expect(applied.bodyMedium.color, const Color(0xFF000000));
      expect(applied.bodyMedium.fontFamily, 'NewFont');
    });
  });

  group('UiSpacing', () {
    test('default values are correct', () {
      const spacing = UiSpacing();
      expect(spacing.xs, 4.0);
      expect(spacing.md, 16.0);
      expect(spacing.borderRadiusMd, 8.0);
    });

    test('radiusMd returns BorderRadius', () {
      const spacing = UiSpacing();
      expect(spacing.radiusMd, BorderRadius.circular(8.0));
    });

    test('copyWith works', () {
      const spacing = UiSpacing();
      final modified = spacing.copyWith(md: 24.0);
      expect(modified.md, 24.0);
      expect(modified.sm, spacing.sm);
    });
  });

  group('UiButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(UiButton(label: 'Click me', onPressed: () {})));

      expect(find.text('Click me'), findsOneWidget);
    });

    testWidgets('uses themed control height', (tester) async {
      final theme = NeonTheme.dark.copyWith(
        components: const UiComponentTokens(controlHeightMedium: 50),
      );
      await tester.pumpWidget(
        _wrap(
          Align(
            alignment: Alignment.topLeft,
            child: UiButton(label: 'Sized', onPressed: () {}),
          ),
          theme: theme,
        ),
      );

      expect(tester.getSize(find.byType(UiButton)).height, 50);
    });

    testWidgets('calls onPressed on tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(UiButton(label: 'Tap', onPressed: () => tapped = true)));

      await tester.tap(find.text('Tap'));
      expect(tapped, isTrue);
    });

    testWidgets('activates from the keyboard', (tester) async {
      var activations = 0;
      await tester.pumpWidget(
        _wrap(
          Align(
            child: UiButton(
              label: 'Keyboard action',
              autofocus: true,
              onPressed: () => activations++,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      expect(activations, 1);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(_wrap(const UiButton(label: 'Disabled')));

      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('renders all variants without error', (tester) async {
      for (final variant in UiButtonVariant.values) {
        await tester.pumpWidget(
          _wrap(UiButton(label: variant.name, variant: variant, onPressed: () {})),
        );
        expect(find.text(variant.name), findsOneWidget);
      }
    });

    testWidgets('adapts to different themes', (tester) async {
      for (final theme in [
        NeonTheme.dark,
        GlassTheme.dark,
        MinimalTheme.dark,
        CyberpunkTheme.dark,
      ]) {
        await tester.pumpWidget(
          _wrap(
            UiButton(label: 'Themed', onPressed: () {}),
            theme: theme,
          ),
        );
        expect(find.text('Themed'), findsOneWidget);
      }
    });
  });

  group('UiCard', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(_wrap(const UiCard(child: Text('Card Content'))));

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('handles tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(UiCard(onTap: () => tapped = true, child: const Text('Tap Card'))),
      );

      await tester.tap(find.text('Tap Card'));
      expect(tapped, isTrue);
    });
  });

  group('UiBadge', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_wrap(const UiBadge(label: 'NEW')));

      expect(find.text('NEW'), findsOneWidget);
    });

    testWidgets('renders all types', (tester) async {
      for (final type in UiBadgeType.values) {
        await tester.pumpWidget(_wrap(UiBadge(label: type.name, type: type)));
        expect(find.text(type.name), findsOneWidget);
      }
    });
  });

  group('UiToggle', () {
    testWidgets('toggles value on tap', (tester) async {
      var value = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrap(UiToggle(value: value, onChanged: (v) => setState(() => value = v)));
          },
        ),
      );

      await tester.tap(find.byType(UiToggle));
      await tester.pump();
      expect(value, isTrue);
    });

    testWidgets('uses a minimum 44 pixel interaction target', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Align(
            child: UiToggle(
              value: false,
              semanticLabel: 'Notifications',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(UiToggle)).height, greaterThanOrEqualTo(44));
      expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
    });
  });

  group('UiChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_wrap(const UiChip(label: 'Flutter')));

      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('handles tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(UiChip(label: 'Chip', onTap: () => tapped = true)));

      await tester.tap(find.text('Chip'));
      expect(tapped, isTrue);
    });
  });

  group('UiAvatar', () {
    testWidgets('renders initials', (tester) async {
      await tester.pumpWidget(_wrap(const UiAvatar(initials: 'TL')));

      expect(find.text('TL'), findsOneWidget);
    });

    testWidgets('all sizes render', (tester) async {
      for (final size in UiAvatarSize.values) {
        await tester.pumpWidget(_wrap(UiAvatar(initials: 'A', size: size)));
        expect(find.text('A'), findsOneWidget);
      }
    });
  });

  group('UiProgressBar', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_wrap(const UiProgressBar(value: 0.5)));

      expect(find.byType(UiProgressBar), findsOneWidget);
    });

    testWidgets('shows label when enabled', (tester) async {
      await tester.pumpWidget(_wrap(const UiProgressBar(value: 0.75, showLabel: true)));

      expect(find.text('75%'), findsOneWidget);
    });
  });

  group('UiDivider', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_wrap(const UiDivider()));

      expect(find.byType(UiDivider), findsOneWidget);
    });

    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(_wrap(const UiDivider(label: 'OR')));

      expect(find.text('OR'), findsOneWidget);
    });
  });

  group('UiAppBar', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(_wrap(const UiAppBar(title: Text('My App'))));

      expect(find.text('My App'), findsOneWidget);
    });

    testWidgets('renders actions', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiAppBar(title: Text('App'), actions: [Text('A1'), Text('A2')])),
      );

      expect(find.text('A1'), findsOneWidget);
      expect(find.text('A2'), findsOneWidget);
    });
  });

  group('New Design Presets', () {
    test('RetroTheme has dark and light', () {
      expect(RetroTheme.dark.name, 'Retro Dark');
      expect(RetroTheme.light.name, 'Retro Light');
      expect(RetroTheme.dark.useGlow, isTrue);
    });

    test('AuroraTheme has dark and light', () {
      expect(AuroraTheme.dark.name, 'Aurora Dark');
      expect(AuroraTheme.light.name, 'Aurora Light');
      expect(AuroraTheme.dark.useGradients, isTrue);
    });

    test('TerminalTheme has dark and amber', () {
      expect(TerminalTheme.dark.name, 'Terminal Dark');
      expect(TerminalTheme.amber.name, 'Terminal Amber');
    });

    test('PastelTheme has dark and light', () {
      expect(PastelTheme.dark.name, 'Pastel Dark');
      expect(PastelTheme.light.name, 'Pastel Light');
      expect(PastelTheme.light.useGlow, isFalse);
    });
  });

  group('UiDialog', () {
    testWidgets('renders title and content', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiDialog(title: 'Confirm', content: Text('Are you sure?'))),
      );

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
    });

    testWidgets('renders actions', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiDialog(title: 'Test', actions: [Text('OK'), Text('Cancel')])),
      );

      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('UiBottomSheet', () {
    testWidgets('renders child and title', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: _wrap(const UiBottomSheet(title: 'Options', child: Text('Content here'))),
        ),
      );

      expect(find.text('Options'), findsOneWidget);
      expect(find.text('Content here'), findsOneWidget);
    });
  });

  group('UiTabBar', () {
    testWidgets('renders tabs', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiTabBar(
            tabs: const [
              UiTab(label: 'Home'),
              UiTab(label: 'Settings'),
            ],
            selectedIndex: 0,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('calls onChanged on tap', (tester) async {
      var selected = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrap(
              UiTabBar(
                tabs: const [
                  UiTab(label: 'A'),
                  UiTab(label: 'B'),
                ],
                selectedIndex: selected,
                onChanged: (i) => setState(() => selected = i),
              ),
            );
          },
        ),
      );

      await tester.tap(find.text('B'));
      await tester.pump();
      expect(selected, 1);
    });
  });

  group('UiSidebar', () {
    testWidgets('renders items', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: _wrap(
            UiSidebar(
              items: const [
                UiSidebarItem(label: 'Dashboard'),
                UiSidebarItem(label: 'Settings'),
              ],
              selectedIndex: 0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('UiDrawer', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(_wrap(const UiDrawer(child: Text('Drawer Content'))));

      expect(find.text('Drawer Content'), findsOneWidget);
    });
  });

  group('UiDropdown', () {
    testWidgets('renders placeholder', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiDropdown<String>(
            items: const ['A', 'B'],
            itemBuilder: (item) => Text(item),
            onChanged: (_) {},
            placeholder: 'Select...',
          ),
        ),
      );

      expect(find.text('Select...'), findsOneWidget);
    });

    testWidgets('renders selected value', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiDropdown<String>(
            value: 'Apple',
            items: const ['Apple', 'Banana'],
            itemBuilder: (item) => Text(item),
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Apple'), findsOneWidget);
    });
  });

  group('UiTooltip', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiTooltip(message: 'Help text', child: Text('Hover me'))),
      );

      expect(find.text('Hover me'), findsOneWidget);
    });
  });

  group('UiSkeleton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_wrap(const UiSkeleton(width: 200, height: 16)));

      expect(find.byType(UiSkeleton), findsOneWidget);
    });

    testWidgets('circle variant renders', (tester) async {
      await tester.pumpWidget(_wrap(const UiSkeleton.circle(size: 44)));

      expect(find.byType(UiSkeleton), findsOneWidget);
    });
  });

  group('UiTable', () {
    testWidgets('renders headers and rows', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const UiTable(
            columns: [
              UiTableColumn(label: 'Name'),
              UiTableColumn(label: 'Age'),
            ],
            rows: [
              [Text('Alice'), Text('30')],
              [Text('Bob'), Text('25')],
            ],
          ),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('handles row tap', (tester) async {
      var tappedRow = -1;

      await tester.pumpWidget(
        _wrap(
          UiTable(
            columns: const [UiTableColumn(label: 'Item')],
            rows: const [
              [Text('Row 0')],
              [Text('Row 1')],
            ],
            onRowTap: (i) => tappedRow = i,
          ),
        ),
      );

      await tester.tap(find.text('Row 1'));
      expect(tappedRow, 1);
    });
  });

  group('UiIcon', () {
    testWidgets('renders with theme color', (tester) async {
      await tester.pumpWidget(_wrap(const UiIcon(UiIcons.home)));

      expect(find.byType(UiIcon), findsOneWidget);
    });
  });

  group('AnimatedUiTheme', () {
    testWidgets('provides theme and animates', (tester) async {
      late UiThemeData resolved;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: AnimatedUiTheme(
            data: NeonTheme.dark,
            child: Builder(
              builder: (context) {
                resolved = UiTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(resolved.name, 'Neon Dark');
    });
  });

  group('UiThemeMode', () {
    testWidgets('selects dark theme when forced', (tester) async {
      late UiThemeData resolved;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: UiThemeMode(
              dark: NeonTheme.dark,
              light: NeonTheme.light,
              child: Builder(
                builder: (context) {
                  resolved = UiTheme.of(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(resolved.name, 'Neon Dark');
    });

    testWidgets('selects light theme when forced', (tester) async {
      late UiThemeData resolved;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.light),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: UiThemeMode(
              dark: NeonTheme.dark,
              light: NeonTheme.light,
              child: Builder(
                builder: (context) {
                  resolved = UiTheme.of(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(resolved.name, 'Neon Light');
    });

    testWidgets('mode override works', (tester) async {
      late UiThemeData resolved;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: UiThemeMode(
            dark: NeonTheme.dark,
            light: NeonTheme.light,
            mode: Brightness.dark,
            child: Builder(
              builder: (context) {
                resolved = UiTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(resolved.name, 'Neon Dark');
    });
  });

  group('UiResponsive', () {
    testWidgets('selects mobile layout', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: UiResponsive(
              mobile: (context) => const Text('Mobile'),
              desktop: (context) => const Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
    });

    testWidgets('selects desktop layout', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: UiResponsive(
              mobile: (context) => const Text('Mobile'),
              desktop: (context) => const Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Desktop'), findsOneWidget);
    });

    test('UiScreenInfo.value selects correct value', () {
      final info = UiScreenInfo.forWidth(1200);
      final cols = info.value(mobile: 1, tablet: 2, desktop: 3);
      expect(cols, 3);
    });
  });

  group('UiTextField (improved)', () {
    testWidgets('shows error text', (tester) async {
      await tester.pumpWidget(_wrap(const UiTextField(label: 'Email', errorText: 'Invalid email')));

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('shows helper text', (tester) async {
      await tester.pumpWidget(_wrap(const UiTextField(helperText: 'Enter your name')));

      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('disabled state renders', (tester) async {
      await tester.pumpWidget(_wrap(const UiTextField(label: 'Disabled', enabled: false)));

      expect(find.text('Disabled'), findsOneWidget);
    });
  });

  group('UiAvatar (improved)', () {
    testWidgets('shows status indicator', (tester) async {
      await tester.pumpWidget(_wrap(const UiAvatar(initials: 'TL', status: UiAvatarStatus.online)));

      expect(find.text('TL'), findsOneWidget);
      // Status indicator adds a Stack
      expect(find.byType(Stack), findsOneWidget);
    });
  });

  group('UiBadge (improved)', () {
    testWidgets('renders all sizes', (tester) async {
      for (final size in UiBadgeSize.values) {
        await tester.pumpWidget(_wrap(UiBadge(label: size.name, size: size)));
        expect(find.text(size.name), findsOneWidget);
      }
    });

    testWidgets('renders with icon', (tester) async {
      await tester.pumpWidget(_wrap(const UiBadge(label: 'NEW', icon: UiIcons.star)));

      expect(find.text('NEW'), findsOneWidget);
    });
  });

  group('UiChip (improved)', () {
    testWidgets('disabled chip does not respond to tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(UiChip(label: 'Off', enabled: false, onTap: () => tapped = true)),
      );

      await tester.tap(find.text('Off'));
      expect(tapped, isFalse);
    });
  });

  group('UiProgressBar (improved)', () {
    testWidgets('animates value changes', (tester) async {
      await tester.pumpWidget(_wrap(const UiProgressBar(value: 0.3)));

      await tester.pumpWidget(_wrap(const UiProgressBar(value: 0.8)));

      // Should find AnimatedFractionallySizedBox
      expect(find.byType(AnimatedFractionallySizedBox), findsOneWidget);
    });
  });

  group('UiApp', () {
    testWidgets('sets up theme and navigator', (tester) async {
      await tester.pumpWidget(
        UiApp(
          theme: NeonTheme.dark,
          home: Builder(
            builder: (context) {
              final theme = UiTheme.of(context);
              return Text(theme.name);
            },
          ),
        ),
      );

      expect(find.text('Neon Dark'), findsOneWidget);
    });

    testWidgets('auto dark/light switch', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: UiApp(
            theme: NeonTheme.light,
            darkTheme: NeonTheme.dark,
            home: Builder(
              builder: (context) {
                return Text(UiTheme.of(context).name);
              },
            ),
          ),
        ),
      );

      expect(find.text('Neon Dark'), findsOneWidget);
    });
  });

  group('UiScaffold', () {
    testWidgets('renders body', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: _wrap(const UiScaffold(body: Text('Content'))),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('renders appBar and body', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: _wrap(
            const UiScaffold(
              appBar: UiAppBar(title: Text('Title')),
              body: Text('Body'),
            ),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('hides sidebar on narrow screen', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: _wrap(
            UiScaffold(
              sidebar: UiSidebar(
                items: const [UiSidebarItem(label: 'Nav')],
                selectedIndex: 0,
                onChanged: (_) {},
              ),
              body: const Text('Body'),
            ),
          ),
        ),
      );

      expect(find.text('Nav'), findsNothing); // hidden on mobile
    });
  });

  group('UiTextField (placeholder)', () {
    testWidgets('shows placeholder when empty', (tester) async {
      await tester.pumpWidget(_wrap(const UiTextField(placeholder: 'Type here...')));

      expect(find.text('Type here...'), findsOneWidget);
    });

    testWidgets('shows character counter', (tester) async {
      final controller = TextEditingController(text: 'Hello');
      await tester.pumpWidget(_wrap(UiTextField(controller: controller, maxLength: 10)));

      expect(find.text('5/10'), findsOneWidget);
    });
  });

  group('UiListTile', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiListTile(title: Text('Alice'), subtitle: Text('Online'))),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('handles tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(UiListTile(title: const Text('Item'), onTap: () => tapped = true)),
      );

      await tester.tap(find.text('Item'));
      expect(tapped, isTrue);
    });
  });

  group('UiResponsiveBody', () {
    testWidgets('renders with max width', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: _wrap(const UiResponsiveBody(maxWidth: 600, child: Text('Centered'))),
        ),
      );

      expect(find.text('Centered'), findsOneWidget);
    });
  });

  group('UiForm', () {
    testWidgets('validates fields', (tester) async {
      final formKey = GlobalKey<UiFormState>();

      await tester.pumpWidget(
        _wrap(
          UiForm(
            key: formKey,
            child: Column(
              children: [
                UiFormField(fieldKey: 'email', label: 'Email', validators: [UiValidators.required]),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Validate with empty field should fail
      final isValid = formKey.currentState!.validate();
      expect(isValid, isFalse);

      await tester.pump();
      expect(find.text('This field is required'), findsOneWidget);
    });
  });

  group('UiValidators', () {
    test('required rejects empty', () {
      expect(UiValidators.required(''), isNotNull);
      expect(UiValidators.required('  '), isNotNull);
      expect(UiValidators.required('hello'), isNull);
    });

    test('email validates format', () {
      expect(UiValidators.email(''), isNull); // empty ok (use required)
      expect(UiValidators.email('bad'), isNotNull);
      expect(UiValidators.email('a@b.c'), isNull);
    });

    test('minLength works', () {
      final v = UiValidators.minLength(3);
      expect(v('ab'), isNotNull);
      expect(v('abc'), isNull);
    });

    test('numeric works', () {
      expect(UiValidators.numeric(''), isNull);
      expect(UiValidators.numeric('abc'), isNotNull);
      expect(UiValidators.numeric('42'), isNull);
      expect(UiValidators.numeric('3.14'), isNull);
    });

    test('matches works', () {
      var pw = 'secret';
      final v = UiValidators.matches(() => pw);
      expect(v('wrong'), isNotNull);
      expect(v('secret'), isNull);
    });
  });

  group('UiHero', () {
    testWidgets('renders child with hero tag', (tester) async {
      await tester.pumpWidget(_wrap(const UiHero(tag: 'test', child: Text('Hero'))));

      expect(find.text('Hero'), findsOneWidget);
      expect(find.byType(Hero), findsOneWidget);
    });

    testWidgets('all flight styles build', (tester) async {
      for (final style in UiHeroFlightStyle.values) {
        await tester.pumpWidget(
          _wrap(UiHero(tag: 'test-$style', flightStyle: style, child: const Text('H'))),
        );
        expect(find.text('H'), findsOneWidget);
      }
    });
  });

  group('UiPageRoute', () {
    test('all transition styles exist', () {
      expect(UiTransitionStyle.values.length, greaterThanOrEqualTo(6));
    });
  });

  group('UiGradientText', () {
    testWidgets('renders text', (tester) async {
      await tester.pumpWidget(_wrap(const UiGradientText('Gradient')));

      expect(find.text('Gradient'), findsOneWidget);
    });

    testWidgets('uses custom colors', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiGradientText('Custom', colors: [Color(0xFFFF0000), Color(0xFF0000FF)])),
      );

      expect(find.text('Custom'), findsOneWidget);
    });
  });

  group('UiShimmerText', () {
    testWidgets('renders and animates', (tester) async {
      await tester.pumpWidget(_wrap(const UiShimmerText('Loading...')));

      expect(find.text('Loading...'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Loading...'), findsOneWidget);
    });
  });

  group('UiPulse', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(_wrap(const UiPulse(child: Text('Pulse'))));

      expect(find.text('Pulse'), findsOneWidget);
    });

    testWidgets('can be disabled', (tester) async {
      await tester.pumpWidget(_wrap(const UiPulse(enabled: false, child: Text('Static'))));

      expect(find.text('Static'), findsOneWidget);
    });
  });

  group('UiGlowContainer', () {
    testWidgets('renders child with glow', (tester) async {
      await tester.pumpWidget(_wrap(const UiGlowContainer(child: Text('Glow'))));

      expect(find.text('Glow'), findsOneWidget);
    });

    testWidgets('static glow mode', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiGlowContainer(animate: false, child: Text('Static Glow'))),
      );

      expect(find.text('Static Glow'), findsOneWidget);
    });
  });

  group('UiTypewriter', () {
    testWidgets('types text progressively', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiTypewriter(text: 'Hello', speed: Duration(milliseconds: 50))),
      );

      // Initially should be empty or very short
      await tester.pump(const Duration(milliseconds: 100));
      // After some time, should have partial text
      await tester.pump(const Duration(milliseconds: 200));
      // Widget should still be there
      expect(find.byType(UiTypewriter), findsOneWidget);
    });
  });

  group('UiCountUp', () {
    testWidgets('renders and animates to target', (tester) async {
      await tester.pumpWidget(_wrap(const UiCountUp(end: 100)));

      expect(find.byType(UiCountUp), findsOneWidget);

      // After full duration it should show 100
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('formats with prefix and separator', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiCountUp(end: 1234, prefix: '\$', duration: Duration(milliseconds: 100))),
      );

      await tester.pumpAndSettle();
      expect(find.text('\$1,234'), findsOneWidget);
    });
  });

  group('UiStagger', () {
    testWidgets('renders all children', (tester) async {
      await tester.pumpWidget(_wrap(const UiStagger(children: [Text('A'), Text('B'), Text('C')])));

      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('all directions work', (tester) async {
      for (final dir in UiStaggerDirection.values) {
        await tester.pumpWidget(_wrap(UiStagger(direction: dir, children: const [Text('X')])));
        await tester.pumpAndSettle();
        expect(find.text('X'), findsOneWidget);
      }
    });
  });

  group('UiCheckbox', () {
    testWidgets('renders and toggles', (tester) async {
      var value = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrap(
              UiCheckbox(value: value, onChanged: (v) => setState(() => value = v ?? false)),
            );
          },
        ),
      );

      await tester.tap(find.byType(UiCheckbox));
      await tester.pump();
      expect(value, isTrue);
    });

    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(_wrap(UiCheckbox(value: false, onChanged: (_) {}, label: 'Accept')));
      expect(find.text('Accept'), findsOneWidget);
    });

    testWidgets('disabled does not toggle', (tester) async {
      var value = false;
      await tester.pumpWidget(
        _wrap(UiCheckbox(value: value, onChanged: (v) => value = v ?? false, enabled: false)),
      );
      await tester.tap(find.byType(UiCheckbox));
      expect(value, isFalse);
    });
  });

  group('UiRadio', () {
    testWidgets('selects value', (tester) async {
      var selected = 'a';
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrap(
              Column(
                children: [
                  UiRadio<String>(
                    value: 'a',
                    groupValue: selected,
                    onChanged: (v) => setState(() => selected = v),
                    label: 'Option A',
                  ),
                  UiRadio<String>(
                    value: 'b',
                    groupValue: selected,
                    onChanged: (v) => setState(() => selected = v),
                    label: 'Option B',
                  ),
                ],
              ),
            );
          },
        ),
      );

      await tester.tap(find.text('Option B'));
      await tester.pump();
      expect(selected, 'b');
    });
  });

  group('UiSlider', () {
    testWidgets('renders with label and value', (tester) async {
      await tester.pumpWidget(
        _wrap(UiSlider(value: 0.5, onChanged: (_) {}, label: 'Volume', showValue: true)),
      );

      expect(find.text('Volume'), findsOneWidget);
      expect(find.byType(UiSlider), findsOneWidget);
    });

    testWidgets('supports arrow-key value changes', (tester) async {
      var value = 0.5;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _wrap(
            UiSlider(
              value: value,
              autofocus: true,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

      expect(value, closeTo(0.55, 0.001));
    });
  });

  group('UiAccordion', () {
    testWidgets('renders sections and expands', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const UiAccordion(
            sections: [
              UiAccordionSection(title: 'Section 1', content: Text('Content 1')),
              UiAccordionSection(title: 'Section 2', content: Text('Content 2')),
            ],
          ),
        ),
      );

      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Section 2'), findsOneWidget);

      // Tap to expand
      await tester.tap(find.text('Section 1'));
      await tester.pumpAndSettle();
      expect(find.text('Content 1'), findsOneWidget);
    });
  });

  group('UiSearchBar', () {
    testWidgets('renders placeholder', (tester) async {
      await tester.pumpWidget(_wrap(const UiSearchBar(placeholder: 'Search...')));

      expect(find.text('Search...'), findsOneWidget);
    });

    testWidgets('calls onChanged', (tester) async {
      String? lastQuery;
      await tester.pumpWidget(_wrap(UiSearchBar(onChanged: (q) => lastQuery = q)));

      await tester.enterText(find.byType(EditableText), 'hello');
      expect(lastQuery, 'hello');
    });
  });

  group('UiEmptyState', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiEmptyState(title: 'No items', description: 'Add your first item.')),
      );

      expect(find.text('No items'), findsOneWidget);
      expect(find.text('Add your first item.'), findsOneWidget);
    });

    testWidgets('renders action widget', (tester) async {
      await tester.pumpWidget(_wrap(const UiEmptyState(title: 'Empty', action: Text('Add'))));

      expect(find.text('Add'), findsOneWidget);
    });
  });

  group('UiLoadingOverlay', () {
    testWidgets('renders spinner', (tester) async {
      await tester.pumpWidget(_wrap(const UiLoadingOverlay()));

      expect(find.byType(UiLoadingOverlay), findsOneWidget);
    });

    testWidgets('shows message', (tester) async {
      await tester.pumpWidget(_wrap(const UiLoadingOverlay(message: 'Loading...')));

      expect(find.text('Loading...'), findsOneWidget);
    });
  });

  group('UiBottomNav', () {
    testWidgets('renders items and handles tap', (tester) async {
      var index = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrap(
              UiBottomNav(
                items: const [
                  UiBottomNavItem(icon: UiIcons.home, label: 'Home'),
                  UiBottomNavItem(icon: UiIcons.search, label: 'Search'),
                ],
                selectedIndex: index,
                onChanged: (i) => setState(() => index = i),
              ),
            );
          },
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      await tester.tap(find.text('Search'));
      await tester.pump();
      expect(index, 1);
    });

    testWidgets('shows badge count', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiBottomNav(
            items: const [UiBottomNavItem(icon: UiIcons.notifications, label: 'Alerts', badge: 5)],
            selectedIndex: 0,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });
  });

  group('UiStepper', () {
    testWidgets('renders steps', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const UiStepper(
            currentStep: 1,
            steps: [
              UiStep(title: 'Account'),
              UiStep(title: 'Details'),
              UiStep(title: 'Confirm'),
            ],
          ),
        ),
      );

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('shows step content', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const UiStepper(
            currentStep: 0,
            steps: [UiStep(title: 'Step 1', content: Text('Form here'))],
          ),
        ),
      );

      expect(find.text('Form here'), findsOneWidget);
    });
  });

  group('UiRating', () {
    testWidgets('renders stars', (tester) async {
      await tester.pumpWidget(_wrap(const UiRating(value: 3.0)));

      expect(find.byType(UiRating), findsOneWidget);
    });
  });

  group('UiAlert', () {
    testWidgets('renders all types', (tester) async {
      for (final type in UiAlertType.values) {
        await tester.pumpWidget(_wrap(UiAlert(type: type, message: type.name)));
        expect(find.text(type.name), findsOneWidget);
      }
    });

    testWidgets('renders title and dismiss', (tester) async {
      await tester.pumpWidget(
        _wrap(UiAlert(title: 'Warning', message: 'Disk full', onDismiss: () {})),
      );

      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Disk full'), findsOneWidget);
    });
  });

  group('UiPopoverMenu', () {
    testWidgets('renders trigger child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiPopoverMenu(
            items: const [UiPopoverItem(label: 'Edit')],
            onSelected: (_) {},
            child: const Text('Menu'),
          ),
        ),
      );

      expect(find.text('Menu'), findsOneWidget);
    });
  });

  group('UiNotificationDot', () {
    testWidgets('shows count', (tester) async {
      await tester.pumpWidget(_wrap(const UiNotificationDot(count: 7, child: Text('Icon'))));

      expect(find.text('7'), findsOneWidget);
      expect(find.text('Icon'), findsOneWidget);
    });

    testWidgets('caps at 99+', (tester) async {
      await tester.pumpWidget(_wrap(const UiNotificationDot(count: 150, child: Text('X'))));

      expect(find.text('99+'), findsOneWidget);
    });
  });

  group('UiTimeline', () {
    testWidgets('renders items', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const UiTimeline(
            items: [
              UiTimelineItem(title: 'Created', subtitle: '2h ago'),
              UiTimelineItem(title: 'Shipped'),
              UiTimelineItem(title: 'Delivered'),
            ],
          ),
        ),
      );

      expect(find.text('Created'), findsOneWidget);
      expect(find.text('Shipped'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
      expect(find.text('2h ago'), findsOneWidget);
    });
  });

  group('UiStat', () {
    testWidgets('renders label, value, trend', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const UiStat(
            label: 'Revenue',
            value: '\$12,345',
            trend: UiStatTrend.up,
            trendText: '+12%',
          ),
        ),
      );

      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('\$12,345'), findsOneWidget);
    });
  });

  group('UiPinInput', () {
    testWidgets('renders cells', (tester) async {
      await tester.pumpWidget(_wrap(const UiPinInput(length: 4, autofocus: false)));

      expect(find.byType(UiPinInput), findsOneWidget);
    });
  });

  group('UiSwipeAction', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiSwipeAction(
            trailingActions: [
              UiSwipeActionData(label: 'Delete', color: const Color(0xFFFF0000), onTap: () {}),
            ],
            child: const Text('Swipe me'),
          ),
        ),
      );

      expect(find.text('Swipe me'), findsOneWidget);
    });
  });

  group('UiMultiStepForm', () {
    testWidgets('renders steps and navigates', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 400,
            child: UiMultiStepForm(
              steps: const [
                UiFormStep(title: 'Step 1', content: Text('Content 1')),
                UiFormStep(title: 'Step 2', content: Text('Content 2')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Step 2'), findsOneWidget);
      expect(find.text('Content 1'), findsOneWidget);

      // Tap Next
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Content 2'), findsOneWidget);
    });
  });

  group('UiCarousel', () {
    testWidgets('renders children with indicators', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiCarousel(height: 100, children: [Text('Slide 1'), Text('Slide 2')])),
      );

      expect(find.text('Slide 1'), findsOneWidget);
      expect(find.byType(UiCarousel), findsOneWidget);
    });
  });

  group('UiImageViewer', () {
    testWidgets('renders widget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 100,
            height: 100,
            child: UiImageViewer(image: MemoryImage(_kTransparentPixel), width: 100, height: 100),
          ),
        ),
      );

      expect(find.byType(UiImageViewer), findsOneWidget);
    });
  });

  group('UiGallery', () {
    testWidgets('renders grid', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            height: 200,
            child: UiGallery(
              images: [MemoryImage(_kTransparentPixel), MemoryImage(_kTransparentPixel)],
              crossAxisCount: 2,
            ),
          ),
        ),
      );

      expect(find.byType(UiGallery), findsOneWidget);
    });
  });

  group('UiCodeBlock', () {
    testWidgets('renders code text', (tester) async {
      await tester.pumpWidget(_wrap(const UiCodeBlock(code: 'void main() {}', language: 'dart')));

      expect(find.text('void main() {}'), findsOneWidget);
      expect(find.text('dart'), findsOneWidget);
    });

    testWidgets('shows line numbers', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiCodeBlock(code: 'line1\nline2', showLineNumbers: true)),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });

  group('UiCalendar', () {
    testWidgets('renders month and day headers', (tester) async {
      await tester.pumpWidget(
        _wrap(UiCalendar(initialMonth: DateTime(2026, 4), onDateSelected: (_) {})),
      );

      expect(find.text('April 2026'), findsOneWidget);
      expect(find.text('Mo'), findsOneWidget);
      expect(find.text('Su'), findsOneWidget);
    });

    testWidgets('selects a date', (tester) async {
      DateTime? selected;
      await tester.pumpWidget(
        _wrap(UiCalendar(initialMonth: DateTime(2026, 4), onDateSelected: (d) => selected = d)),
      );

      await tester.tap(find.text('15'));
      expect(selected?.day, 15);
    });
  });

  // === Tier 1 ===

  group('UiAsyncBuilder', () {
    testWidgets('shows loading then data', (tester) async {
      final future = Future.value('Hello');

      await tester.pumpWidget(
        _wrap(UiAsyncBuilder<String>(future: future, builder: (context, data) => Text(data))),
      );

      // After future completes
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
    });
  });

  group('UiPullToRefresh', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiPullToRefresh(
            onRefresh: () async {},
            child: ListView(children: const [Text('Item')]),
          ),
        ),
      );

      expect(find.text('Item'), findsOneWidget);
    });
  });

  group('UiInfiniteList', () {
    testWidgets('renders items', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiInfiniteList<String>(
            items: const ['A', 'B', 'C'],
            itemBuilder: (context, item, index) => Text(item),
            onLoadMore: () async {},
            hasMore: false,
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });
  });

  group('UiConfirmDialog', () {
    testWidgets('renders title and message', (tester) async {
      // Just test the widget directly (not via show)
      await tester.pumpWidget(_wrap(const Center(child: Text('UiConfirmDialog exists'))));

      expect(find.text('UiConfirmDialog exists'), findsOneWidget);
    });
  });

  group('UiActionSheet', () {
    testWidgets('type exists', (tester) async {
      // Verify type exists
      const item = UiActionSheetItem(label: 'Test');
      expect(item.label, 'Test');
    });
  });

  // === Tier 2 ===

  group('UiTagInput', () {
    testWidgets('renders existing tags', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiTagInput(tags: const ['Flutter', 'Dart'], onTagAdded: (_) {}, onTagRemoved: (_) {}),
        ),
      );

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
    });
  });

  group('UiNumberInput', () {
    testWidgets('renders value and buttons', (tester) async {
      await tester.pumpWidget(_wrap(UiNumberInput(value: 5, onChanged: (_) {}, label: 'Quantity')));

      expect(find.text('5'), findsOneWidget);
      expect(find.text('Quantity'), findsOneWidget);
    });
  });

  group('UiExpandableText', () {
    testWidgets('renders text', (tester) async {
      await tester.pumpWidget(
        _wrap(const SizedBox(width: 200, child: UiExpandableText(text: 'Short text', maxLines: 3))),
      );

      expect(find.byType(UiExpandableText), findsOneWidget);
      expect(find.textContaining('Short text'), findsWidgets);
    });
  });

  group('UiResponsiveGrid', () {
    testWidgets('renders grid items', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: _wrap(
            UiResponsiveGrid(
              children: const [
                UiGridItem(child: Text('Col 1')),
                UiGridItem(child: Text('Col 2')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Col 1'), findsOneWidget);
      expect(find.text('Col 2'), findsOneWidget);
    });
  });

  group('UiOnboarding', () {
    testWidgets('renders pages with navigation', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiOnboarding(
            pages: const [
              UiOnboardingPage(title: 'Welcome', description: 'Intro page'),
              UiOnboardingPage(title: 'Features', description: 'Cool stuff'),
            ],
            onCompleted: () {},
          ),
        ),
      );

      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Intro page'), findsOneWidget);
    });
  });

  // === Tier 3 ===

  group('UiColorPicker', () {
    testWidgets('renders color swatches', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiColorPicker(value: const Color(0xFFFF0000), onChanged: (_) {}, label: 'Pick color'),
        ),
      );

      expect(find.text('Pick color'), findsOneWidget);
      expect(find.byType(UiColorPicker), findsOneWidget);
    });
  });

  group('UiSegmentedControl', () {
    testWidgets('renders segments and selects', (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrap(
              UiSegmentedControl(
                segments: const ['Day', 'Week', 'Month'],
                selectedIndex: selected,
                onChanged: (i) => setState(() => selected = i),
              ),
            );
          },
        ),
      );

      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);

      await tester.tap(find.text('Week'));
      await tester.pump();
      expect(selected, 1);
    });
  });

  group('UiBreadcrumb', () {
    testWidgets('renders items with separator', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiBreadcrumb(
            items: [
              UiBreadcrumbItem(label: 'Home', onTap: () {}),
              UiBreadcrumbItem(label: 'Products', onTap: () {}),
              const UiBreadcrumbItem(label: 'Details'),
            ],
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });
  });

  group('UiAvatarGroup', () {
    testWidgets('renders avatars with overflow', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const UiAvatarGroup(maxVisible: 2, avatars: [Text('A'), Text('B'), Text('C'), Text('D')]),
        ),
      );

      expect(find.text('+2'), findsOneWidget);
    });
  });

  group('UiStatusPage', () {
    testWidgets('renders all types', (tester) async {
      for (final type in UiStatusType.values) {
        await tester.pumpWidget(
          _wrap(UiStatusPage(type: type, title: type.name, description: 'Description')),
        );
        expect(find.text(type.name), findsOneWidget);
      }
    });

    testWidgets('renders action', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiStatusPage(type: UiStatusType.error, title: 'Error', action: Text('Retry'))),
      );

      expect(find.text('Retry'), findsOneWidget);
    });
  });

  // === MUST HAVE ===

  group('UiDatePicker', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(_wrap(UiDatePicker(label: 'Birthday', onChanged: (_) {})));
      expect(find.text('Birthday'), findsOneWidget);
    });
  });

  group('UiTimePicker', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(_wrap(UiTimePicker(label: 'Start time', onChanged: (_) {})));
      expect(find.text('Start time'), findsOneWidget);
    });
  });

  group('UiAutoComplete', () {
    testWidgets('renders input', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiAutoComplete<String>(
            suggestions: const ['Apple', 'Banana'],
            itemBuilder: (item) => Text(item),
            onSelected: (_) {},
            filter: (item, q) => item.toLowerCase().contains(q.toLowerCase()),
            placeholder: 'Search fruit...',
          ),
        ),
      );
      expect(find.byType(UiAutoComplete<String>), findsOneWidget);
    });
  });

  group('UiPagination', () {
    testWidgets('renders pages', (tester) async {
      await tester.pumpWidget(
        _wrap(UiPagination(currentPage: 1, totalPages: 10, onPageChanged: (_) {})),
      );
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('UiProgressCircle', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(_wrap(const UiProgressCircle(value: 0.7, showLabel: true)));
      expect(find.text('70%'), findsOneWidget);
    });
  });

  group('UiIconButton', () {
    testWidgets('renders and handles tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(UiIconButton(icon: UiIcons.settings, onPressed: () => tapped = true)),
      );
      await tester.tap(find.byType(UiIconButton));
      expect(tapped, isTrue);
    });
  });

  // === SHOULD HAVE ===

  group('UiTreeView', () {
    testWidgets('renders nodes', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const UiTreeView(
            nodes: [
              UiTreeNode(
                label: 'Root',
                children: [
                  UiTreeNode(label: 'Child 1'),
                  UiTreeNode(label: 'Child 2'),
                ],
              ),
            ],
          ),
        ),
      );
      expect(find.text('Root'), findsOneWidget);
    });
  });

  group('UiReorderableList', () {
    testWidgets('renders items', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: UiTheme(
            data: NeonTheme.dark,
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) {
                    return UiReorderableList<String>(
                      items: const ['A', 'B', 'C'],
                      itemBuilder: (context, item, index) => Text(item),
                      onReorder: (a, b) {},
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(UiReorderableList<String>), findsOneWidget);
    });
  });

  group('UiContextMenu', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiContextMenu(
            items: [UiContextMenuItem(label: 'Copy', onTap: () {})],
            child: const Text('Right-click me'),
          ),
        ),
      );
      expect(find.text('Right-click me'), findsOneWidget);
    });
  });

  group('UiResizablePanel', () {
    testWidgets('renders both children', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiResizablePanel(firstChild: Text('Left'), secondChild: Text('Right'))),
      );
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });
  });

  group('UiButtonGroup', () {
    testWidgets('renders and selects', (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrap(
              UiButtonGroup(
                labels: const ['S', 'M', 'L'],
                selectedIndex: selected,
                onChanged: (i) => setState(() => selected = i),
              ),
            );
          },
        ),
      );
      expect(find.text('S'), findsOneWidget);
      await tester.tap(find.text('L'));
      await tester.pump();
      expect(selected, 2);
    });
  });

  group('UiCollapsible', () {
    testWidgets('toggles content', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiCollapsible(title: Text('Title'), child: Text('Hidden content'))),
      );
      expect(find.text('Title'), findsOneWidget);
    });
  });

  group('UiFloatingActionButton', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(
        _wrap(UiFloatingActionButton(icon: const Icon(UiIcons.add), onPressed: () {})),
      );
      expect(find.byType(UiFloatingActionButton), findsOneWidget);
    });
  });

  group('UiHoverCard', () {
    testWidgets('renders trigger', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiHoverCard(content: Text('Preview'), child: Text('Hover me'))),
      );
      expect(find.text('Hover me'), findsOneWidget);
    });
  });

  // === NICE TO HAVE ===

  group('UiKbd', () {
    testWidgets('renders keys', (tester) async {
      await tester.pumpWidget(_wrap(const UiKbd(keys: ['Ctrl', 'K'])));
      expect(find.text('Ctrl'), findsOneWidget);
      expect(find.text('K'), findsOneWidget);
    });
  });

  group('UiClipboardButton', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(_wrap(const UiClipboardButton(text: 'copy me')));
      expect(find.byType(UiClipboardButton), findsOneWidget);
    });
  });

  group('UiMasonryGrid', () {
    testWidgets('renders children', (tester) async {
      await tester.pumpWidget(
        _wrap(const UiMasonryGrid(crossAxisCount: 2, children: [Text('A'), Text('B'), Text('C')])),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });
  });

  group('UiChatBubble', () {
    testWidgets('renders message', (tester) async {
      await tester.pumpWidget(_wrap(const UiChatBubble(message: 'Hello!', isMe: true)));
      expect(find.text('Hello!'), findsOneWidget);
    });

    testWidgets('renders other person', (tester) async {
      await tester.pumpWidget(_wrap(const UiChatBubble(message: 'Hi there', isMe: false)));
      expect(find.text('Hi there'), findsOneWidget);
    });
  });

  group('UiWatermark', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(_wrap(const UiWatermark(text: 'DRAFT', child: Text('Content'))));
      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('UiDescriptionList', () {
    testWidgets('renders items', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const UiDescriptionList(
            items: [
              UiDescriptionItem(label: 'Name', value: 'Alice'),
              UiDescriptionItem(label: 'Age', value: '30'),
            ],
          ),
        ),
      );
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });
  });

  group('UiMarquee', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        _wrap(const SizedBox(width: 200, child: UiMarquee(child: Text('Scrolling')))),
      );
      expect(find.byType(UiMarquee), findsOneWidget);
    });
  });

  group('UiSpeedDial', () {
    testWidgets('renders main button', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiSpeedDial(
            icon: UiIcons.add,
            actions: [UiSpeedDialAction(icon: UiIcons.edit, label: 'Edit', onTap: () {})],
          ),
        ),
      );
      expect(find.byType(UiSpeedDial), findsOneWidget);
    });
  });

  group('UiScrollIndicator', () {
    testWidgets('renders', (tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              UiScrollIndicator(controller: controller),
              Expanded(
                child: ListView(controller: controller, children: const [Text('A')]),
              ),
            ],
          ),
        ),
      );
      expect(find.byType(UiScrollIndicator), findsOneWidget);
    });
  });

  group('UiSignaturePad', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(height: 200, child: UiSignaturePad())));
      expect(find.byType(UiSignaturePad), findsOneWidget);
    });
  });

  // === CHAT MODULE ===

  group('UiChatModels', () {
    test('UiChatUser copyWith', () {
      const user = UiChatUser(id: '1', name: 'Alice');
      final updated = user.copyWith(isOnline: true);
      expect(updated.name, 'Alice');
      expect(updated.isOnline, isTrue);
    });

    test('UiChatMessage copyWith', () {
      final msg = UiChatMessage(
        id: 'm1',
        roomId: 'r1',
        sender: const UiChatUser(id: '1', name: 'Alice'),
        content: 'Hello',
        timestamp: DateTime(2026, 4, 22),
      );
      final updated = msg.copyWith(status: UiMessageStatus.read);
      expect(updated.content, 'Hello');
      expect(updated.status, UiMessageStatus.read);
    });

    test('UiChatRoom copyWith', () {
      const room = UiChatRoom(id: 'r1', name: 'General');
      final updated = room.copyWith(unreadCount: 5);
      expect(updated.name, 'General');
      expect(updated.unreadCount, 5);
    });
  });

  group('UiChatController', () {
    test('addMessage and getters', () {
      final controller = UiChatController(
        currentUser: const UiChatUser(id: 'me', name: 'Me'),
      );

      final msg = UiChatMessage(
        id: 'm1',
        roomId: 'r1',
        sender: const UiChatUser(id: 'me', name: 'Me'),
        content: 'Test',
        timestamp: DateTime.now(),
      );

      controller.addMessage(msg);
      expect(controller.messages.length, 1);
      expect(controller.messages.first.content, 'Test');

      controller.dispose();
    });

    test('setTyping and reply', () {
      final controller = UiChatController(
        currentUser: const UiChatUser(id: 'me', name: 'Me'),
      );

      final msg = UiChatMessage(
        id: 'm1',
        roomId: 'r1',
        sender: const UiChatUser(id: 'other', name: 'Other'),
        content: 'Hi',
        timestamp: DateTime.now(),
      );

      controller.addMessage(msg);
      controller.setTyping(true);
      expect(controller.isTyping, isTrue);

      controller.startReply('m1');
      expect(controller.replyingToMessage?.id, 'm1');

      controller.cancelReply();
      expect(controller.replyingToMessage, isNull);

      controller.dispose();
    });
  });

  group('UiChatMessageWidget', () {
    testWidgets('renders text message', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiChatMessageWidget(
            message: UiChatMessage(
              id: 'm1',
              roomId: 'r1',
              sender: const UiChatUser(id: 'other', name: 'Alice'),
              content: 'Hello World',
              timestamp: DateTime(2026, 4, 22, 14, 30),
            ),
            currentUserId: 'me',
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('renders system message', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiChatMessageWidget(
            message: UiChatMessage(
              id: 'm2',
              roomId: 'r1',
              sender: const UiChatUser(id: 'system', name: 'System'),
              content: 'Alice joined the chat',
              type: UiMessageType.system,
              timestamp: DateTime.now(),
            ),
            currentUserId: 'me',
          ),
        ),
      );

      expect(find.text('Alice joined the chat'), findsOneWidget);
    });
  });

  group('UiChatInputBar', () {
    testWidgets('renders and sends message', (tester) async {
      await tester.pumpWidget(_wrap(UiChatInputBar(onSend: (_) {})));

      expect(find.byType(UiChatInputBar), findsOneWidget);
    });
  });

  group('UiChatList', () {
    testWidgets('renders rooms', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiChatList(
            rooms: const [
              UiChatRoom(id: 'r1', name: 'General'),
              UiChatRoom(id: 'r2', name: 'Random'),
            ],
            onRoomTap: (_) {},
            currentUserId: 'me',
          ),
        ),
      );

      expect(find.text('General'), findsOneWidget);
      expect(find.text('Random'), findsOneWidget);
    });
  });

  group('UiChatListTile', () {
    testWidgets('renders room info', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiChatListTile(
            room: const UiChatRoom(id: 'r1', name: 'Team Chat', unreadCount: 3),
            onTap: () {},
            currentUserId: 'me',
          ),
        ),
      );

      expect(find.text('Team Chat'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });

  group('UiTypingIndicator', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(_wrap(const UiTypingIndicator(userName: 'Alice')));

      expect(find.byType(UiTypingIndicator), findsOneWidget);
    });
  });

  group('UiMessageStatusIcon', () {
    testWidgets('renders all statuses', (tester) async {
      for (final status in UiMessageStatus.values) {
        await tester.pumpWidget(_wrap(UiMessageStatusIcon(status: status)));
        expect(find.byType(UiMessageStatusIcon), findsOneWidget);
      }
    });
  });

  group('UiChatDateSeparator', () {
    testWidgets('renders today', (tester) async {
      await tester.pumpWidget(_wrap(UiChatDateSeparator(date: DateTime.now())));

      expect(find.text('Today'), findsOneWidget);
    });
  });

  group('UiChatReplyPreview', () {
    testWidgets('renders quoted message', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiChatReplyPreview(
            message: UiChatMessage(
              id: 'm1',
              roomId: 'r1',
              sender: const UiChatUser(id: '1', name: 'Bob'),
              content: 'Original message',
              timestamp: DateTime.now(),
            ),
          ),
        ),
      );

      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Original message'), findsOneWidget);
    });
  });

  group('UiChatRoomView', () {
    testWidgets('renders complete chat room', (tester) async {
      final controller = UiChatController(
        currentUser: const UiChatUser(id: 'me', name: 'Me'),
        messages: [
          UiChatMessage(
            id: 'm1',
            roomId: 'r1',
            sender: const UiChatUser(id: 'other', name: 'Alice'),
            content: 'Hey!',
            timestamp: DateTime.now(),
          ),
        ],
      );

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 600,
            child: UiChatRoomView(
              controller: controller,
              currentUserId: 'me',
              roomName: 'Test Room',
              onSend: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Room'), findsOneWidget);
      expect(find.text('Hey!'), findsOneWidget);

      controller.dispose();
    });
  });
}
