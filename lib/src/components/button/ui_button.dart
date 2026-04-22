import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// Button variant determines the visual style.
enum UiButtonVariant { filled, outlined, ghost, glow }

/// Button size presets.
enum UiButtonSize { small, medium, large }

/// A themeable button that adapts to the active [UiThemeData].
///
/// ```dart
/// UiButton(
///   label: 'Submit',
///   onPressed: () {},
///   variant: UiButtonVariant.glow,
/// )
/// ```
class UiButton extends StatefulWidget {
  const UiButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = UiButtonVariant.filled,
    this.size = UiButtonSize.medium,
    this.icon,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final UiButtonVariant variant;
  final UiButtonSize size;
  final IconData? icon;

  /// If true, the button stretches to fill available width.
  final bool expand;

  /// Shows a loading indicator instead of the label.
  final bool loading;

  bool get _enabled => onPressed != null && !loading;

  @override
  State<UiButton> createState() => _UiButtonState();
}

class _UiButtonState extends State<UiButton> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final double verticalPadding;
    final double horizontalPadding;
    final TextStyle textStyle;

    switch (widget.size) {
      case UiButtonSize.small:
        verticalPadding = spacing.xs;
        horizontalPadding = spacing.sm;
        textStyle = typo.labelSmall;
      case UiButtonSize.medium:
        verticalPadding = spacing.sm;
        horizontalPadding = spacing.md;
        textStyle = typo.labelMedium;
      case UiButtonSize.large:
        verticalPadding = spacing.md;
        horizontalPadding = spacing.lg;
        textStyle = typo.labelLarge;
    }

    final Color bgColor;
    final Color fgColor;
    final Border? border;
    List<BoxShadow>? shadows;

    switch (widget.variant) {
      case UiButtonVariant.filled:
        bgColor = widget._enabled
            ? (_pressed ? colors.primary.withValues(alpha: 0.8) : colors.primary)
            : colors.primary.withValues(alpha: 0.4);
        fgColor = colors.onPrimary;
        border = null;
        if (theme.useShadows) {
          shadows = [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];
        }
      case UiButtonVariant.outlined:
        bgColor = _hovered
            ? colors.primary.withValues(alpha: 0.1)
            : const Color(0x00000000);
        fgColor = widget._enabled
            ? colors.primary
            : colors.primary.withValues(alpha: 0.4);
        border = Border.all(
          color: widget._enabled
              ? colors.primary
              : colors.primary.withValues(alpha: 0.4),
          width: theme.borderWidth,
        );
      case UiButtonVariant.ghost:
        bgColor = _hovered
            ? colors.onSurface.withValues(alpha: 0.08)
            : const Color(0x00000000);
        fgColor = widget._enabled
            ? colors.onSurface
            : colors.onSurface.withValues(alpha: 0.4);
        border = null;
      case UiButtonVariant.glow:
        bgColor = widget._enabled
            ? (_pressed ? colors.primary.withValues(alpha: 0.9) : colors.primary)
            : colors.primary.withValues(alpha: 0.4);
        fgColor = colors.onPrimary;
        border = null;
        if (theme.useGlow && colors.glow != null) {
          shadows = [
            BoxShadow(
              color: colors.glow!.withValues(alpha: _hovered ? 0.8 : 0.5),
              blurRadius: _hovered ? 20 : 12,
              spreadRadius: _hovered ? 2 : 0,
            ),
          ];
        }
    }

    final content = widget.loading
        ? SizedBox(
            width: textStyle.fontSize ?? 14,
            height: textStyle.fontSize ?? 14,
            child: const _LoadingIndicator(),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: (textStyle.fontSize ?? 14) + 2, color: fgColor),
                SizedBox(width: spacing.xs),
              ],
              Text(widget.label, style: textStyle.copyWith(color: fgColor)),
            ],
          );

    final buttonChild = AnimatedContainer(
      duration: theme.animationDuration,
      curve: theme.animationCurve,
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: spacing.radiusMd,
        border: border,
        boxShadow: shadows,
      ),
      child: content,
    );

    return MouseRegion(
      cursor: widget._enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: widget._enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: widget._enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: widget._enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onPressed,
        child: widget.expand
            ? SizedBox(width: double.infinity, child: buttonChild)
            : buttonChild,
      ),
    );
  }
}

class _LoadingIndicator extends StatefulWidget {
  const _LoadingIndicator();

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _SpinnerPainter(
            progress: _controller.value,
            color: theme.colorScheme.onPrimary,
          ),
        );
      },
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;
    const sweepAngle = 4.0;
    final startAngle = progress * 6.28;

    canvas.drawArc(rect.deflate(1), startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
