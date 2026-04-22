import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed split view with a draggable divider.
///
/// ```dart
/// UiResizablePanel(
///   firstChild: Text('Left'),
///   secondChild: Text('Right'),
///   axis: Axis.horizontal,
/// )
/// ```
class UiResizablePanel extends StatefulWidget {
  const UiResizablePanel({
    super.key,
    required this.firstChild,
    required this.secondChild,
    this.axis = Axis.horizontal,
    this.initialRatio = 0.5,
    this.minRatio = 0.1,
    this.maxRatio = 0.9,
  });

  final Widget firstChild;
  final Widget secondChild;
  final Axis axis;
  final double initialRatio;
  final double minRatio;
  final double maxRatio;

  @override
  State<UiResizablePanel> createState() => _UiResizablePanelState();
}

class _UiResizablePanelState extends State<UiResizablePanel> {
  late double _ratio;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio;
  }

  void _onDragUpdate(DragUpdateDetails details, double totalSize) {
    setState(() {
      final delta = widget.axis == Axis.horizontal
          ? details.delta.dx / totalSize
          : details.delta.dy / totalSize;
      _ratio = (_ratio + delta).clamp(widget.minRatio, widget.maxRatio);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;

    final dividerThickness = 6.0;
    final dividerColor = _hovering ? colors.primary : colors.border;

    final List<BoxShadow>? glowShadow =
        _hovering && theme.useGlow && colors.glow != null
            ? [
                BoxShadow(
                  color: colors.glow!.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ]
            : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSize = widget.axis == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        final firstSize = totalSize * _ratio - dividerThickness / 2;
        final secondSize = totalSize * (1 - _ratio) - dividerThickness / 2;

        final divider = MouseRegion(
          cursor: widget.axis == Axis.horizontal
              ? SystemMouseCursors.resizeColumn
              : SystemMouseCursors.resizeRow,
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: GestureDetector(
            onHorizontalDragUpdate: widget.axis == Axis.horizontal
                ? (d) => _onDragUpdate(d, totalSize)
                : null,
            onVerticalDragUpdate: widget.axis == Axis.vertical
                ? (d) => _onDragUpdate(d, totalSize)
                : null,
            child: Container(
              width:
                  widget.axis == Axis.horizontal ? dividerThickness : null,
              height:
                  widget.axis == Axis.vertical ? dividerThickness : null,
              decoration: BoxDecoration(
                color: dividerColor,
                boxShadow: glowShadow,
              ),
            ),
          ),
        );

        final children = <Widget>[
          SizedBox(
            width: widget.axis == Axis.horizontal ? firstSize : null,
            height: widget.axis == Axis.vertical ? firstSize : null,
            child: widget.firstChild,
          ),
          divider,
          SizedBox(
            width: widget.axis == Axis.horizontal ? secondSize : null,
            height: widget.axis == Axis.vertical ? secondSize : null,
            child: widget.secondChild,
          ),
        ];

        return widget.axis == Axis.horizontal
            ? Row(children: children)
            : Column(children: children);
      },
    );
  }
}
