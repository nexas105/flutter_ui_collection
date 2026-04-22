import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed pull-to-refresh wrapper.
///
/// Wraps a scrollable [child] and triggers [onRefresh] when the user
/// pulls down past the threshold. Shows a themed spinner during refresh.
///
/// ```dart
/// UiPullToRefresh(
///   onRefresh: () async => await fetchData(),
///   child: ListView(...),
/// )
/// ```
class UiPullToRefresh extends StatefulWidget {
  const UiPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.pullThreshold = 80.0,
    this.indicatorSize = 32.0,
  });

  /// The scrollable child widget.
  final Widget child;

  /// Async callback triggered on pull-to-refresh.
  final Future<void> Function() onRefresh;

  /// How far the user must pull to trigger a refresh.
  final double pullThreshold;

  /// Size of the loading indicator.
  final double indicatorSize;

  @override
  State<UiPullToRefresh> createState() => _UiPullToRefreshState();
}

class _UiPullToRefreshState extends State<UiPullToRefresh>
    with SingleTickerProviderStateMixin {
  double _pullDistance = 0.0;
  bool _refreshing = false;
  late final AnimationController _spinnerController;

  @override
  void initState() {
    super.initState();
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _spinnerController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _refreshing = true);
    _spinnerController.repeat();
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _spinnerController.stop();
        setState(() {
          _refreshing = false;
          _pullDistance = 0.0;
        });
      }
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_refreshing) return false;

    if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) {
        setState(() {
          _pullDistance += notification.overscroll.abs();
        });
      }
    }

    if (notification is ScrollEndNotification) {
      if (_pullDistance >= widget.pullThreshold) {
        _handleRefresh();
      } else {
        setState(() => _pullDistance = 0.0);
      }
    }

    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels > 0 && _pullDistance > 0) {
        setState(() => _pullDistance = 0.0);
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    final progress = (_pullDistance / widget.pullThreshold).clamp(0.0, 1.0);
    final indicatorOffset =
        _refreshing ? widget.pullThreshold : _pullDistance.clamp(0.0, widget.pullThreshold);

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          widget.child,
          if (indicatorOffset > 0 || _refreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: theme.animationDuration,
                curve: theme.animationCurve,
                height: indicatorOffset,
                alignment: Alignment.center,
                child: _refreshing
                    ? AnimatedBuilder(
                        animation: _spinnerController,
                        builder: (context, _) {
                          return CustomPaint(
                            size: Size.square(widget.indicatorSize),
                            painter: _PullSpinnerPainter(
                              progress: _spinnerController.value,
                              color: colors.primary,
                              glowColor:
                                  theme.useGlow ? colors.glow : null,
                            ),
                          );
                        },
                      )
                    : CustomPaint(
                        size: Size.square(widget.indicatorSize),
                        painter: _PullProgressPainter(
                          progress: progress,
                          color: colors.primary,
                          glowColor: theme.useGlow ? colors.glow : null,
                        ),
                      ),
              ),
            ),
          if (_pullDistance > 0 && !_refreshing)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(height: spacing.xs),
            ),
        ],
      ),
    );
  }
}

/// Paints a progress arc indicating how close the user is to triggering refresh.
class _PullProgressPainter extends CustomPainter {
  _PullProgressPainter({
    required this.progress,
    required this.color,
    this.glowColor,
  });

  final double progress;
  final Color color;
  final Color? glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;
    final deflated = rect.deflate(3);

    canvas.drawArc(deflated, 0, 2 * math.pi, false, bgPaint);

    if (glowColor != null && progress > 0.5) {
      final glowPaint = Paint()
        ..color = glowColor!.withValues(alpha: 0.3 * progress)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawArc(
          deflated, -math.pi / 2, 2 * math.pi * progress, false, glowPaint);
    }

    canvas.drawArc(
        deflated, -math.pi / 2, 2 * math.pi * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(_PullProgressPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

/// Paints a spinning arc during active refresh.
class _PullSpinnerPainter extends CustomPainter {
  _PullSpinnerPainter({
    required this.progress,
    required this.color,
    this.glowColor,
  });

  final double progress;
  final Color color;
  final Color? glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;
    final deflated = rect.deflate(3);
    final startAngle = progress * 2 * math.pi;
    const sweepAngle = 4.0;

    if (glowColor != null) {
      final glowPaint = Paint()
        ..color = glowColor!.withValues(alpha: 0.4)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawArc(deflated, startAngle, sweepAngle, false, glowPaint);
    }

    canvas.drawArc(deflated, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_PullSpinnerPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
