// ignore_for_file: unused_local_variable

import 'package:flutter/widgets.dart';
import 'package:flutter_ui_collection/flutter_ui_collection.dart';

/// Example: Neon-themed app with various UI components.
///
/// Run this example to see how flutter_ui_collection works
/// with different design presets.
void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  /// Available themes to cycle through.
  static final themes = [
    NeonTheme.dark,
    NeonTheme.light,
    GlassTheme.dark,
    GlassTheme.light,
    MinimalTheme.dark,
    MinimalTheme.light,
    CyberpunkTheme.dark,
    CyberpunkTheme.light,
  ];

  int _themeIndex = 0;
  bool _toggleValue = false;

  void _nextTheme() {
    setState(() {
      _themeIndex = (_themeIndex + 1) % themes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = themes[_themeIndex];

    return Directionality(
      textDirection: TextDirection.ltr,
      child: UiTheme(
        data: theme,
        child: Builder(
          builder: (context) {
            final t = context.uiTheme;
            return ColoredBox(
              color: t.colorScheme.background,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: t.spacing.paddingMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Bar
                      UiAppBar(
                        title: Text('Flutter UI Collection',
                            style: t.typography.titleMedium),
                        actions: [
                          GestureDetector(
                            onTap: _nextTheme,
                            child: Text('Theme: ${t.name}',
                                style: t.typography.labelSmall
                                    .copyWith(color: t.colorScheme.primary)),
                          ),
                        ],
                      ),
                      SizedBox(height: t.spacing.lg),

                      // Buttons
                      Text('Buttons', style: t.typography.headlineSmall),
                      SizedBox(height: t.spacing.sm),
                      Wrap(
                        spacing: t.spacing.sm,
                        runSpacing: t.spacing.sm,
                        children: [
                          UiButton(
                            label: 'Filled',
                            onPressed: () {},
                          ),
                          UiButton(
                            label: 'Outlined',
                            variant: UiButtonVariant.outlined,
                            onPressed: () {},
                          ),
                          UiButton(
                            label: 'Ghost',
                            variant: UiButtonVariant.ghost,
                            onPressed: () {},
                          ),
                          UiButton(
                            label: 'Glow',
                            variant: UiButtonVariant.glow,
                            onPressed: () {},
                          ),
                          const UiButton(label: 'Disabled'),
                        ],
                      ),
                      SizedBox(height: t.spacing.lg),

                      // Cards
                      Text('Cards', style: t.typography.headlineSmall),
                      SizedBox(height: t.spacing.sm),
                      UiCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Standard Card',
                                style: t.typography.titleMedium),
                            SizedBox(height: t.spacing.xs),
                            Text(
                              'This card adapts to the active theme '
                              'automatically.',
                              style: t.typography.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: t.spacing.sm),
                      UiCard(
                        blur: true,
                        child: Text('Glass Card (blur)',
                            style: t.typography.bodyMedium),
                      ),
                      SizedBox(height: t.spacing.lg),

                      // Badges
                      Text('Badges', style: t.typography.headlineSmall),
                      SizedBox(height: t.spacing.sm),
                      Wrap(
                        spacing: t.spacing.sm,
                        runSpacing: t.spacing.sm,
                        children: const [
                          UiBadge(label: 'PRIMARY'),
                          UiBadge(
                              label: 'SUCCESS',
                              type: UiBadgeType.success),
                          UiBadge(
                              label: 'WARNING',
                              type: UiBadgeType.warning),
                          UiBadge(
                              label: 'ERROR', type: UiBadgeType.error),
                          UiBadge(
                              label: 'OUTLINED',
                              type: UiBadgeType.secondary,
                              outlined: true),
                        ],
                      ),
                      SizedBox(height: t.spacing.lg),

                      // Toggle
                      Text('Toggle', style: t.typography.headlineSmall),
                      SizedBox(height: t.spacing.sm),
                      Row(
                        children: [
                          UiToggle(
                            value: _toggleValue,
                            onChanged: (v) =>
                                setState(() => _toggleValue = v),
                          ),
                          SizedBox(width: t.spacing.sm),
                          Text(
                            _toggleValue ? 'ON' : 'OFF',
                            style: t.typography.labelMedium,
                          ),
                        ],
                      ),
                      SizedBox(height: t.spacing.lg),

                      // Chips
                      Text('Chips', style: t.typography.headlineSmall),
                      SizedBox(height: t.spacing.sm),
                      Wrap(
                        spacing: t.spacing.sm,
                        children: [
                          const UiChip(label: 'Flutter'),
                          const UiChip(
                              label: 'Selected', selected: true),
                          UiChip(
                              label: 'Deletable',
                              onDelete: () {}),
                        ],
                      ),
                      SizedBox(height: t.spacing.lg),

                      // Avatars
                      Text('Avatars', style: t.typography.headlineSmall),
                      SizedBox(height: t.spacing.sm),
                      Row(
                        children: [
                          const UiAvatar(
                              initials: 'TL',
                              size: UiAvatarSize.small),
                          SizedBox(width: t.spacing.sm),
                          const UiAvatar(initials: 'AB'),
                          SizedBox(width: t.spacing.sm),
                          const UiAvatar(
                              initials: 'XY',
                              size: UiAvatarSize.large),
                        ],
                      ),
                      SizedBox(height: t.spacing.lg),

                      // Progress
                      Text('Progress', style: t.typography.headlineSmall),
                      SizedBox(height: t.spacing.sm),
                      const UiProgressBar(value: 0.7, showLabel: true),
                      SizedBox(height: t.spacing.sm),
                      const UiProgressBar(value: 0.35),
                      SizedBox(height: t.spacing.lg),

                      // Divider
                      Text('Divider', style: t.typography.headlineSmall),
                      SizedBox(height: t.spacing.sm),
                      const UiDivider(),
                      SizedBox(height: t.spacing.sm),
                      const UiDivider(label: 'OR'),
                      SizedBox(height: t.spacing.lg),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
