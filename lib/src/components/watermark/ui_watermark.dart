import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Tiles a watermark text diagonally across its child.
///
/// Useful for "DRAFT", "CONFIDENTIAL", or similar overlays.
///
/// ```dart
/// UiWatermark(
///   text: 'DRAFT',
///   child: MyDocument(),
/// )
/// ```
class UiWatermark extends StatelessWidget {
  const UiWatermark({
    super.key,
    required this.text,
    required this.child,
    this.opacity = 0.05,
    this.rotate = -0.3,
    this.spacing = 120.0,
    this.textStyle,
  });

  /// The watermark text to tile.
  final String text;

  /// The widget to overlay.
  final Widget child;

  /// Opacity of the watermark. Defaults to `0.05`.
  final double opacity;

  /// Rotation in radians. Defaults to `-0.3`.
  final double rotate;

  /// Distance between repeated watermark texts. Defaults to `120.0`.
  final double spacing;

  /// Optional override for the watermark text style.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final typo = theme.typography;

    final style = textStyle ??
        typo.headlineMedium.copyWith(
          color: colors.onBackground,
          fontWeight: FontWeight.w700,
        );

    return ClipRect(
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: opacity,
                child: CustomPaint(
                  painter: _WatermarkPainter(
                    text: text,
                    style: style,
                    rotate: rotate,
                    spacing: spacing,
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

class _WatermarkPainter extends CustomPainter {
  _WatermarkPainter({
    required this.text,
    required this.style,
    required this.rotate,
    required this.spacing,
  });

  final String text;
  final TextStyle style;
  final double rotate;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    // Calculate the diagonal needed to cover the rotated area.
    final diagonal = math.sqrt(size.width * size.width + size.height * size.height);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotate);

    final stepX = textWidth + spacing;
    final stepY = textHeight + spacing;

    final halfDiag = diagonal / 2;
    final startX = -halfDiag;
    final startY = -halfDiag;

    for (var y = startY; y < halfDiag; y += stepY) {
      for (var x = startX; x < halfDiag; x += stepX) {
        textPainter.paint(canvas, Offset(x, y));
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_WatermarkPainter oldDelegate) =>
      text != oldDelegate.text ||
      style != oldDelegate.style ||
      rotate != oldDelegate.rotate ||
      spacing != oldDelegate.spacing;
}
