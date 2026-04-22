import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Animated number counter that counts up (or down) to a target value.
///
/// ```dart
/// UiCountUp(
///   end: 1234,
///   duration: Duration(seconds: 2),
///   prefix: '\$',
///   style: theme.typography.displayLarge,
/// )
/// ```
class UiCountUp extends StatefulWidget {
  const UiCountUp({
    super.key,
    this.begin = 0,
    required this.end,
    this.duration = const Duration(milliseconds: 1500),
    this.curve,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
    this.separator = ',',
    this.onComplete,
  });

  final double begin;
  final double end;
  final Duration duration;
  final Curve? curve;
  final TextStyle? style;

  /// Text shown before the number (e.g. '$').
  final String prefix;

  /// Text shown after the number (e.g. '%').
  final String suffix;

  /// Decimal places to show.
  final int decimals;

  /// Thousands separator.
  final String separator;

  final VoidCallback? onComplete;

  @override
  State<UiCountUp> createState() => _UiCountUpState();
}

class _UiCountUpState extends State<UiCountUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    final curve = widget.curve ?? Curves.easeOutCubic;
    _animation = Tween<double>(begin: widget.begin, end: widget.end)
        .animate(CurvedAnimation(parent: _controller, curve: curve));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(UiCountUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.end != widget.end || oldWidget.begin != widget.begin) {
      final theme = UiTheme.maybeOf(context);
      final curve = widget.curve ?? theme?.animationCurve ?? Curves.easeOutCubic;
      _animation = Tween<double>(begin: widget.begin, end: widget.end)
          .animate(CurvedAnimation(parent: _controller, curve: curve));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    final fixed = value.toStringAsFixed(widget.decimals);

    if (widget.separator.isEmpty) return '${widget.prefix}$fixed${widget.suffix}';

    // Add thousands separator
    final parts = fixed.split('.');
    final intPart = parts[0];
    final buffer = StringBuffer();
    var count = 0;
    for (var i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0 && intPart[i] != '-') {
        buffer.write(widget.separator);
      }
      buffer.write(intPart[i]);
      count++;
    }
    final formatted = buffer.toString().split('').reversed.join();
    final decimal = parts.length > 1 ? '.${parts[1]}' : '';

    return '${widget.prefix}$formatted$decimal${widget.suffix}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final resolvedStyle = widget.style ??
        theme.typography.displayMedium.copyWith(
          color: theme.colorScheme.onBackground,
        );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Text(
          _formatNumber(_animation.value),
          style: resolvedStyle,
        );
      },
    );
  }
}
