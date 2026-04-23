import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Column definition for [UiDataTable].
class UiDataColumn {
  const UiDataColumn({
    required this.label,
    this.sortable = false,
    this.width,
    this.flex,
  });

  /// Header label text.
  final String label;

  /// Whether this column supports sorting.
  final bool sortable;

  /// Fixed width. If null, the column uses [flex] or equal distribution.
  final double? width;

  /// Flex factor for flexible sizing. Ignored when [width] is set.
  final int? flex;
}

/// A sortable data table with themed styling.
///
/// ```dart
/// UiDataTable(
///   columns: [
///     UiDataColumn(label: 'Name', sortable: true),
///     UiDataColumn(label: 'Value', sortable: true),
///   ],
///   rows: [
///     [Text('Alpha'), Text('100')],
///     [Text('Beta'), Text('200')],
///   ],
///   onSort: (index, ascending) { /* sort logic */ },
/// )
/// ```
class UiDataTable extends StatelessWidget {
  const UiDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.striped = false,
  });

  /// Column definitions.
  final List<UiDataColumn> columns;

  /// Row data. Each inner list must have the same length as [columns].
  final List<List<Widget>> rows;

  /// Index of the currently sorted column, or null if unsorted.
  final int? sortColumnIndex;

  /// Whether the current sort is ascending.
  final bool sortAscending;

  /// Called when a sortable column header is tapped.
  final void Function(int columnIndex, bool ascending)? onSort;

  /// Whether to alternate row background colors.
  final bool striped;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    Widget buildCell(Widget child, UiDataColumn column) {
      if (column.width != null) {
        return SizedBox(width: column.width, child: child);
      }
      return Expanded(flex: column.flex ?? 1, child: child);
    }

    // Header row
    final header = Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.border,
            width: theme.borderWidth,
          ),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < columns.length; i++)
            buildCell(
              _HeaderCell(
                column: columns[i],
                isSorted: sortColumnIndex == i,
                ascending: sortAscending,
                onTap: columns[i].sortable && onSort != null
                    ? () {
                        final newAscending =
                            sortColumnIndex == i ? !sortAscending : true;
                        onSort!(i, newAscending);
                      }
                    : null,
                style: typo.labelMedium.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
                activeStyle: typo.labelMedium.copyWith(
                  color: colors.primary,
                ),
              ),
              columns[i],
            ),
        ],
      ),
    );

    // Data rows
    final dataRows = <Widget>[];
    for (int r = 0; r < rows.length; r++) {
      final row = rows[r];
      final isStriped = striped && r.isOdd;

      dataRows.add(
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            color: isStriped
                ? colors.onSurface.withValues(alpha: 0.03)
                : null,
            border: Border(
              bottom: BorderSide(
                color: colors.border.withValues(alpha: 0.3),
                width: theme.borderWidth * 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              for (int c = 0; c < row.length; c++)
                buildCell(row[c], columns[c]),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        ...dataRows,
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.column,
    required this.isSorted,
    required this.ascending,
    required this.style,
    required this.activeStyle,
    this.onTap,
  });

  final UiDataColumn column;
  final bool isSorted;
  final bool ascending;
  final TextStyle style;
  final TextStyle activeStyle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      column.label,
      style: isSorted ? activeStyle : style,
      overflow: TextOverflow.ellipsis,
    );

    if (!column.sortable) return label;

    // Unicode arrows: \u2191 up, \u2193 down
    final arrow = isSorted ? (ascending ? ' \u2191' : ' \u2193') : '';

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: label),
          if (arrow.isNotEmpty)
            Text(
              arrow,
              style: activeStyle,
            ),
        ],
      ),
    );
  }
}
