import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_cart_controller.dart';
import 'ui_cart_item_tile.dart';
import 'ui_cart_summary.dart';

/// A full cart screen built around a [UiCartController].
///
/// Rebuilds automatically when the controller changes via [ListenableBuilder].
/// Shows an empty state when the cart is empty.
///
/// ```dart
/// UiCartScreen(
///   controller: cartController,
///   onCheckout: () => navigateToCheckout(),
///   onContinueShopping: () => navigateToShop(),
/// )
/// ```
class UiCartScreen extends StatelessWidget {
  const UiCartScreen({
    super.key,
    required this.controller,
    this.onCheckout,
    this.onContinueShopping,
  });

  /// The cart controller to observe.
  final UiCartController controller;

  /// Called when the checkout button is tapped.
  final VoidCallback? onCheckout;

  /// Called when the "continue shopping" action is tapped.
  final VoidCallback? onContinueShopping;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isEmpty) {
          return _EmptyCart(
            onContinueShopping: onContinueShopping,
          );
        }

        final theme = UiTheme.of(context);
        final spacing = theme.spacing;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cart items
            Expanded(
              child: SingleChildScrollView(
                padding: spacing.paddingMd,
                child: Column(
                  children: [
                    for (int i = 0; i < controller.items.length; i++) ...[
                      if (i > 0) SizedBox(height: spacing.sm),
                      UiCartItemTile(
                        item: controller.items[i],
                        currency: controller.currency,
                        onQuantityChanged: (qty) => controller.updateQuantity(
                          controller.items[i].product.id,
                          qty,
                        ),
                        onRemove: () => controller.removeItem(
                          controller.items[i].product.id,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Summary
            Padding(
              padding: spacing.paddingMd,
              child: UiCartSummary(
                subtotal: controller.subtotal,
                shipping: controller.shipping,
                tax: controller.tax,
                total: controller.total,
                currency: controller.currency,
                itemCount: controller.itemCount,
                onCheckout: onCheckout,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({this.onContinueShopping});

  final VoidCallback? onContinueShopping;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            const IconData(0xe854,
                fontFamily: 'MaterialIcons'), // shopping_cart
            size: 64,
            color: colors.onSurface.withValues(alpha: 0.2),
          ),
          SizedBox(height: spacing.md),
          Text(
            'Your cart is empty',
            style: typo.titleMedium.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: spacing.lg),
          if (onContinueShopping != null)
            GestureDetector(
              onTap: onContinueShopping,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.lg,
                    vertical: spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: spacing.radiusMd,
                  ),
                  child: Text(
                    'Continue Shopping',
                    style: typo.labelLarge.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
