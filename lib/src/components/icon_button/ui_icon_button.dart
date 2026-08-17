import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Visual variant for the icon button.
enum UiIconButtonVariant { filled, outlined, ghost }

/// A themed icon-only button with hover and glow support.
///
/// ```dart
/// UiIconButton(
///   icon: Icons.add,
///   onPressed: () {},
///   variant: UiIconButtonVariant.filled,
///   tooltip: 'Add item',
/// )
/// ```
class UiIconButton extends StatefulWidget {
  const UiIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size,
    this.iconSize,
    this.tooltip,
    this.variant = UiIconButtonVariant.filled,
    this.color,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double? size;
  final double? iconSize;
  final String? tooltip;
  final UiIconButtonVariant variant;
  final Color? color;
  final bool enabled;

  bool get _enabled => enabled && onPressed != null;

  @override
  State<UiIconButton> createState() => _UiIconButtonState();
}

class _UiIconButtonState extends State<UiIconButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final components = theme.components;

    final effectiveColor = widget.color ?? colors.primary;

    final Color bgColor;
    final Color fgColor;
    Border? border;
    List<BoxShadow>? shadows;

    switch (widget.variant) {
      case UiIconButtonVariant.filled:
        bgColor = widget._enabled
            ? (_pressed
                  ? effectiveColor.withValues(alpha: 0.8)
                  : effectiveColor)
            : effectiveColor.withValues(alpha: 0.4);
        fgColor = colors.onPrimary;
        if (theme.useGlow && colors.glow != null && widget._enabled) {
          shadows = [
            BoxShadow(
              color: colors.glow!.withValues(alpha: _hovered ? 0.7 : 0.4),
              blurRadius: _hovered ? 16 : 8,
              spreadRadius: _hovered ? 1 : 0,
            ),
          ];
        } else if (theme.useShadows) {
          shadows = [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ];
        }
      case UiIconButtonVariant.outlined:
        bgColor = _hovered && widget._enabled
            ? effectiveColor.withValues(alpha: 0.1)
            : const Color(0x00000000);
        fgColor = widget._enabled
            ? effectiveColor
            : effectiveColor.withValues(alpha: 0.4);
        border = Border.all(
          color: widget._enabled
              ? effectiveColor
              : effectiveColor.withValues(alpha: 0.4),
          width: theme.borderWidth,
        );
      case UiIconButtonVariant.ghost:
        bgColor = _hovered && widget._enabled
            ? colors.onSurface.withValues(alpha: 0.08)
            : const Color(0x00000000);
        fgColor = widget._enabled
            ? colors.onSurface
            : colors.onSurface.withValues(alpha: 0.4);
    }

    Widget button = MouseRegion(
      cursor: widget._enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: widget._enabled
            ? (_) => setState(() => _pressed = true)
            : null,
        onTapUp: widget._enabled
            ? (_) => setState(() => _pressed = false)
            : null,
        onTapCancel: widget._enabled
            ? () => setState(() => _pressed = false)
            : null,
        onTap: widget._enabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          width: widget.size ?? components.controlHeightMedium,
          height: widget.size ?? components.controlHeightMedium,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: spacing.radiusMd,
            border: border,
            boxShadow: shadows,
          ),
          alignment: Alignment.center,
          child: Icon(
            theme.icons.resolve(widget.icon),
            size: widget.iconSize ?? components.iconSizeMedium,
            color: fgColor,
            weight: theme.icons.weight,
            grade: theme.icons.grade,
            opticalSize: theme.icons.opticalSize,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      // Wrap with a simple semantic label since we avoid Material Tooltip
      button = Semantics(label: widget.tooltip, button: true, child: button);
    }

    return button;
  }
}
