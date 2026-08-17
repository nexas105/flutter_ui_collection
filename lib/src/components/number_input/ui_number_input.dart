import 'package:flutter/widgets.dart';

import '../../icons/ui_icons.dart';
import '../../theme/ui_theme.dart';

/// A numeric stepper input with increment and decrement buttons.
///
/// Displays a [-] button, the current value, and a [+] button in a row.
/// Buttons are disabled when the value reaches [min] or [max].
///
/// ```dart
/// UiNumberInput(
///   value: _quantity,
///   onChanged: (v) => setState(() => _quantity = v),
///   min: 0,
///   max: 100,
/// )
/// ```
class UiNumberInput extends StatefulWidget {
  const UiNumberInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.step = 1,
    this.label,
    this.enabled = true,
  });

  final num value;
  final ValueChanged<num> onChanged;
  final num? min;
  final num? max;
  final num step;
  final String? label;
  final bool enabled;

  @override
  State<UiNumberInput> createState() => _UiNumberInputState();
}

class _UiNumberInputState extends State<UiNumberInput> {
  bool _decrementHovered = false;
  bool _incrementHovered = false;

  bool get _canDecrement =>
      widget.enabled &&
      (widget.min == null || widget.value - widget.step >= widget.min!);

  bool get _canIncrement =>
      widget.enabled &&
      (widget.max == null || widget.value + widget.step <= widget.max!);

  void _decrement() {
    if (!_canDecrement) return;
    final next = widget.value - widget.step;
    widget.onChanged(
      widget.min != null && next < widget.min! ? widget.min! : next,
    );
  }

  void _increment() {
    if (!_canIncrement) return;
    final next = widget.value + widget.step;
    widget.onChanged(
      widget.max != null && next > widget.max! ? widget.max! : next,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: typo.labelMedium.copyWith(color: colors.onBackground),
            ),
            SizedBox(height: spacing.xs),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepperButton(
                icon: UiIcons.decrement,
                enabled: _canDecrement,
                hovered: _decrementHovered,
                onHoverChanged: (v) => setState(() => _decrementHovered = v),
                onTap: _decrement,
              ),
              SizedBox(width: spacing.sm),
              AnimatedContainer(
                duration: theme.animationDuration,
                curve: theme.animationCurve,
                constraints: const BoxConstraints(minWidth: 48),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: spacing.radiusMd,
                  border: Border.all(
                    color: colors.border,
                    width: theme.borderWidth,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.value % 1 == 0
                      ? widget.value.toInt().toString()
                      : widget.value.toString(),
                  style: typo.bodyMedium.copyWith(color: colors.onSurface),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: spacing.sm),
              _StepperButton(
                icon: UiIcons.increment,
                enabled: _canIncrement,
                hovered: _incrementHovered,
                onHoverChanged: (v) => setState(() => _incrementHovered = v),
                onTap: _increment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.hovered,
    required this.onHoverChanged,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    final bgColor = !enabled
        ? colors.surface.withValues(alpha: 0.5)
        : hovered
        ? colors.primary.withValues(alpha: 0.15)
        : colors.surface;
    final fgColor = !enabled
        ? colors.onSurface.withValues(alpha: 0.3)
        : colors.primary;
    final borderColor = !enabled
        ? colors.border.withValues(alpha: 0.4)
        : colors.primary;

    List<BoxShadow>? glow;
    if (enabled && hovered && theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(color: colors.glow!.withValues(alpha: 0.2), blurRadius: 8),
      ];
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => onHoverChanged(true),
        onExit: (_) => onHoverChanged(false),
        child: AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: spacing.radiusMd,
            border: Border.all(color: borderColor, width: theme.borderWidth),
            boxShadow: glow,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: fgColor),
        ),
      ),
    );
  }
}
