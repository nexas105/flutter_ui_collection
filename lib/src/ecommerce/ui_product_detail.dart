import 'package:flutter/widgets.dart';

import '../icons/ui_icons.dart';
import '../theme/ui_theme.dart';
import 'ui_ecommerce_models.dart';
import 'ui_price_display.dart';
import 'ui_product_badge.dart';

/// A full product detail page.
///
/// Displays the product image area, badges, name, price, rating,
/// description, and an add-to-cart button in a scrollable layout.
///
/// ```dart
/// UiProductDetail(
///   product: myProduct,
///   onAddToCart: () => cart.addItem(myProduct),
///   onBack: () => Navigator.pop(context),
/// )
/// ```
class UiProductDetail extends StatelessWidget {
  const UiProductDetail({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onBack,
  });

  /// The product to display.
  final UiProduct product;

  /// Called when the user taps the add-to-cart button.
  final VoidCallback? onAddToCart;

  /// Called when the user taps the back action.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;
    final hasSale =
        product.salePrice != null && product.salePrice! < product.price;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(spacing.sm),
                child: GestureDetector(
                  onTap: onBack,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      padding: EdgeInsets.all(spacing.sm),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: spacing.radiusFull,
                        border: Border.all(
                          color: colors.border,
                          width: theme.borderWidth,
                        ),
                      ),
                      child: Icon(
                        UiIcons.arrowBack,
                        size: 20,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Image area
          Container(
            height: 300,
            color: colors.surface,
            child: Center(
              child: Text(
                product.name,
                style: typo.titleLarge.copyWith(
                  color: colors.resolvedOnSurfaceSubtle,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Padding(
            padding: spacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges row
                if (product.badges.isNotEmpty || hasSale) ...[
                  Wrap(
                    spacing: spacing.sm,
                    runSpacing: spacing.xs,
                    children: [
                      if (hasSale)
                        const UiProductBadge(type: UiProductBadgeType.sale),
                      for (final badge in product.badges)
                        UiProductBadge(
                          type: UiProductBadgeType.custom,
                          label: badge,
                        ),
                    ],
                  ),
                  SizedBox(height: spacing.md),
                ],

                // Product name
                Text(
                  product.name,
                  style: typo.headlineMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: spacing.sm),

                // Price
                UiPriceDisplay(
                  price: hasSale ? product.salePrice! : product.price,
                  originalPrice: hasSale ? product.price : null,
                  large: true,
                ),
                SizedBox(height: spacing.sm),

                // Rating stars
                _RatingStars(
                  rating: product.rating,
                  reviewCount: product.reviewCount,
                  theme: theme,
                ),
                SizedBox(height: spacing.md),

                // Description
                if (product.description.isNotEmpty)
                  Text(
                    product.description,
                    style: typo.bodyMedium.copyWith(color: colors.onSurface),
                  ),
                SizedBox(height: spacing.lg),

                // Add to Cart button
                _AddToCartFullWidth(
                  inStock: product.inStock,
                  onTap: product.inStock ? onAddToCart : null,
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({
    required this.rating,
    required this.reviewCount,
    required this.theme,
  });

  final double rating;
  final int reviewCount;
  final dynamic theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final typo = theme.typography;

    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              i < rating ? UiIcons.star : UiIcons.starBorder,
              size: 16,
              color: i < rating ? colors.warning : colors.border,
            ),
          ),
        const SizedBox(width: 6),
        Text(
          '${rating.toStringAsFixed(1)} ($reviewCount reviews)',
          style: (typo.bodySmall as TextStyle).copyWith(
            color: colors.resolvedOnSurfaceMuted,
          ),
        ),
      ],
    );
  }
}

class _AddToCartFullWidth extends StatefulWidget {
  const _AddToCartFullWidth({
    required this.inStock,
    required this.onTap,
    required this.theme,
  });

  final bool inStock;
  final VoidCallback? onTap;
  final dynamic theme;

  @override
  State<_AddToCartFullWidth> createState() => _AddToCartFullWidthState();
}

class _AddToCartFullWidthState extends State<_AddToCartFullWidth> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;
    final enabled = widget.inStock && widget.onTap != null;
    final bgColor = enabled ? colors.primary as Color : colors.border as Color;

    final glow = enabled
        ? theme.surfaceShadows(accent: colors.primary as Color)
        : null;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          padding: EdgeInsets.symmetric(vertical: spacing.md),
          decoration: BoxDecoration(
            color: _pressed ? bgColor.withValues(alpha: 0.8) : bgColor,
            borderRadius: spacing.radiusMd,
            boxShadow: glow,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                UiIcons.cart,
                size: 20,
                color: enabled ? colors.onPrimary : colors.onSurface,
              ),
              SizedBox(width: spacing.sm),
              Text(
                enabled ? 'Add to Cart' : 'Out of Stock',
                style: (typo.labelLarge as TextStyle).copyWith(
                  color: enabled ? colors.onPrimary : colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
