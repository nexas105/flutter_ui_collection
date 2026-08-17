import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_auth_models.dart';

/// A themed social login button that shows a provider icon and label.
///
/// ```dart
/// UiSocialButton(
///   provider: UiSocialProvider.google,
///   onPressed: () => controller.socialLogin(UiSocialProvider.google),
/// )
/// ```
class UiSocialButton extends StatefulWidget {
  const UiSocialButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.loading = false,
    this.label,
    this.icon,
  });

  /// The social provider this button represents.
  final UiSocialProvider provider;

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  /// Shows a loading indicator when true.
  final bool loading;

  /// Override the default "Continue with {provider}" label.
  final String? label;

  /// Override the provider's default icon.
  final IconData? icon;

  bool get _enabled => onPressed != null && !loading;

  @override
  State<UiSocialButton> createState() => _UiSocialButtonState();
}

class _UiSocialButtonState extends State<UiSocialButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final bgColor = _hovered
        ? colors.primary.withValues(alpha: theme.components.hoverOpacity)
        : const Color(0x00000000);
    final borderColor = widget._enabled
        ? colors.border
        : colors.border.withValues(alpha: 0.4);
    final fgColor = widget._enabled
        ? colors.onSurface
        : colors.resolvedOnSurfaceSubtle;

    final resolvedIcon = widget.icon ?? widget.provider.icon;
    final resolvedLabel =
        widget.label ?? 'Continue with ${widget.provider.label}';

    final shadows = _hovered ? theme.surfaceShadows(emphasized: true) : null;

    final content = widget.loading
        ? SizedBox(
            width: 16,
            height: 16,
            child: _SocialLoadingIndicator(color: fgColor),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(resolvedIcon, size: 18, color: fgColor),
              SizedBox(width: spacing.sm),
              Flexible(
                child: Text(
                  resolvedLabel,
                  style: typo.labelMedium.copyWith(color: fgColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          );

    return MouseRegion(
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
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          padding: EdgeInsets.symmetric(
            vertical: spacing.sm,
            horizontal: spacing.md,
          ),
          decoration: BoxDecoration(
            color: _pressed
                ? colors.primary.withValues(
                    alpha: theme.components.pressedOpacity,
                  )
                : bgColor,
            borderRadius: spacing.radiusMd,
            border: Border.all(color: borderColor, width: theme.borderWidth),
            boxShadow: shadows,
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}

class _SocialLoadingIndicator extends StatefulWidget {
  const _SocialLoadingIndicator({required this.color});
  final Color color;

  @override
  State<_SocialLoadingIndicator> createState() =>
      _SocialLoadingIndicatorState();
}

class _SocialLoadingIndicatorState extends State<_SocialLoadingIndicator>
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _SpinnerPainter(
            progress: _controller.value,
            color: widget.color,
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
    final startAngle = progress * 6.28;

    canvas.drawArc(rect.deflate(1), startAngle, 4.0, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
