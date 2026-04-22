import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_collection/flutter_ui_collection.dart';

/// Wraps a widget with [UiTheme] and [Directionality] for testing.
Widget _wrap(Widget child, {UiThemeData? theme}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: UiTheme(
      data: theme ?? NeonTheme.dark,
      child: child,
    ),
  );
}

void main() {
  group('UiTheme', () {
    testWidgets('provides theme data to descendants', (tester) async {
      late UiThemeData resolved;

      await tester.pumpWidget(
        _wrap(
          Builder(builder: (context) {
            resolved = UiTheme.of(context);
            return const SizedBox();
          }),
        ),
      );

      expect(resolved.name, 'Neon Dark');
    });

    testWidgets('maybeOf returns null without ancestor', (tester) async {
      UiThemeData? resolved;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(builder: (context) {
            resolved = UiTheme.maybeOf(context);
            return const SizedBox();
          }),
        ),
      );

      expect(resolved, isNull);
    });

    testWidgets('context extension works', (tester) async {
      late UiThemeData resolved;

      await tester.pumpWidget(
        _wrap(
          Builder(builder: (context) {
            resolved = context.uiTheme;
            return const SizedBox();
          }),
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
      final typo = UiTypography.fromFont(
        fontFamily: 'TestFont',
        color: const Color(0xFFFFFFFF),
      );

      expect(typo.displayLarge.fontFamily, 'TestFont');
      expect(typo.bodyMedium.color, const Color(0xFFFFFFFF));
      expect(typo.labelSmall.fontWeight, FontWeight.w600);
    });

    test('apply overrides color and fontFamily', () {
      final typo = UiTypography.fromFont(
        fontFamily: 'Original',
        color: const Color(0xFFFFFFFF),
      );
      final applied = typo.apply(
        color: const Color(0xFF000000),
        fontFamily: 'NewFont',
      );

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
      await tester.pumpWidget(_wrap(
        UiButton(label: 'Click me', onPressed: () {}),
      ));

      expect(find.text('Click me'), findsOneWidget);
    });

    testWidgets('calls onPressed on tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        UiButton(label: 'Tap', onPressed: () => tapped = true),
      ));

      await tester.tap(find.text('Tap'));
      expect(tapped, isTrue);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const UiButton(label: 'Disabled'),
      ));

      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('renders all variants without error', (tester) async {
      for (final variant in UiButtonVariant.values) {
        await tester.pumpWidget(_wrap(
          UiButton(
            label: variant.name,
            variant: variant,
            onPressed: () {},
          ),
        ));
        expect(find.text(variant.name), findsOneWidget);
      }
    });

    testWidgets('adapts to different themes', (tester) async {
      for (final theme in [NeonTheme.dark, GlassTheme.dark, MinimalTheme.dark, CyberpunkTheme.dark]) {
        await tester.pumpWidget(_wrap(
          UiButton(label: 'Themed', onPressed: () {}),
          theme: theme,
        ));
        expect(find.text('Themed'), findsOneWidget);
      }
    });
  });

  group('UiCard', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(_wrap(
        const UiCard(child: Text('Card Content')),
      ));

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('handles tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        UiCard(onTap: () => tapped = true, child: const Text('Tap Card')),
      ));

      await tester.tap(find.text('Tap Card'));
      expect(tapped, isTrue);
    });
  });

  group('UiBadge', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_wrap(
        const UiBadge(label: 'NEW'),
      ));

      expect(find.text('NEW'), findsOneWidget);
    });

    testWidgets('renders all types', (tester) async {
      for (final type in UiBadgeType.values) {
        await tester.pumpWidget(_wrap(
          UiBadge(label: type.name, type: type),
        ));
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
            return _wrap(
              UiToggle(
                value: value,
                onChanged: (v) => setState(() => value = v),
              ),
            );
          },
        ),
      );

      await tester.tap(find.byType(UiToggle));
      await tester.pump();
      expect(value, isTrue);
    });
  });

  group('UiChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_wrap(
        const UiChip(label: 'Flutter'),
      ));

      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('handles tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        UiChip(label: 'Chip', onTap: () => tapped = true),
      ));

      await tester.tap(find.text('Chip'));
      expect(tapped, isTrue);
    });
  });

  group('UiAvatar', () {
    testWidgets('renders initials', (tester) async {
      await tester.pumpWidget(_wrap(
        const UiAvatar(initials: 'TL'),
      ));

      expect(find.text('TL'), findsOneWidget);
    });

    testWidgets('all sizes render', (tester) async {
      for (final size in UiAvatarSize.values) {
        await tester.pumpWidget(_wrap(
          UiAvatar(initials: 'A', size: size),
        ));
        expect(find.text('A'), findsOneWidget);
      }
    });
  });

  group('UiProgressBar', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const UiProgressBar(value: 0.5),
      ));

      expect(find.byType(UiProgressBar), findsOneWidget);
    });

    testWidgets('shows label when enabled', (tester) async {
      await tester.pumpWidget(_wrap(
        const UiProgressBar(value: 0.75, showLabel: true),
      ));

      expect(find.text('75%'), findsOneWidget);
    });
  });

  group('UiDivider', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const UiDivider(),
      ));

      expect(find.byType(UiDivider), findsOneWidget);
    });

    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(_wrap(
        const UiDivider(label: 'OR'),
      ));

      expect(find.text('OR'), findsOneWidget);
    });
  });

  group('UiAppBar', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(_wrap(
        const UiAppBar(title: Text('My App')),
      ));

      expect(find.text('My App'), findsOneWidget);
    });

    testWidgets('renders actions', (tester) async {
      await tester.pumpWidget(_wrap(
        const UiAppBar(
          title: Text('App'),
          actions: [Text('A1'), Text('A2')],
        ),
      ));

      expect(find.text('A1'), findsOneWidget);
      expect(find.text('A2'), findsOneWidget);
    });
  });
}
