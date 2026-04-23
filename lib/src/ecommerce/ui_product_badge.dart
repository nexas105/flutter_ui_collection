import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// The position of a [UiProductBadge] when used as an overlay.
enum UiProductBadgePosition { topLeft, topRight }

/// Built-in badge types with default labels and colors.
enum UiProductBadgeType { sale, newItem, bestseller, outOfStock, custom }

/// A pill-shaped product badge with a label and themed color.
///
/// ```dart
/// UiProductBadge(type: UiProductBadgeType.sale)
/// UiProductBadge(type: UiProductBadgeType.custom, label: 'Limited')
/// ```
class UiProductBadge extends StatelessWidget {
  const UiProductBadge({
    super.key,
    required this.type,
    this.label,
    this.position = UiProductBadgePosition.topLeft,
  });

  /// Badge type. Determines default label and color.
  final UiProductBadgeType type;

  /// Optional label override. When null, uses the default for [type].
  final String? label;

  /// Where the badge should sit when used as an overlay.
  final UiProductBadgePosition position;

  String get _defaultLabel {
    switch (type) {
      case UiProductBadgeType.sale:
        return 'SALE';
      case UiProductBadgeType.newItem:
        return 'NEW';
      case UiProductBadgeType.bestseller:
        return 'BESTSELLER';
      case UiProductBadgeType.outOfStock:
        return 'OUT OF STOCK';
      case UiProductBadgeType.custom:
        return label ?? '';
    }
  }

  Color _resolveColor(UiTheme? themeWidget, BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    switch (type) {
      case UiProductBadgeType.sale:
        return colors.error;
      case UiProductBadgeType.newItem:
        return colors.primary;
      case UiProductBadgeType.bestseller:
        return colors.warning;
      case UiProductBadgeType.outOfStock:
        return colors.border;
      case UiProductBadgeType.custom:
        return colors.secondary;
    }
  }

  Color _resolveOnColor(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    switch (type) {
      case UiProductBadgeType.sale:
        return colors.onError;
      case UiProductBadgeType.newItem:
        return colors.onPrimary;
      case UiProductBadgeType.bestseller:
        return colors.onWarning;
      case UiProductBadgeType.outOfStock:
        return colors.onSurface;
      case UiProductBadgeType.custom:
        return colors.onSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final spacing = theme.spacing;
    final typo = theme.typography;
    final bgColor = _resolveColor(null, context);
    final fgColor = _resolveOnColor(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: spacing.radiusFull,
      ),
      child: Text(
        label ?? _defaultLabel,
        style: typo.labelSmall.copyWith(
          color: fgColor,
          height: 1.0,
        ),
      ),
    );
  }
}
