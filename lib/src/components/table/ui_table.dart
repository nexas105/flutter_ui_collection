import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Column definition for [UiTable].
class UiTableColumn {
  const UiTableColumn({
    required this.label,
    this.width,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  });

  final String label;

  /// Fixed width. If null, uses [flex].
  final double? width;

  /// Flex factor when no fixed width is set.
  final int flex;

  final Alignment alignment;
}

/// A themed data table.
///
/// ```dart
/// UiTable(
///   columns: [
///     UiTableColumn(label: 'Name'),
///     UiTableColumn(label: 'Age', width: 80),
///   ],
///   rows: [
///     [Text('Alice'), Text('30')],
///     [Text('Bob'), Text('25')],
///   ],
/// )
/// ```
class UiTable extends StatelessWidget {
  const UiTable({
    super.key,
    required this.columns,
    required this.rows,
    this.striped = true,
    this.showHeader = true,
    this.onRowTap,
  });

  final List<UiTableColumn> columns;
  final List<List<Widget>> rows;

  /// Alternating row background colors.
  final bool striped;

  final bool showHeader;

  /// Called when a row is tapped, with the row index.
  final ValueChanged<int>? onRowTap;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Container(
      decoration: BoxDecoration(
        borderRadius: spacing.radiusMd,
        border: Border.all(color: colors.border, width: theme.borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          if (showHeader)
            Container(
              color: colors.surface,
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
              child: Row(
                children: [
                  for (int i = 0; i < columns.length; i++)
                    _buildCell(
                      columns[i],
                      Align(
                        alignment: columns[i].alignment,
                        child: Text(
                          columns[i].label,
                          style: typo.labelMedium.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (showHeader)
            Container(
              height: theme.borderWidth,
              color: colors.border,
            ),
          // Rows
          for (int rowIndex = 0; rowIndex < rows.length; rowIndex++)
            GestureDetector(
              onTap: onRowTap != null ? () => onRowTap!(rowIndex) : null,
              child: MouseRegion(
                cursor: onRowTap != null
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                child: Container(
                  color: striped && rowIndex.isOdd
                      ? colors.surface.withValues(alpha: 0.5)
                      : const Color(0x00000000),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.sm,
                  ),
                  child: Row(
                    children: [
                      for (int colIndex = 0;
                          colIndex < columns.length && colIndex < rows[rowIndex].length;
                          colIndex++)
                        _buildCell(
                          columns[colIndex],
                          DefaultTextStyle(
                            style: typo.bodyMedium.copyWith(
                              color: colors.onBackground,
                            ),
                            child: Align(
                              alignment: columns[colIndex].alignment,
                              child: rows[rowIndex][colIndex],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCell(UiTableColumn column, Widget child) {
    if (column.width != null) {
      return SizedBox(width: column.width, child: child);
    }
    return Expanded(flex: column.flex, child: child);
  }
}
