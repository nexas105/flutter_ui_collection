import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// An animated heart toggle for wishlisting products.
///
/// Renders a heart via [CustomPaint] and plays a scale-bounce animation
/// when tapped.
///
/// ```dart
/// UiWishlistButton(
///   isWishlisted: true,
///   onToggle: (value) => toggleWishlist(product, value),
/// )
/// ```
class UiWishlistButton extends StatefulWidget {
  const UiWishlistButton({
    super.key,
    required this.isWishlisted,
    this.onToggle,
    this.size = 24.0,
  });

  /// Whether the item is currently in the wishlist.
  final bool isWishlisted;

  /// Called with the new state when the heart is tapped.
  final ValueChanged<bool>? onToggle;

  /// Size of the heart icon.
  final double size;

  @override
  State<UiWishlistButton> createState() => _UiWishlistButtonState();
}

class _UiWishlistButtonState extends State<UiWishlistButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onToggle?.call(!widget.isWishlisted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: _handleTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Overshoot then settle: scale from 1 -> 1.3 -> 1
            final t = _controller.value;
            final scale = 1.0 + 0.3 * math.sin(t * math.pi);
            return Transform.scale(scale: scale, child: child);
          },
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _HeartPainter(
              filled: widget.isWishlisted,
              color: widget.isWishlisted ? colors.error : colors.onSurface,
              strokeWidth: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeartPainter extends CustomPainter {
  _HeartPainter({
    required this.filled,
    required this.color,
    required this.strokeWidth,
  });

  final bool filled;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.9)
      ..cubicTo(w * 0.15, h * 0.65, -w * 0.05, h * 0.3, w * 0.25, h * 0.15)
      ..cubicTo(w * 0.35, h * 0.08, w * 0.45, h * 0.15, w * 0.5, h * 0.3)
      ..cubicTo(w * 0.55, h * 0.15, w * 0.65, h * 0.08, w * 0.75, h * 0.15)
      ..cubicTo(w * 1.05, h * 0.3, w * 0.85, h * 0.65, w * 0.5, h * 0.9)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HeartPainter oldDelegate) =>
      filled != oldDelegate.filled || color != oldDelegate.color;
}
