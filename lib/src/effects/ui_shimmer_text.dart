import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Text with a sweeping shimmer/shine animation.
///
/// Great for loading states, titles, or highlights.
///
/// ```dart
/// UiShimmerText(
///   'Loading...',
///   style: theme.typography.headlineMedium,
/// )
/// ```
class UiShimmerText extends StatefulWidget {
  const UiShimmerText(
    this.text, {
    super.key,
    this.style,
    this.baseColor,
    this.shimmerColor,
    this.duration = const Duration(milliseconds: 2000),
  });

  final String text;
  final TextStyle? style;

  /// Base text color. Defaults to theme's onBackground.
  final Color? baseColor;

  /// Shimmer highlight color. Defaults to theme's primary.
  final Color? shimmerColor;

  final Duration duration;

  @override
  State<UiShimmerText> createState() => _UiShimmerTextState();
}

class _UiShimmerTextState extends State<UiShimmerText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final resolvedStyle = widget.style ??
        theme.typography.headlineMedium.copyWith(
          color: theme.colorScheme.onBackground,
        );

    final baseColor = widget.baseColor ?? theme.colorScheme.onBackground;
    final shimmerColor = widget.shimmerColor ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + 3.0 * _controller.value, 0),
              end: Alignment(0.0 + 3.0 * _controller.value, 0),
              colors: [baseColor, shimmerColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(widget.text, style: resolvedStyle),
        );
      },
    );
  }
}
