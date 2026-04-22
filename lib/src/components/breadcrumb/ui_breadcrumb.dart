import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A single item in a [UiBreadcrumb].
class UiBreadcrumbItem {
  const UiBreadcrumbItem({
    required this.label,
    this.onTap,
  });

  /// The display label for this breadcrumb.
  final String label;

  /// Called when the item is tapped. If `null`, the item is not interactive.
  final VoidCallback? onTap;
}

/// Breadcrumb navigation showing a trail of tappable links.
///
/// ```dart
/// UiBreadcrumb(
///   items: [
///     UiBreadcrumbItem(label: 'Home', onTap: () {}),
///     UiBreadcrumbItem(label: 'Products', onTap: () {}),
///     UiBreadcrumbItem(label: 'Widget'),
///   ],
/// )
/// ```
class UiBreadcrumb extends StatelessWidget {
  const UiBreadcrumb({
    super.key,
    required this.items,
    this.separator = '/',
  });

  /// The breadcrumb items. The last item is displayed as the current page.
  final List<UiBreadcrumbItem> items;

  /// The separator string between items.
  final String separator;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final separatorStyle = typo.bodySmall.copyWith(
      color: colors.onSurface.withValues(alpha: 0.4),
    );

    final children = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      if (isLast) {
        children.add(
          Text(
            item.label,
            style: typo.bodySmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        children.add(
          _BreadcrumbLink(
            label: item.label,
            onTap: item.onTap,
          ),
        );
        children.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.xs),
            child: Text(separator, style: separatorStyle),
          ),
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _BreadcrumbLink extends StatefulWidget {
  const _BreadcrumbLink({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  State<_BreadcrumbLink> createState() => _BreadcrumbLinkState();
}

class _BreadcrumbLinkState extends State<_BreadcrumbLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final typo = theme.typography;

    final isInteractive = widget.onTap != null;

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: isInteractive
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Text(
          widget.label,
          style: typo.bodySmall.copyWith(
            color: isInteractive
                ? (_hovered
                    ? colors.primary.withValues(alpha: 0.7)
                    : colors.primary)
                : colors.onSurface.withValues(alpha: 0.6),
            decoration:
                _hovered && isInteractive ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }
}
