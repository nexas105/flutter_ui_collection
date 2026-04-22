import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed horizontal divider.
///
/// Adapts color and style to the active theme.
class UiDivider extends StatelessWidget {
  const UiDivider({
    super.key,
    this.thickness,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
    this.label,
  });

  final double? thickness;
  final Color? color;
  final double indent;
  final double endIndent;

  /// Optional centered label (e.g. "OR").
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final lineColor = color ?? colors.border;
    final lineThickness = thickness ?? theme.borderWidth;

    if (label != null) {
      return Row(
        children: [
          SizedBox(width: indent),
          Expanded(child: Container(height: lineThickness, color: lineColor)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.sm),
            child: Text(
              label!,
              style: typo.labelSmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(child: Container(height: lineThickness, color: lineColor)),
          SizedBox(width: endIndent),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: indent, right: endIndent),
      child: Container(height: lineThickness, color: lineColor),
    );
  }
}
