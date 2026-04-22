import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed async data builder that handles loading, error, and data states.
///
/// Supports both [Future] and [Stream] sources. Automatically shows a themed
/// loading spinner, error state with retry, or data via the [builder] callback.
///
/// ```dart
/// UiAsyncBuilder<User>(
///   future: fetchUser(),
///   builder: (context, user) => Text(user.name),
///   onRetry: () => setState(() {}),
/// )
/// ```
class UiAsyncBuilder<T> extends StatefulWidget {
  const UiAsyncBuilder({
    super.key,
    this.future,
    this.stream,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
    this.onRetry,
  }) : assert(
          future != null || stream != null,
          'Either future or stream must be provided.',
        );

  /// A [Future] that resolves to the data.
  final Future<T>? future;

  /// A [Stream] that emits the data.
  final Stream<T>? stream;

  /// Builder called when data is available.
  final Widget Function(BuildContext context, T data) builder;

  /// Optional custom loading widget. Defaults to a themed spinner.
  final Widget? loadingWidget;

  /// Optional custom error builder.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Called when the retry button is tapped in the default error state.
  final VoidCallback? onRetry;

  @override
  State<UiAsyncBuilder<T>> createState() => _UiAsyncBuilderState<T>();
}

class _UiAsyncBuilderState<T> extends State<UiAsyncBuilder<T>> {
  T? _data;
  Object? _error;
  bool _loading = true;
  StreamSubscription<T>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(UiAsyncBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.future != oldWidget.future ||
        widget.stream != oldWidget.stream) {
      _subscription?.cancel();
      _subscribe();
    }
  }

  void _subscribe() {
    setState(() {
      _loading = true;
      _error = null;
    });

    if (widget.stream != null) {
      _subscription = widget.stream!.listen(
        (data) {
          if (mounted) {
            setState(() {
              _data = data;
              _loading = false;
              _error = null;
            });
          }
        },
        onError: (Object error) {
          if (mounted) {
            setState(() {
              _error = error;
              _loading = false;
            });
          }
        },
      );
    } else if (widget.future != null) {
      widget.future!.then((data) {
        if (mounted) {
          setState(() {
            _data = data;
            _loading = false;
          });
        }
      }).catchError((Object error) {
        if (mounted) {
          setState(() {
            _error = error;
            _loading = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    if (_loading) {
      return widget.loadingWidget ??
          Center(
            child: _ThemedSpinner(
              color: colors.primary,
              glowColor: theme.useGlow ? colors.glow : null,
              size: 32,
            ),
          );
    }

    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!);
      }

      return Center(
        child: Padding(
          padding: spacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Something went wrong',
                style: typo.titleMedium.copyWith(color: colors.error),
              ),
              SizedBox(height: spacing.sm),
              Text(
                _error.toString(),
                style: typo.bodySmall.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.onRetry != null) ...[
                SizedBox(height: spacing.md),
                _RetryButton(onRetry: widget.onRetry!),
              ],
            ],
          ),
        ),
      );
    }

    return widget.builder(context, _data as T);
  }
}

/// Themed retry button for error states.
class _RetryButton extends StatefulWidget {
  const _RetryButton({required this.onRetry});

  final VoidCallback onRetry;

  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<_RetryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onRetry,
        child: AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          padding: EdgeInsets.symmetric(
            vertical: spacing.sm,
            horizontal: spacing.md,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? colors.primary.withValues(alpha: 0.1)
                : const Color(0x00000000),
            borderRadius: spacing.radiusMd,
            border: Border.all(
              color: colors.primary,
              width: theme.borderWidth,
            ),
          ),
          child: Text(
            'Retry',
            style: typo.labelMedium.copyWith(color: colors.primary),
          ),
        ),
      ),
    );
  }
}

/// A themed spinner using [CustomPaint].
class _ThemedSpinner extends StatefulWidget {
  const _ThemedSpinner({
    required this.color,
    this.glowColor,
    this.size = 32,
  });

  final Color color;
  final Color? glowColor;
  final double size;

  @override
  State<_ThemedSpinner> createState() => _ThemedSpinnerState();
}

class _ThemedSpinnerState extends State<_ThemedSpinner>
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
          size: Size.square(widget.size),
          painter: _SpinnerPainter(
            progress: _controller.value,
            color: widget.color,
            glowColor: widget.glowColor,
          ),
        );
      },
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({
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
    final startAngle = progress * 2 * math.pi;
    const sweepAngle = 4.0;

    if (glowColor != null) {
      final glowPaint = Paint()
        ..color = glowColor!.withValues(alpha: 0.4)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawArc(rect.deflate(3), startAngle, sweepAngle, false, glowPaint);
    }

    canvas.drawArc(rect.deflate(3), startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
