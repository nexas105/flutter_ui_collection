import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A speed-dial action for [UiFloatingActionButton].
class UiFabAction {
  const UiFabAction({
    required this.icon,
    this.label,
    required this.onTap,
  });

  final Widget icon;
  final String? label;
  final VoidCallback onTap;
}

/// A themed floating action button with optional speed dial.
///
/// ```dart
/// UiFloatingActionButton(
///   icon: Icon(Icons.add),
///   onPressed: () {},
///   actions: [
///     UiFabAction(icon: Icon(Icons.edit), label: 'Edit', onTap: () {}),
///   ],
/// )
/// ```
class UiFloatingActionButton extends StatefulWidget {
  const UiFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.actions = const [],
    this.size = 56.0,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final List<UiFabAction> actions;
  final double size;

  @override
  State<UiFloatingActionButton> createState() =>
      _UiFloatingActionButtonState();
}

class _UiFloatingActionButtonState extends State<UiFloatingActionButton>
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
    if (widget.actions.isEmpty) {
      widget.onPressed?.call();
      return;
    }
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

    final List<BoxShadow> shadows = [];
    if (theme.useGlow && colors.glow != null) {
      shadows.add(BoxShadow(
        color: colors.glow!.withValues(alpha: 0.4),
        blurRadius: 20,
        spreadRadius: 2,
      ));
    } else if (theme.useShadows) {
      shadows.add(BoxShadow(
        color: colors.shadow,
        blurRadius: 12,
        offset: const Offset(0, 4),
      ));
    }

    final miniSize = widget.size * 0.7;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Speed dial actions
        if (widget.actions.isNotEmpty)
          SizeTransition(
            sizeFactor: _controller,
            axisAlignment: 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final action in widget.actions) ...[
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (action.label != null) ...[
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
                              action.label!,
                              style: typo.labelSmall
                                  .copyWith(color: colors.onSurface),
                            ),
                          ),
                          SizedBox(width: spacing.sm),
                        ],
                        GestureDetector(
                          onTap: () {
                            _toggle();
                            action.onTap();
                          },
                          child: Container(
                            width: miniSize,
                            height: miniSize,
                            decoration: BoxDecoration(
                              color: colors.secondary,
                              shape: BoxShape.circle,
                              boxShadow:
                                  theme.useShadows
                                      ? [
                                          BoxShadow(
                                            color: colors.shadow,
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                            ),
                            alignment: Alignment.center,
                            child: action.icon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        // Main FAB
        GestureDetector(
          onTap: _toggle,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                boxShadow: shadows,
              ),
              alignment: Alignment.center,
              child: AnimatedRotation(
                turns: _open ? 0.125 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: widget.icon,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
