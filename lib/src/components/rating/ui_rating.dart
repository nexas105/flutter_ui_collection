import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed star rating widget.
///
/// ```dart
/// UiRating(
///   value: 3.5,
///   onChanged: (v) => setState(() => _rating = v),
/// )
/// ```
class UiRating extends StatefulWidget {
  const UiRating({
    super.key,
    required this.value,
    this.onChanged,
    this.maxRating = 5,
    this.size = 28.0,
    this.spacing = 4.0,
    this.allowHalf = true,
    this.color,
    this.emptyColor,
  });

  /// Current rating value.
  final double value;

  /// Called when the user taps a star. Null makes it read-only.
  final ValueChanged<double>? onChanged;

  final int maxRating;
  final double size;
  final double spacing;
  final bool allowHalf;

  /// Filled star color. Defaults to theme's warning color.
  final Color? color;

  /// Empty star color. Defaults to theme's border color.
  final Color? emptyColor;

  @override
  State<UiRating> createState() => _UiRatingState();
}

class _UiRatingState extends State<UiRating> {
  double? _hoverValue;

  double get _displayValue => _hoverValue ?? widget.value;

  void _handleTap(int index, Offset localPosition) {
    if (widget.onChanged == null) return;
    if (widget.allowHalf && localPosition.dx < widget.size / 2) {
      widget.onChanged!(index + 0.5);
    } else {
      widget.onChanged!(index + 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final filledColor = widget.color ?? colors.warning;
    final emptyColor = widget.emptyColor ?? colors.border;
    final interactive = widget.onChanged != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < widget.maxRating; i++) ...[
          if (i > 0) SizedBox(width: widget.spacing),
          GestureDetector(
            onTapDown: interactive
                ? (d) => _handleTap(i, d.localPosition)
                : null,
            child: MouseRegion(
              cursor: interactive ? SystemMouseCursors.click : SystemMouseCursors.basic,
              onEnter: interactive
                  ? (_) => setState(() => _hoverValue = i + 1.0)
                  : null,
              onExit: interactive
                  ? (_) => setState(() => _hoverValue = null)
                  : null,
              child: _StarIcon(
                filled: _displayValue >= i + 1,
                halfFilled: _displayValue > i && _displayValue < i + 1,
                size: widget.size,
                filledColor: filledColor,
                emptyColor: emptyColor,
                glowColor: theme.useGlow ? filledColor : null,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StarIcon extends StatelessWidget {
  const _StarIcon({
    required this.filled,
    required this.halfFilled,
    required this.size,
    required this.filledColor,
    required this.emptyColor,
    this.glowColor,
  });

  final bool filled;
  final bool halfFilled;
  final double size;
  final Color filledColor;
  final Color emptyColor;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StarPainter(
          filled: filled,
          halfFilled: halfFilled,
          filledColor: filledColor,
          emptyColor: emptyColor,
          glowColor: glowColor,
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({
    required this.filled,
    required this.halfFilled,
    required this.filledColor,
    required this.emptyColor,
    this.glowColor,
  });

  final bool filled;
  final bool halfFilled;
  final Color filledColor;
  final Color emptyColor;
  final Color? glowColor;

  Path _starPath(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final ir = r * 0.4;
    final path = Path();

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * 3.14159265 / 180;
      final innerAngle = ((i * 72) + 36 - 90) * 3.14159265 / 180;
      final ox = cx + r * math.cos(outerAngle);
      final oy = cy + r * math.sin(outerAngle);
      final ix = cx + ir * math.cos(innerAngle);
      final iy = cy + ir * math.sin(innerAngle);
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _starPath(size);

    if (filled) {
      canvas.drawPath(path, Paint()..color = filledColor);
      if (glowColor != null) {
        canvas.drawPath(path, Paint()
          ..color = glowColor!.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      }
    } else if (halfFilled) {
      // Draw empty star
      canvas.drawPath(path, Paint()..color = emptyColor);
      // Clip left half and draw filled
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width / 2, size.height));
      canvas.drawPath(path, Paint()..color = filledColor);
      canvas.restore();
    } else {
      canvas.drawPath(path, Paint()..color = emptyColor);
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      filled != old.filled || halfFilled != old.halfFilled;
}
