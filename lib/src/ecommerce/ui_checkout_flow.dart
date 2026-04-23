import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_cart_controller.dart';

/// A 3-step checkout flow: Address, Payment, Review.
///
/// Uses [UiCartController] to display order totals on the review step.
///
/// ```dart
/// UiCheckoutFlow(
///   controller: cartController,
///   onComplete: () => showConfirmation(),
/// )
/// ```
class UiCheckoutFlow extends StatefulWidget {
  const UiCheckoutFlow({
    super.key,
    required this.controller,
    this.onComplete,
  });

  /// Cart controller used to read totals for the review step.
  final UiCartController controller;

  /// Called when the user places the order on step 3.
  final VoidCallback? onComplete;

  @override
  State<UiCheckoutFlow> createState() => _UiCheckoutFlowState();
}

class _UiCheckoutFlowState extends State<UiCheckoutFlow> {
  int _step = 0;
  int _paymentMethod = 0; // 0=card, 1=paypal, 2=bank

  late final TextEditingController _nameController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _zipController;
  late final FocusNode _nameFocus;
  late final FocusNode _streetFocus;
  late final FocusNode _cityFocus;
  late final FocusNode _zipFocus;

  String _name = '';
  String _street = '';
  String _city = '';
  String _zip = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _streetController = TextEditingController();
    _cityController = TextEditingController();
    _zipController = TextEditingController();
    _nameFocus = FocusNode();
    _streetFocus = FocusNode();
    _cityFocus = FocusNode();
    _zipFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _nameFocus.dispose();
    _streetFocus.dispose();
    _cityFocus.dispose();
    _zipFocus.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      widget.onComplete?.call();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Step indicator
        Padding(
          padding: spacing.paddingMd,
          child: Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i <= _step ? colors.primary : colors.border,
                    ),
                  ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: i <= _step ? colors.primary : colors.border,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: typo.labelMedium.copyWith(
                      color: i <= _step
                          ? colors.onPrimary
                          : colors.onSurface,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Step title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          child: Text(
            _stepTitle,
            style: typo.titleLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: spacing.md),

        // Step content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: spacing.md),
            child: _buildStepContent(theme),
          ),
        ),

        // Navigation buttons
        Padding(
          padding: spacing.paddingMd,
          child: Row(
            children: [
              if (_step > 0)
                Expanded(
                  child: _NavButton(
                    label: 'Back',
                    isPrimary: false,
                    onTap: _back,
                    theme: theme,
                  ),
                ),
              if (_step > 0) SizedBox(width: spacing.md),
              Expanded(
                child: _NavButton(
                  label: _step == 2 ? 'Place Order' : 'Next',
                  isPrimary: true,
                  onTap: _next,
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get _stepTitle {
    switch (_step) {
      case 0:
        return 'Shipping Address';
      case 1:
        return 'Payment Method';
      case 2:
        return 'Review Order';
      default:
        return '';
    }
  }

  Widget _buildStepContent(dynamic theme) {
    switch (_step) {
      case 0:
        return _buildAddressStep(theme);
      case 1:
        return _buildPaymentStep(theme);
      case 2:
        return _buildReviewStep(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAddressStep(dynamic theme) {
    final spacing = theme.spacing;

    return Column(
      children: [
        _TextInputField(
          controller: _nameController,
          focusNode: _nameFocus,
          placeholder: 'Full Name',
          text: _name,
          onChanged: (v) => setState(() => _name = v),
          theme: theme,
        ),
        SizedBox(height: spacing.md),
        _TextInputField(
          controller: _streetController,
          focusNode: _streetFocus,
          placeholder: 'Street Address',
          text: _street,
          onChanged: (v) => setState(() => _street = v),
          theme: theme,
        ),
        SizedBox(height: spacing.md),
        _TextInputField(
          controller: _cityController,
          focusNode: _cityFocus,
          placeholder: 'City',
          text: _city,
          onChanged: (v) => setState(() => _city = v),
          theme: theme,
        ),
        SizedBox(height: spacing.md),
        _TextInputField(
          controller: _zipController,
          focusNode: _zipFocus,
          placeholder: 'ZIP Code',
          text: _zip,
          onChanged: (v) => setState(() => _zip = v),
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildPaymentStep(dynamic theme) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    const labels = ['Credit / Debit Card', 'PayPal', 'Bank Transfer'];
    const icons = [
      IconData(0xe870, fontFamily: 'MaterialIcons'), // credit_card
      IconData(0xe8a7, fontFamily: 'MaterialIcons'), // payment
      IconData(0xe084, fontFamily: 'MaterialIcons'), // account_balance
    ];

    return Column(
      children: [
        for (int i = 0; i < 3; i++) ...[
          if (i > 0) SizedBox(height: spacing.sm),
          GestureDetector(
            onTap: () => setState(() => _paymentMethod = i),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: spacing.paddingMd,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: spacing.radiusMd,
                  border: Border.all(
                    color: _paymentMethod == i
                        ? colors.primary
                        : colors.border,
                    width: theme.borderWidth,
                  ),
                ),
                child: Row(
                  children: [
                    // Radio circle
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _paymentMethod == i
                              ? colors.primary
                              : colors.border,
                          width: 2,
                        ),
                      ),
                      child: _paymentMethod == i
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: spacing.md),
                    Icon(
                      icons[i],
                      size: 20,
                      color: colors.onSurface,
                    ),
                    SizedBox(width: spacing.sm),
                    Text(
                      labels[i],
                      style: (typo.bodyMedium as TextStyle).copyWith(
                        color: colors.onSurface,
                        fontWeight: _paymentMethod == i
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewStep(dynamic theme) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;
    final cart = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: spacing.paddingMd,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: spacing.radiusMd,
            border: Border.all(
              color: colors.border,
              width: theme.borderWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                style: (typo.titleSmall as TextStyle).copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: spacing.sm),
              _ReviewRow(
                label: 'Items',
                value: '${cart.itemCount}',
                theme: theme,
              ),
              SizedBox(height: spacing.xs),
              _ReviewRow(
                label: 'Subtotal',
                value:
                    '${cart.currency}${cart.subtotal.toStringAsFixed(2)}',
                theme: theme,
              ),
              if (cart.shipping > 0) ...[
                SizedBox(height: spacing.xs),
                _ReviewRow(
                  label: 'Shipping',
                  value:
                      '${cart.currency}${cart.shipping.toStringAsFixed(2)}',
                  theme: theme,
                ),
              ],
              if (cart.tax > 0) ...[
                SizedBox(height: spacing.xs),
                _ReviewRow(
                  label: 'Tax',
                  value:
                      '${cart.currency}${cart.tax.toStringAsFixed(2)}',
                  theme: theme,
                ),
              ],
              SizedBox(height: spacing.sm),
              Container(height: 1, color: colors.border),
              SizedBox(height: spacing.sm),
              _ReviewRow(
                label: 'Total',
                value: '${cart.currency}${cart.total.toStringAsFixed(2)}',
                theme: theme,
                bold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextInputField extends StatelessWidget {
  const _TextInputField({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.text,
    required this.onChanged,
    required this.theme,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final String text;
  final ValueChanged<String> onChanged;
  final dynamic theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: spacing.radiusMd,
        border: Border.all(color: colors.border, width: theme.borderWidth),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          if (text.isEmpty)
            Text(
              placeholder,
              style: (typo.bodyMedium as TextStyle).copyWith(
                color: (colors.onSurface as Color).withValues(alpha: 0.4),
              ),
            ),
          EditableText(
            controller: controller,
            focusNode: focusNode,
            style: (typo.bodyMedium as TextStyle).copyWith(
              color: colors.onSurface,
            ),
            cursorColor: colors.primary,
            backgroundCursorColor: colors.border,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onTap;
  final dynamic theme;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final Color bgColor;
    final Color fgColor;
    if (widget.isPrimary) {
      bgColor = colors.primary;
      fgColor = colors.onPrimary;
    } else {
      bgColor = colors.surface;
      fgColor = colors.onSurface;
    }

    List<BoxShadow>? glow;
    if (widget.isPrimary && theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(
          color: (colors.primary as Color).withValues(alpha: 0.3),
          blurRadius: 8,
        ),
      ];
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          padding: EdgeInsets.symmetric(vertical: spacing.md),
          decoration: BoxDecoration(
            color: _pressed ? bgColor.withValues(alpha: 0.8) : bgColor,
            borderRadius: spacing.radiusMd,
            border: widget.isPrimary
                ? null
                : Border.all(
                    color: colors.border,
                    width: theme.borderWidth,
                  ),
            boxShadow: glow,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: (typo.labelLarge as TextStyle).copyWith(
              color: fgColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    required this.theme,
    this.bold = false,
  });

  final String label;
  final String value;
  final dynamic theme;
  final bool bold;

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
            color: bold
                ? colors.onSurface
                : (colors.onSurface as Color).withValues(alpha: 0.7),
            fontWeight: bold ? FontWeight.w700 : null,
          ),
        ),
        Text(
          value,
          style: style.copyWith(
            color: colors.onSurface,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
