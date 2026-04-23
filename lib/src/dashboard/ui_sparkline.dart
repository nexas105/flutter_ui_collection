import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A tiny inline sparkline chart rendered via [CustomPaint].
///
/// ```dart
/// UiSparkline(
///   data: [10, 25, 18, 30, 22, 35],
///   width: 100,
///   height: 40,
///   filled: true,
/// )
/// ```
class UiSparkline extends StatefulWidget {
  const UiSparkline({
    super.key,
    required this.data,
    this.width,
    this.height = 40,
    this.color,
    this.filled = false,
    this.animated = true,
  });

  /// Y-values drawn left-to-right with even horizontal spacing.
  final List<double> data;

  /// Width of the sparkline. If null, expands to fill available space.
  final double? width;

  /// Height of the sparkline.
  final double height;

  /// Override line color. Falls back to [UiColorScheme.primary].
  final Color? color;

  /// Whether to fill the area under the line with a gradient.
  final bool filled;

  /// Whether to animate the sparkline drawing.
  final bool animated;

  @override
  State<UiSparkline> createState() => _UiSparklineState();
}

class _UiSparklineState extends State<UiSparkline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    if (widget.animated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(UiSparkline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data && widget.animated) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final accent = widget.color ?? theme.colorScheme.primary;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return CustomPaint(
            size: Size(widget.width ?? double.infinity, widget.height),
            painter: _SparklinePainter(
              data: widget.data,
              progress: _animation.value,
              color: accent,
              filled: widget.filled,
            ),
          );
        },
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.data,
    required this.progress,
    required this.color,
    required this.filled,
  });

  final List<double> data;
  final double progress;
  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minVal = data.reduce(math.min);
    final maxVal = data.reduce(math.max);
    final range = maxVal - minVal;
    if (range == 0) return;

    final stepX = size.width / (data.length - 1);
    final padding = 2.0;
    final chartHeight = size.height - padding * 2;

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = padding +
          chartHeight -
          ((data[i] - minVal) / range) * chartHeight;
      points.add(Offset(x, y));
    }

    // Clip for animation progress
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, 0, size.width * progress, size.height),
    );

    // Build line path
    final linePath = Path()
      ..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    // Gradient fill below line
    if (filled) {
      final fillPath = Path.from(linePath);
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.lineTo(points.first.dx, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    // Stroke line
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      data != oldDelegate.data ||
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      filled != oldDelegate.filled;
}
