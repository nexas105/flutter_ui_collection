import 'package:flutter/widgets.dart';

/// Defines a single item within a [UiResponsiveGrid].
///
/// [span] controls how many columns this item occupies at the
/// default (mobile) breakpoint. [tabletSpan] and [desktopSpan]
/// override the span at wider breakpoints.
class UiGridItem {
  const UiGridItem({
    required this.child,
    this.span = 12,
    this.tabletSpan,
    this.desktopSpan,
  });

  final Widget child;
  final int span;
  final int? tabletSpan;
  final int? desktopSpan;
}

/// A responsive column-based grid layout.
///
/// Uses [LayoutBuilder] to determine available width and assigns
/// item widths based on their span relative to [columns].
/// Breakpoints: mobile < 600, tablet < 1024, desktop >= 1024.
///
/// ```dart
/// UiResponsiveGrid(
///   children: [
///     UiGridItem(span: 12, tabletSpan: 6, desktopSpan: 4, child: Card()),
///     UiGridItem(span: 12, tabletSpan: 6, desktopSpan: 4, child: Card()),
///     UiGridItem(span: 12, tabletSpan: 12, desktopSpan: 4, child: Card()),
///   ],
/// )
/// ```
class UiResponsiveGrid extends StatelessWidget {
  const UiResponsiveGrid({
    super.key,
    required this.children,
    this.columns = 12,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  });

  final List<UiGridItem> children;
  final int columns;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((item) {
            final span = _resolveSpan(item, width);
            final clampedSpan = span.clamp(1, columns);
            // Total gap space in one full row.
            final gaps = spacing * (columns / clampedSpan - 1).clamp(0, columns - 1);
            final itemWidth =
                (width - gaps) * clampedSpan / columns;

            return SizedBox(
              width: itemWidth.clamp(0, width),
              child: item.child,
            );
          }).toList(),
        );
      },
    );
  }

  int _resolveSpan(UiGridItem item, double width) {
    if (width >= 1024 && item.desktopSpan != null) {
      return item.desktopSpan!;
    }
    if (width >= 600 && item.tabletSpan != null) {
      return item.tabletSpan!;
    }
    return item.span;
  }
}
