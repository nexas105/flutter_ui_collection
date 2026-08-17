import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A single tile in [UiDashboardLayout].
class UiDashboardTile {
  const UiDashboardTile({
    required this.child,
    this.colSpan = 1,
    this.rowSpan = 1,
  });

  final Widget child;

  /// Number of columns this tile spans.
  final int colSpan;

  /// Number of rows this tile spans.
  final int rowSpan;
}

/// A responsive dashboard grid layout.
///
/// Automatically adjusts columns based on screen width.
/// Each tile can span multiple columns and rows.
///
/// ```dart
/// UiDashboardLayout(
///   tiles: [
///     UiDashboardTile(child: revenueChart, colSpan: 2),
///     UiDashboardTile(child: usersPie),
///     UiDashboardTile(child: activityFeed),
///   ],
///   columns: 4,
///   rowHeight: 200,
/// )
/// ```
class UiDashboardLayout extends StatelessWidget {
  const UiDashboardLayout({
    super.key,
    required this.tiles,
    this.columns = 4,
    this.spacing,
    this.rowHeight = 200,
  });

  final List<UiDashboardTile> tiles;

  /// Default number of columns at the widest breakpoint.
  final int columns;

  /// Gap between tiles. Falls back to theme spacing.
  final double? spacing;

  /// Height of a single row unit.
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final gap = spacing ?? theme.spacing.md;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        // Responsive column count
        int effectiveColumns;
        if (maxWidth > 1100) {
          effectiveColumns = columns;
        } else if (maxWidth > 750) {
          effectiveColumns = (columns * 0.75).ceil().clamp(1, columns);
        } else if (maxWidth > 450) {
          effectiveColumns = (columns * 0.5).ceil().clamp(1, columns);
        } else {
          effectiveColumns = 1;
        }

        final colWidth =
            (maxWidth - gap * (effectiveColumns - 1)) / effectiveColumns;

        // Simple greedy row packing
        final rows = <List<_PlacedTile>>[];
        final rowCapacity = <int>[];

        for (final tile in tiles) {
          final span = tile.colSpan.clamp(1, effectiveColumns);

          // Find a row with enough space
          int targetRow = -1;
          for (int r = 0; r < rows.length; r++) {
            if (rowCapacity[r] + span <= effectiveColumns) {
              targetRow = r;
              break;
            }
          }

          if (targetRow == -1) {
            targetRow = rows.length;
            rows.add([]);
            rowCapacity.add(0);
          }

          rows[targetRow].add(_PlacedTile(tile: tile, span: span));
          rowCapacity[targetRow] += span;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int r = 0; r < rows.length; r++) ...[
              if (r > 0) SizedBox(height: gap),
              SizedBox(
                height: rows[r].fold<double>(
                  rowHeight,
                  (maxH, pt) =>
                      pt.tile.rowSpan * rowHeight +
                              (pt.tile.rowSpan - 1) * gap >
                          maxH
                      ? pt.tile.rowSpan * rowHeight +
                            (pt.tile.rowSpan - 1) * gap
                      : maxH,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int t = 0; t < rows[r].length; t++) ...[
                      if (t > 0) SizedBox(width: gap),
                      SizedBox(
                        width:
                            rows[r][t].span * colWidth +
                            (rows[r][t].span - 1) * gap,
                        child: rows[r][t].tile.child,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PlacedTile {
  const _PlacedTile({required this.tile, required this.span});
  final UiDashboardTile tile;
  final int span;
}
