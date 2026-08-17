import 'package:flutter/widgets.dart';

import '../icons/ui_icons.dart';
import '../theme/ui_theme.dart';
import 'ui_ecommerce_models.dart';

/// A cart item row showing product thumbnail, name, quantity controls,
/// price, and a remove button.
///
/// ```dart
/// UiCartItemTile(
///   item: cartItem,
///   onQuantityChanged: (qty) => updateQuantity(cartItem, qty),
///   onRemove: () => removeFromCart(cartItem),
/// )
/// ```
class UiCartItemTile extends StatelessWidget {
  const UiCartItemTile({
    super.key,
    required this.item,
    this.onQuantityChanged,
    this.onRemove,
    this.currency = '\$',
  });

  final UiCartItem item;
  final ValueChanged<int>? onQuantityChanged;
  final VoidCallback? onRemove;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;
    final product = item.product;
    final effectivePrice = product.salePrice ?? product.price;

    return Container(
      padding: spacing.paddingMd,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: spacing.radiusMd,
        border: Border.all(color: colors.border, width: theme.borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: spacing.radiusSm,
            child: Container(
              width: 64,
              height: 64,
              color: colors.resolvedBorderSubtle,
              child: Icon(
                UiIcons.image,
                size: 28,
                color: colors.onSurface.withValues(
                  alpha: theme.components.strongTintOpacity,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing.md),
          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: typo.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.xs),
                Text(
                  '$currency${(effectivePrice * item.quantity).toStringAsFixed(2)}',
                  style: typo.bodyMedium.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          // Quantity selector
          _QuantitySelector(
            quantity: item.quantity,
            onChanged: onQuantityChanged,
            theme: theme,
          ),
          SizedBox(width: spacing.sm),
          // Remove button
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: EdgeInsets.all(spacing.xs),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(
                      alpha: theme.components.tintOpacity,
                    ),
                    borderRadius: spacing.radiusSm,
                  ),
                  child: Icon(UiIcons.delete, size: 18, color: colors.error),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onChanged,
    required this.theme,
  });

  final int quantity;
  final ValueChanged<int>? onChanged;
  final dynamic theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border, width: theme.borderWidth),
        borderRadius: spacing.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: UiIcons.remove,
            enabled: quantity > 1 && onChanged != null,
            onTap: () => onChanged?.call(quantity - 1),
            theme: theme,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: spacing.xs),
            child: Text(
              '$quantity',
              style: (typo.bodyMedium as TextStyle).copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _QuantityButton(
            icon: UiIcons.add,
            enabled: onChanged != null,
            onTap: () => onChanged?.call(quantity + 1),
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final dynamic theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled
                ? (colors.surface as Color)
                : (colors.border as Color).withValues(
                    alpha: theme.components.strongTintOpacity,
                  ),
            borderRadius: spacing.radiusSm,
          ),
          child: Icon(
            icon,
            size: 16,
            color: enabled ? colors.onSurface : colors.resolvedOnSurfaceSubtle,
          ),
        ),
      ),
    );
  }
}
