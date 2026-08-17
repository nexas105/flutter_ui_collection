import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_ecommerce_models.dart';
import 'ui_product_card.dart';

/// A responsive grid of [UiProductCard] widgets.
///
/// When [loading] is true, skeleton placeholders are shown instead.
///
/// ```dart
/// UiProductGrid(
///   products: catalog,
///   onProductTap: (p) => goToDetail(p),
///   onAddToCart: (p) => cart.add(p),
/// )
/// ```
class UiProductGrid extends StatelessWidget {
  const UiProductGrid({
    super.key,
    required this.products,
    this.crossAxisCount,
    this.onProductTap,
    this.onAddToCart,
    this.loading = false,
    this.skeletonCount = 6,
    this.imageHeight = 180.0,
    this.compact = false,
    this.spacing,
    this.padding,
  });

  /// Products to display. Ignored when [loading] is true.
  final List<UiProduct> products;

  /// Fixed column count. When null, auto-calculates based on available width.
  final int? crossAxisCount;

  /// Called when a product card is tapped.
  final void Function(UiProduct product)? onProductTap;

  /// Called when the add-to-cart button is pressed.
  final void Function(UiProduct product)? onAddToCart;

  /// Shows skeleton placeholders instead of products.
  final bool loading;

  /// Number of skeleton cards to show while loading.
  final int skeletonCount;

  /// Height of the image area in each card.
  final double imageHeight;

  /// Use compact card layout.
  final bool compact;

  /// Spacing between grid items. Defaults to theme spacing md.
  final double? spacing;

  /// Padding around the grid.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final themeSpacing = theme.spacing;
    final gap = spacing ?? themeSpacing.md;
    final resolvedPadding = padding ?? EdgeInsets.zero;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = crossAxisCount ?? _autoColumns(constraints.maxWidth);
        final itemCount = loading ? skeletonCount : products.length;

        if (itemCount == 0) {
          return const SizedBox.shrink();
        }

        final rows = (itemCount / cols).ceil();
        final availableWidth =
            constraints.maxWidth - resolvedPadding.horizontal;
        final itemWidth = (availableWidth - gap * (cols - 1)) / cols;

        return Padding(
          padding: resolvedPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int row = 0; row < rows; row++) ...[
                if (row > 0) SizedBox(height: gap),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int col = 0; col < cols; col++) ...[
                      if (col > 0) SizedBox(width: gap),
                      SizedBox(
                        width: itemWidth,
                        child: _buildItem(row * cols + col, itemCount),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(int index, int itemCount) {
    if (index >= itemCount) {
      return const SizedBox.shrink();
    }

    if (loading) {
      return _ProductCardSkeleton(imageHeight: imageHeight, compact: compact);
    }

    final product = products[index];
    return UiProductCard(
      product: product,
      onTap: onProductTap != null ? () => onProductTap!(product) : null,
      onAddToCart: onAddToCart != null ? () => onAddToCart!(product) : null,
      imageHeight: imageHeight,
      compact: compact,
    );
  }

  int _autoColumns(double width) {
    if (width >= 1200) return 4;
    if (width >= 800) return 3;
    if (width >= 500) return 2;
    return 1;
  }
}

/// Skeleton placeholder for a product card.
class _ProductCardSkeleton extends StatefulWidget {
  const _ProductCardSkeleton({
    required this.imageHeight,
    required this.compact,
  });

  final double imageHeight;
  final bool compact;

  @override
  State<_ProductCardSkeleton> createState() => _ProductCardSkeletonState();
}

class _ProductCardSkeletonState extends State<_ProductCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    final base = colors.surface;
    final highlight = colors.border;

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: spacing.radiusMd,
            border: Border.all(color: colors.border, width: theme.borderWidth),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image skeleton
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(spacing.borderRadiusMd),
                  topRight: Radius.circular(spacing.borderRadiusMd),
                ),
                child: Container(
                  height: widget.imageHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1.0 + 2.0 * _shimmer.value, 0),
                      end: Alignment(1.0 + 2.0 * _shimmer.value, 0),
                      colors: [base, highlight, base],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(
                  widget.compact ? spacing.sm : spacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title skeleton
                    _shimmerBox(base, highlight, double.infinity, 16, spacing),
                    SizedBox(height: spacing.sm),
                    // Price skeleton
                    _shimmerBox(base, highlight, 80, 14, spacing),
                    if (!widget.compact) ...[
                      SizedBox(height: spacing.sm),
                      // Rating skeleton
                      _shimmerBox(base, highlight, 100, 12, spacing),
                      SizedBox(height: spacing.sm),
                      // Button skeleton
                      _shimmerBox(
                        base,
                        highlight,
                        double.infinity,
                        36,
                        spacing,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(
    Color base,
    Color highlight,
    double width,
    double height,
    dynamic spacing,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: spacing.radiusSm,
        gradient: LinearGradient(
          begin: Alignment(-1.0 + 2.0 * _shimmer.value, 0),
          end: Alignment(1.0 + 2.0 * _shimmer.value, 0),
          colors: [base, highlight, base],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
