import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A cart summary widget showing subtotal, shipping, tax, and total,
/// with a checkout button.
///
/// ```dart
/// UiCartSummary(
///   subtotal: 89.97,
///   shipping: 5.99,
///   tax: 7.20,
///   total: 103.16,
///   itemCount: 3,
///   onCheckout: () => navigateToCheckout(),
/// )
/// ```
class UiCartSummary extends StatelessWidget {
  const UiCartSummary({
    super.key,
    required this.subtotal,
    this.shipping,
    this.tax,
    required this.total,
    this.currency = '\$',
    this.onCheckout,
    this.itemCount,
  });

  final double subtotal;
  final double? shipping;
  final double? tax;
  final double total;
  final String currency;
  final VoidCallback? onCheckout;
  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final shadows = theme.surfaceShadows();

    return Container(
      padding: spacing.paddingMd,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: spacing.radiusMd,
        border: Border.all(color: colors.border, width: theme.borderWidth),
        boxShadow: shadows,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            itemCount != null
                ? 'Order Summary ($itemCount items)'
                : 'Order Summary',
            style: typo.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: spacing.md),
          // Line items
          _SummaryRow(
            label: 'Subtotal',
            value: '$currency${subtotal.toStringAsFixed(2)}',
            theme: theme,
          ),
          if (shipping != null) ...[
            SizedBox(height: spacing.sm),
            _SummaryRow(
              label: 'Shipping',
              value: shipping! > 0
                  ? '$currency${shipping!.toStringAsFixed(2)}'
                  : 'Free',
              theme: theme,
              valueColor: shipping! == 0 ? colors.success : null,
            ),
          ],
          if (tax != null) ...[
            SizedBox(height: spacing.sm),
            _SummaryRow(
              label: 'Tax',
              value: '$currency${tax!.toStringAsFixed(2)}',
              theme: theme,
            ),
          ],
          SizedBox(height: spacing.sm),
          // Divider
          Container(height: 1, color: colors.border),
          SizedBox(height: spacing.sm),
          // Total
          _SummaryRow(
            label: 'Total',
            value: '$currency${total.toStringAsFixed(2)}',
            theme: theme,
            bold: true,
          ),
          SizedBox(height: spacing.lg),
          // Checkout button
          _CheckoutButton(onTap: onCheckout, theme: theme),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.theme,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final dynamic theme;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final typo = theme.typography;

    final style = bold ? typo.titleSmall : typo.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (style as TextStyle).copyWith(
            color: bold ? colors.onSurface : colors.resolvedOnSurfaceMuted,
            fontWeight: bold ? FontWeight.w700 : null,
          ),
        ),
        Text(
          value,
          style: style.copyWith(
            color: valueColor ?? colors.onSurface,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CheckoutButton extends StatefulWidget {
  const _CheckoutButton({required this.onTap, required this.theme});

  final VoidCallback? onTap;
  final dynamic theme;

  @override
  State<_CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<_CheckoutButton> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;
    final enabled = widget.onTap != null;

    final bgColor = enabled
        ? colors.primary as Color
        : (colors.border as Color);

    final glow = enabled
        ? theme.surfaceShadows(
            emphasized: _hovered,
            accent: colors.primary as Color,
          )
        : null;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onTap,
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
          child: Text(
            'Proceed to Checkout',
            style: (typo.labelLarge as TextStyle).copyWith(
              color: enabled ? colors.onPrimary : colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
