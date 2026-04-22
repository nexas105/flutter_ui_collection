import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Animates a list of children with staggered entrance animations.
///
/// Each child slides/fades in with a delay, creating a cascading reveal effect.
///
/// ```dart
/// UiStagger(
///   children: [
///     UiCard(child: Text('First')),
///     UiCard(child: Text('Second')),
///     UiCard(child: Text('Third')),
///   ],
/// )
/// ```
class UiStagger extends StatefulWidget {
  const UiStagger({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.animationDuration = const Duration(milliseconds: 400),
    this.curve,
    this.direction = UiStaggerDirection.up,
    this.slideOffset = 20.0,
  });

  final List<Widget> children;

  /// Delay between each child's animation start.
  final Duration staggerDelay;

  /// Duration of each child's animation.
  final Duration animationDuration;

  final Curve? curve;

  /// Direction from which children slide in.
  final UiStaggerDirection direction;

  /// How far children slide (in pixels).
  final double slideOffset;

  @override
  State<UiStagger> createState() => _UiStaggerState();
}

class _UiStaggerState extends State<UiStagger>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final totalDuration = widget.animationDuration +
        widget.staggerDelay * widget.children.length;
    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final curve = widget.curve ?? theme.animationCurve;
    final totalMs = _controller.duration!.inMilliseconds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < widget.children.length; i++)
          _StaggerItem(
            animation: _controller,
            begin: (widget.staggerDelay.inMilliseconds * i) / totalMs,
            end: ((widget.staggerDelay.inMilliseconds * i) +
                    widget.animationDuration.inMilliseconds) /
                totalMs,
            curve: curve,
            direction: widget.direction,
            slideOffset: widget.slideOffset,
            child: widget.children[i],
          ),
      ],
    );
  }
}

class _StaggerItem extends StatelessWidget {
  const _StaggerItem({
    required this.animation,
    required this.begin,
    required this.end,
    required this.curve,
    required this.direction,
    required this.slideOffset,
    required this.child,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Curve curve;
  final UiStaggerDirection direction;
  final double slideOffset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final itemAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(begin.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: curve),
    );

    final Offset slideBegin;
    switch (direction) {
      case UiStaggerDirection.up:
        slideBegin = Offset(0, slideOffset);
      case UiStaggerDirection.down:
        slideBegin = Offset(0, -slideOffset);
      case UiStaggerDirection.left:
        slideBegin = Offset(slideOffset, 0);
      case UiStaggerDirection.right:
        slideBegin = Offset(-slideOffset, 0);
    }

    return AnimatedBuilder(
      animation: itemAnimation,
      builder: (context, child) {
        final t = itemAnimation.value;
        return Transform.translate(
          offset: Offset.lerp(slideBegin, Offset.zero, t)!,
          child: Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Direction from which stagger items enter.
enum UiStaggerDirection { up, down, left, right }
