import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// An action revealed by swiping a list item.
class UiSwipeActionData {
  const UiSwipeActionData({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;
}

/// A list item wrapper that reveals action buttons on horizontal swipe.
///
/// ```dart
/// UiSwipeAction(
///   leadingActions: [
///     UiSwipeActionData(label: 'Archive', color: Colors.blue, onTap: () {}),
///   ],
///   trailingActions: [
///     UiSwipeActionData(label: 'Delete', color: Colors.red, icon: UiIcons.delete, onTap: () {}),
///   ],
///   child: UiListTile(title: Text('Swipe me')),
/// )
/// ```
class UiSwipeAction extends StatefulWidget {
  const UiSwipeAction({
    super.key,
    required this.child,
    this.leadingActions = const [],
    this.trailingActions = const [],
    this.actionWidth = 80.0,
    this.threshold = 0.3,
  });

  final Widget child;
  final List<UiSwipeActionData> leadingActions;
  final List<UiSwipeActionData> trailingActions;

  /// Width of each action button.
  final double actionWidth;

  /// Swipe fraction to trigger full reveal.
  final double threshold;

  @override
  State<UiSwipeAction> createState() => _UiSwipeActionState();
}

class _UiSwipeActionState extends State<UiSwipeAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dragExtent = 0;

  double get _maxLeadingExtent =>
      widget.leadingActions.length * widget.actionWidth;
  double get _maxTrailingExtent =>
      widget.trailingActions.length * widget.actionWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.delta.dx;
      _dragExtent = _dragExtent.clamp(-_maxTrailingExtent, _maxLeadingExtent);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final width = context.size?.width ?? 300;
    final fraction = _dragExtent.abs() / width;

    if (fraction > widget.threshold) {
      // Snap to full reveal
      setState(() {
        _dragExtent = _dragExtent > 0 ? _maxLeadingExtent : -_maxTrailingExtent;
      });
    } else {
      // Snap back
      setState(() => _dragExtent = 0);
    }
  }

  void _close() {
    setState(() => _dragExtent = 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final typo = theme.typography;

    return ClipRect(
      child: Stack(
        children: [
          // Background actions
          Positioned.fill(
            child: Row(
              children: [
                // Leading actions (swipe right)
                if (widget.leadingActions.isNotEmpty)
                  ...widget.leadingActions.map((action) => SizedBox(
                        width: widget.actionWidth,
                        child: GestureDetector(
                          onTap: () {
                            _close();
                            action.onTap();
                          },
                          child: Container(
                            color: action.color,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (action.icon != null)
                                  Icon(action.icon, size: 20, color: const Color(0xFFFFFFFF)),
                                Text(action.label,
                                    style: typo.labelSmall.copyWith(color: const Color(0xFFFFFFFF))),
                              ],
                            ),
                          ),
                        ),
                      )),
                const Spacer(),
                // Trailing actions (swipe left)
                if (widget.trailingActions.isNotEmpty)
                  ...widget.trailingActions.map((action) => SizedBox(
                        width: widget.actionWidth,
                        child: GestureDetector(
                          onTap: () {
                            _close();
                            action.onTap();
                          },
                          child: Container(
                            color: action.color,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (action.icon != null)
                                  Icon(action.icon, size: 20, color: const Color(0xFFFFFFFF)),
                                Text(action.label,
                                    style: typo.labelSmall.copyWith(color: const Color(0xFFFFFFFF))),
                              ],
                            ),
                          ),
                        ),
                      )),
              ],
            ),
          ),
          // Main content
          GestureDetector(
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: Matrix4.translationValues(_dragExtent, 0, 0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
