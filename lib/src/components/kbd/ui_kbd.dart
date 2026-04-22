import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Displays a keyboard shortcut as styled key caps.
///
/// ```dart
/// UiKbd(keys: ['Ctrl', 'K'])
/// UiKbd(keys: ['⌘', 'Shift', 'P'])
/// ```
class UiKbd extends StatelessWidget {
  const UiKbd({
    super.key,
    required this.keys,
    this.separator = '+',
  });

  /// The key labels to display (e.g. `['Ctrl', 'K']`).
  final List<String> keys;

  /// Text shown between key caps. Defaults to `'+'`.
  final String separator;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final keyStyle = typo.labelSmall.copyWith(
      color: colors.onSurface,
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Courier New', 'Courier'],
    );

    final separatorStyle = typo.labelSmall.copyWith(
      color: colors.onSurface.withValues(alpha: 0.5),
    );

    List<BoxShadow>? glow;
    if (theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.15),
          blurRadius: 4,
        ),
      ];
    }

    final children = <Widget>[];
    for (var i = 0; i < keys.length; i++) {
      if (i > 0) {
        children.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.xs),
          child: Text(separator, style: separatorStyle),
        ));
      }
      children.add(
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.xs / 2,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: spacing.radiusSm,
            border: Border.all(color: colors.border, width: theme.borderWidth),
            boxShadow: glow ??
                (theme.useShadows
                    ? [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.15),
                          offset: const Offset(0, 1),
                          blurRadius: 1,
                        ),
                      ]
                    : null),
          ),
          child: Text(keys[i], style: keyStyle),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
