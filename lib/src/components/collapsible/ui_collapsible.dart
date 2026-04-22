import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed collapsible / expandable section.
///
/// ```dart
/// UiCollapsible(
///   title: Text('Details'),
///   child: Text('Hidden content'),
/// )
/// ```
class UiCollapsible extends StatefulWidget {
  const UiCollapsible({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.onToggle,
  });

  final Widget title;
  final Widget child;
  final bool initiallyExpanded;
  final void Function(bool expanded)? onToggle;

  @override
  State<UiCollapsible> createState() => _UiCollapsibleState();
}

class _UiCollapsibleState extends State<UiCollapsible> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
    });
    widget.onToggle?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    final List<BoxShadow>? glowShadow = theme.useGlow && colors.glow != null
        ? [
            BoxShadow(
              color: colors.glow!.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ]
        : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: spacing.radiusMd,
        border: Border.all(color: colors.border, width: theme.borderWidth),
        color: colors.surface,
        boxShadow: glowShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: _toggle,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: spacing.sm + 2,
                ),
                color: const Color(0x00000000),
                child: Row(
                  children: [
                    Expanded(child: widget.title),
                    AnimatedRotation(
                      turns: _expanded ? 0.25 : 0.0,
                      duration: theme.animationDuration,
                      child: Text(
                        '\u25B6',
                        style: TextStyle(
                          color: colors.onSurface.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding:
                  EdgeInsets.fromLTRB(spacing.md, 0, spacing.md, spacing.md),
              child: widget.child,
            ),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: theme.animationDuration,
            sizeCurve: theme.animationCurve,
          ),
        ],
      ),
    );
  }
}
