import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Displays a product price with optional original price strikethrough
/// and discount percentage badge.
///
/// ```dart
/// UiPriceDisplay(
///   price: 29.99,
///   originalPrice: 49.99,
///   currency: '\$',
/// )
/// ```
class UiPriceDisplay extends StatelessWidget {
  const UiPriceDisplay({
    super.key,
    required this.price,
    this.originalPrice,
    this.currency = '\$',
    this.large = false,
  });

  /// The current / sale price.
  final double price;

  /// Original price before discount. Shows with strikethrough when set.
  final double? originalPrice;

  /// Currency symbol to prepend. Defaults to `\$`.
  final String currency;

  /// If true, renders with larger text styles.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final typo = theme.typography;
    final spacing = theme.spacing;

    final hasDiscount = originalPrice != null && originalPrice! > price;
    final priceStyle = (large ? typo.headlineSmall : typo.titleMedium).copyWith(
      color: hasDiscount ? colors.error : colors.onSurface,
      fontWeight: FontWeight.w700,
    );
    final originalStyle = (large ? typo.bodyLarge : typo.bodySmall).copyWith(
      color: colors.resolvedOnSurfaceSubtle,
      decoration: TextDecoration.lineThrough,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$currency${price.toStringAsFixed(2)}', style: priceStyle),
        if (hasDiscount) ...[
          SizedBox(width: spacing.xs),
          Text(
            '$currency${originalPrice!.toStringAsFixed(2)}',
            style: originalStyle,
          ),
          SizedBox(width: spacing.xs),
          _DiscountBadge(
            percentage: ((originalPrice! - price) / originalPrice! * 100)
                .round(),
            theme: theme,
          ),
        ],
      ],
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percentage, required this.theme});

  final int percentage;
  final dynamic theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final typo = theme.typography;
    final spacing = theme.spacing;

    final glow = theme.surfaceShadows(accent: colors.error as Color);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing.xs + 2, vertical: 2),
      decoration: BoxDecoration(
        color: colors.error,
        borderRadius: spacing.radiusSm,
        boxShadow: glow,
      ),
      child: Text(
        '-$percentage%',
        style: (typo.labelSmall as TextStyle).copyWith(color: colors.onError),
      ),
    );
  }
}
