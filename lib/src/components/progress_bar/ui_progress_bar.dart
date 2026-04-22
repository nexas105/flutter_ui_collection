import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed progress bar.
///
/// ```dart
/// UiProgressBar(value: 0.65)
/// ```
class UiProgressBar extends StatelessWidget {
  const UiProgressBar({
    super.key,
    required this.value,
    this.height = 8.0,
    this.showLabel = false,
    this.color,
    this.trackColor,
  });

  /// Progress value between 0.0 and 1.0.
  final double value;
  final double height;
  final bool showLabel;
  final Color? color;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final clampedValue = value.clamp(0.0, 1.0);
    final barColor = color ?? colors.primary;
    final bgColor = trackColor ?? colors.border;

    final gradient = theme.useGradients && colors.gradient != null
        ? LinearGradient(colors: colors.gradient!)
        : null;

    List<BoxShadow>? glow;
    if (theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.3),
          blurRadius: 8,
        ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Text(
            '${(clampedValue * 100).round()}%',
            style: typo.labelSmall.copyWith(color: colors.onBackground),
          ),
          SizedBox(height: spacing.xs),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              children: [
                // Track
                Container(
                  decoration: BoxDecoration(color: bgColor),
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: clampedValue,
                  child: Container(
                    decoration: BoxDecoration(
                      color: gradient == null ? barColor : null,
                      gradient: gradient,
                      boxShadow: glow,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
