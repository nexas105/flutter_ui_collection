import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed drag-to-reorder list built without Material.
///
/// Uses [LongPressDraggable] and [DragTarget] for reordering.
///
/// ```dart
/// UiReorderableList<String>(
///   items: ['A', 'B', 'C'],
///   itemBuilder: (context, item, index) => Text(item),
///   onReorder: (oldIndex, newIndex) { ... },
/// )
/// ```
class UiReorderableList<T> extends StatefulWidget {
  const UiReorderableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    this.handleBuilder,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;

  /// Optional drag handle builder. If null, the entire item is draggable.
  final Widget Function(BuildContext context, int index)? handleBuilder;

  @override
  State<UiReorderableList<T>> createState() => _UiReorderableListState<T>();
}

class _UiReorderableListState<T> extends State<UiReorderableList<T>> {
  int? _dragIndex;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < widget.items.length; i++)
          DragTarget<int>(
            onWillAcceptWithDetails: (details) => details.data != i,
            onAcceptWithDetails: (details) {
              widget.onReorder(details.data, i);
            },
            builder: (context, candidateData, rejectedData) {
              final isDropTarget = candidateData.isNotEmpty;

              final itemContent = Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isDropTarget
                      ? colors.primary.withValues(alpha: 0.08)
                      : colors.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: isDropTarget ? colors.primary : colors.border,
                      width: theme.borderWidth,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (widget.handleBuilder != null) ...[
                      widget.handleBuilder!(context, i),
                      SizedBox(width: spacing.sm),
                    ],
                    Expanded(
                      child: widget.itemBuilder(
                          context, widget.items[i], i),
                    ),
                  ],
                ),
              );

              final List<BoxShadow> dragShadows = [];
              if (theme.useGlow && colors.glow != null) {
                dragShadows.add(BoxShadow(
                  color: colors.glow!.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ));
              } else if (theme.useShadows) {
                dragShadows.add(BoxShadow(
                  color: colors.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ));
              }

              final feedback = Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: spacing.radiusMd,
                  border: Border.all(
                    color: colors.primary,
                    width: theme.borderWidth,
                  ),
                  boxShadow: dragShadows,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: spacing.sm,
                ),
                child: DefaultTextStyle(
                  style: theme.typography.bodyMedium
                      .copyWith(color: colors.onSurface),
                  child: widget.itemBuilder(context, widget.items[i], i),
                ),
              );

              return LongPressDraggable<int>(
                data: i,
                feedback: feedback,
                childWhenDragging: Opacity(
                  opacity: 0.4,
                  child: itemContent,
                ),
                onDragStarted: () => setState(() => _dragIndex = i),
                onDragEnd: (_) => setState(() => _dragIndex = null),
                child: Opacity(
                  opacity: _dragIndex == i ? 0.4 : 1.0,
                  child: itemContent,
                ),
              );
            },
          ),
      ],
    );
  }
}
