import 'package:flutter/widgets.dart';

import '../icons/ui_icons.dart';
import '../theme/ui_theme.dart';
import 'ui_ecommerce_models.dart';
import 'ui_price_display.dart';

/// A themed product card for catalog display.
///
/// Shows product image, name, price, rating, and an add-to-cart action.
/// Supports a compact layout and hover scale effect.
///
/// ```dart
/// UiProductCard(
///   product: myProduct,
///   onTap: () => navigateToDetail(myProduct),
///   onAddToCart: () => cart.add(myProduct),
/// )
/// ```
class UiProductCard extends StatefulWidget {
  const UiProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.imageHeight = 180.0,
    this.compact = false,
  });

  final UiProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final double imageHeight;
  final bool compact;

  @override
  State<UiProductCard> createState() => _UiProductCardState();
}

class _UiProductCardState extends State<UiProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final product = widget.product;
    final hasSale =
        product.salePrice != null && product.salePrice! < product.price;

    List<BoxShadow>? shadows;
    if (theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: _hovered ? 0.25 : 0.1),
          blurRadius: _hovered ? 20 : 12,
          spreadRadius: 1,
        ),
      ];
    } else if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.shadow,
          blurRadius: _hovered ? 16 : 8,
          offset: const Offset(0, 4),
        ),
      ];
    }

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: spacing.radiusMd,
              border: Border.all(
                color: _hovered ? colors.primary : colors.border,
                width: theme.borderWidth,
              ),
              boxShadow: shadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image area with badge overlay
                _ImageArea(
                  product: product,
                  height: widget.imageHeight,
                  hasSale: hasSale,
                  theme: theme,
                ),
                // Content
                Padding(
                  padding: EdgeInsets.all(
                    widget.compact ? spacing.sm : spacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        product.name,
                        style:
                            (widget.compact ? typo.bodySmall : typo.titleSmall)
                                .copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: spacing.xs),
                      // Price
                      UiPriceDisplay(
                        price: hasSale ? product.salePrice! : product.price,
                        originalPrice: hasSale ? product.price : null,
                      ),
                      if (!widget.compact) ...[
                        SizedBox(height: spacing.xs),
                        // Rating row
                        _RatingRow(
                          rating: product.rating,
                          reviewCount: product.reviewCount,
                          theme: theme,
                        ),
                        SizedBox(height: spacing.sm),
                        // Add to cart button
                        if (widget.onAddToCart != null)
                          _AddToCartButton(
                            inStock: product.inStock,
                            onTap: product.inStock ? widget.onAddToCart : null,
                            theme: theme,
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageArea extends StatelessWidget {
  const _ImageArea({
    required this.product,
    required this.height,
    required this.hasSale,
    required this.theme,
  });

  final UiProduct product;
  final double height;
  final bool hasSale;
  final dynamic theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(spacing.borderRadiusMd),
        topRight: Radius.circular(spacing.borderRadiusMd),
      ),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder background
            Container(
              color: (colors.border as Color).withValues(alpha: 0.3),
              child: Center(
                child: Icon(
                  UiIcons.image,
                  size: 48,
                  color: (colors.onSurface as Color).withValues(alpha: 0.2),
                ),
              ),
            ),
            // Sale badge
            if (hasSale)
              Positioned(
                top: spacing.sm,
                left: spacing.sm,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.error,
                    borderRadius: spacing.radiusSm,
                  ),
                  child: Text(
                    'SALE',
                    style: (typo.labelSmall as TextStyle).copyWith(
                      color: colors.onError,
                    ),
                  ),
                ),
              ),
            // Additional badges
            if (product.badges.isNotEmpty)
              Positioned(
                top: spacing.sm,
                right: spacing.sm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final badge in product.badges)
                      Padding(
                        padding: EdgeInsets.only(bottom: spacing.xs),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.sm,
                            vertical: spacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: spacing.radiusSm,
                          ),
                          child: Text(
                            badge,
                            style: (typo.labelSmall as TextStyle).copyWith(
                              color: colors.onPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            // Out of stock overlay
            if (!product.inStock)
              Container(
                color: (colors.background as Color).withValues(alpha: 0.6),
                child: Center(
                  child: Text(
                    'Out of Stock',
                    style: (typo.titleSmall as TextStyle).copyWith(
                      color: colors.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({
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
        // Small inline stars
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(right: 1),
            child: Icon(
              i < rating ? UiIcons.star : UiIcons.starBorder,
              size: 14,
              color: i < rating ? colors.warning : colors.border,
            ),
          ),
        const SizedBox(width: 4),
        Text(
          '($reviewCount)',
          style: (typo.bodySmall as TextStyle).copyWith(
            color: (colors.onSurface as Color).withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _AddToCartButton extends StatefulWidget {
  const _AddToCartButton({
    required this.inStock,
    required this.onTap,
    required this.theme,
  });

  final bool inStock;
  final VoidCallback? onTap;
  final dynamic theme;

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final enabled = widget.inStock && widget.onTap != null;
    final bgColor = enabled ? colors.primary : (colors.border as Color);

    List<BoxShadow>? glow;
    if (enabled && theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(
          color: (colors.primary as Color).withValues(alpha: 0.3),
          blurRadius: 8,
        ),
      ];
    }

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
          padding: EdgeInsets.symmetric(vertical: spacing.sm),
          decoration: BoxDecoration(
            color: _pressed
                ? (bgColor as Color).withValues(alpha: 0.8)
                : bgColor,
            borderRadius: spacing.radiusSm,
            boxShadow: glow,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                UiIcons.cart,
                size: 16,
                color: enabled ? colors.onPrimary : colors.onSurface,
              ),
              SizedBox(width: spacing.xs),
              Text(
                enabled ? 'Add to Cart' : 'Unavailable',
                style: (typo.labelMedium as TextStyle).copyWith(
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
