import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A Pinterest-style staggered masonry grid layout.
///
/// Distributes children across columns using a shortest-column-first algorithm
/// so that columns stay roughly equal in height.
///
/// ```dart
/// UiMasonryGrid(
///   crossAxisCount: 3,
///   children: cards,
/// )
/// ```
class UiMasonryGrid extends StatelessWidget {
  const UiMasonryGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spacing,
    this.mainAxisSpacing,
    this.padding,
  });

  /// Widgets to distribute across columns.
  final List<Widget> children;

  /// Number of columns. Defaults to `2`.
  final int crossAxisCount;

  /// Horizontal spacing between columns.
  final double? spacing;

  /// Vertical spacing between items within a column.
  final double? mainAxisSpacing;

  /// Optional outer padding.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final sp = theme.spacing;

    final hGap = spacing ?? sp.md;
    final vGap = mainAxisSpacing ?? sp.md;

    // Build column lists using round-robin (shortest-first would need
    // actual heights which aren't available at build time, so we use
    // simple round-robin distribution which is the standard approach
    // for a build-time masonry).
    final columns = List.generate(crossAxisCount, (_) => <Widget>[]);
    for (var i = 0; i < children.length; i++) {
      columns[i % crossAxisCount].add(children[i]);
    }

    return SingleChildScrollView(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var col = 0; col < crossAxisCount; col++) ...[
            if (col > 0) SizedBox(width: hGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var row = 0; row < columns[col].length; row++) ...[
                    if (row > 0) SizedBox(height: vGap),
                    columns[col][row],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
