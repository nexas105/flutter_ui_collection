import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A single cell in a [UiHeatmap].
class UiHeatmapCell {
  const UiHeatmapCell({
    required this.value,
    this.label,
  });

  /// Intensity value from 0.0 (empty) to 1.0 (full).
  final double value;

  /// Optional tooltip or label for this cell.
  final String? label;
}

/// A grid heatmap (GitHub contribution-style) built from [UiHeatmapCell]s.
///
/// Color is interpolated between [colorEmpty] and [colorFull] based on each
/// cell's value.
///
/// ```dart
/// UiHeatmap(
///   cells: [
///     [UiHeatmapCell(value: 0.2), UiHeatmapCell(value: 0.8)],
///     [UiHeatmapCell(value: 0.5), UiHeatmapCell(value: 1.0)],
///   ],
/// )
/// ```
class UiHeatmap extends StatelessWidget {
  const UiHeatmap({
    super.key,
    required this.cells,
    this.cellSize = 14,
    this.spacing = 2,
    this.colorEmpty,
    this.colorFull,
  });

  /// 2D grid of cells. Each inner list is a row.
  final List<List<UiHeatmapCell>> cells;

  /// Size of each square cell.
  final double cellSize;

  /// Spacing between cells.
  final double spacing;

  /// Color for value 0.0. Falls back to [UiColorScheme.border].
  final Color? colorEmpty;

  /// Color for value 1.0. Falls back to [UiColorScheme.primary].
  final Color? colorFull;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final empty = colorEmpty ?? colors.border.withValues(alpha: 0.3);
    final full = colorFull ?? colors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int row = 0; row < cells.length; row++)
          Padding(
            padding: EdgeInsets.only(
              bottom: row < cells.length - 1 ? spacing : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int col = 0; col < cells[row].length; col++)
                  Padding(
                    padding: EdgeInsets.only(
                      right: col < cells[row].length - 1 ? spacing : 0,
                    ),
                    child: _HeatmapSquare(
                      cell: cells[row][col],
                      size: cellSize,
                      colorEmpty: empty,
                      colorFull: full,
                      borderRadius: theme.spacing.borderRadiusSm * 0.5,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HeatmapSquare extends StatelessWidget {
  const _HeatmapSquare({
    required this.cell,
    required this.size,
    required this.colorEmpty,
    required this.colorFull,
    required this.borderRadius,
  });

  final UiHeatmapCell cell;
  final double size;
  final Color colorEmpty;
  final Color colorFull;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final clamped = cell.value.clamp(0.0, 1.0);
    final blended = Color.lerp(colorEmpty, colorFull, clamped)!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: blended,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
