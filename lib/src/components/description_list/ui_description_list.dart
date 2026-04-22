import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Layout direction for description list items.
enum UiDescriptionListDirection { horizontal, vertical }

/// A single term/description pair for [UiDescriptionList].
class UiDescriptionItem {
  const UiDescriptionItem({
    required this.label,
    required this.value,
  });

  /// The label/term.
  final String label;

  /// The value/description, either a [String] or a [Widget].
  final dynamic value;
}

/// Displays a list of key-value pairs.
///
/// ```dart
/// UiDescriptionList(
///   items: [
///     UiDescriptionItem(label: 'Name', value: 'John Doe'),
///     UiDescriptionItem(label: 'Email', value: 'john@example.com'),
///   ],
/// )
/// ```
class UiDescriptionList extends StatelessWidget {
  const UiDescriptionList({
    super.key,
    required this.items,
    this.direction = UiDescriptionListDirection.horizontal,
    this.showDividers = true,
  });

  /// The key-value pairs to display.
  final List<UiDescriptionItem> items;

  /// Whether labels and values are side-by-side or stacked.
  final UiDescriptionListDirection direction;

  /// Whether to show dividers between items.
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final labelStyle = typo.labelMedium.copyWith(
      color: colors.onSurface.withValues(alpha: 0.6),
    );
    final valueStyle = typo.bodyMedium.copyWith(color: colors.onSurface);

    Widget buildValue(dynamic value) {
      if (value is Widget) return value;
      return Text('$value', style: valueStyle);
    }

    final children = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      if (i > 0 && showDividers) {
        children.add(Container(
          height: theme.borderWidth,
          color: colors.border.withValues(alpha: 0.3),
        ));
      }

      final item = items[i];
      final Widget row;

      if (direction == UiDescriptionListDirection.horizontal) {
        row = Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: Text(item.label, style: labelStyle),
              ),
              SizedBox(width: spacing.md),
              Expanded(child: buildValue(item.value)),
            ],
          ),
        );
      } else {
        row = Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label, style: labelStyle),
              SizedBox(height: spacing.xs),
              buildValue(item.value),
            ],
          ),
        );
      }

      children.add(row);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
