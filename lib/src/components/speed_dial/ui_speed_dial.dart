import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A single action in the [UiSpeedDial] fan-out menu.
class UiSpeedDialAction {
  const UiSpeedDialAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Optional override color for this action.
  final Color? color;
}

/// An expandable floating action button that fans out labeled mini-buttons.
///
/// ```dart
/// UiSpeedDial(
///   icon: Icons.add,
///   actions: [
///     UiSpeedDialAction(icon: Icons.camera, label: 'Camera', onTap: () {}),
///     UiSpeedDialAction(icon: Icons.photo, label: 'Gallery', onTap: () {}),
///   ],
/// )
/// ```
class UiSpeedDial extends StatefulWidget {
  const UiSpeedDial({
    super.key,
    required this.icon,
    required this.actions,
    this.size = 56.0,
  });

  /// Icon shown on the main button.
  final IconData icon;

  /// Actions that fan out when the main button is tapped.
  final List<UiSpeedDialAction> actions;

  /// Size of the main button. Defaults to `56.0`.
  final double size;

  @override
  State<UiSpeedDial> createState() => _UiSpeedDialState();
}

class _UiSpeedDialState extends State<UiSpeedDial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    List<BoxShadow>? glow;
    if (theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.35),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ];
    }

    List<BoxShadow>? shadow;
    if (theme.useShadows) {
      shadow = [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    }

    final mainButton = GestureDetector(
      onTap: _toggle,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
            boxShadow: glow ?? shadow,
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.rotate(
              angle: _controller.value * 0.75,
              child: child,
            ),
            child: Icon(
              widget.icon,
              color: colors.onPrimary,
              size: widget.size * 0.45,
            ),
          ),
        ),
      ),
    );

    final actionWidgets = <Widget>[];
    for (var i = 0; i < widget.actions.length; i++) {
      final action = widget.actions[i];
      final actionColor = action.color ?? colors.secondary;

      // Staggered interval for each action.
      final begin = (i / widget.actions.length) * 0.6;
      final end = begin + 0.4;
      final scaleAnim = CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end.clamp(0.0, 1.0), curve: Curves.easeOut),
      );

      actionWidgets.add(
        AnimatedBuilder(
          animation: scaleAnim,
          builder: (context, child) => Transform.scale(
            scale: scaleAnim.value,
            child: Opacity(opacity: scaleAnim.value, child: child),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: spacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: spacing.radiusSm,
                    border: Border.all(
                      color: colors.border,
                      width: theme.borderWidth,
                    ),
                  ),
                  child: Text(
                    action.label,
                    style: typo.labelSmall.copyWith(color: colors.onSurface),
                  ),
                ),
                SizedBox(width: spacing.sm),
                GestureDetector(
                  onTap: () {
                    _toggle();
                    action.onTap();
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: widget.size * 0.7,
                      height: widget.size * 0.7,
                      decoration: BoxDecoration(
                        color: actionColor,
                        shape: BoxShape.circle,
                        boxShadow: theme.useShadows
                            ? [
                                BoxShadow(
                                  color: colors.shadow.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        action.icon,
                        color: colors.onSecondary,
                        size: widget.size * 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...actionWidgets,
        if (actionWidgets.isNotEmpty) SizedBox(height: spacing.sm),
        mainButton,
      ],
    );
  }
}
