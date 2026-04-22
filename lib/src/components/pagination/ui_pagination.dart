import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed pagination control with page numbers and navigation arrows.
///
/// ```dart
/// UiPagination(
///   currentPage: 3,
///   totalPages: 10,
///   onPageChanged: (page) => setState(() => _page = page),
/// )
/// ```
class UiPagination extends StatelessWidget {
  const UiPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.maxVisiblePages = 5,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final int maxVisiblePages;

  List<int?> _buildPageNumbers() {
    if (totalPages <= maxVisiblePages) {
      return List.generate(totalPages, (i) => i + 1);
    }

    final pages = <int?>[];
    final half = maxVisiblePages ~/ 2;

    int start = currentPage - half;
    int end = currentPage + half;

    if (start < 1) {
      start = 1;
      end = maxVisiblePages;
    }
    if (end > totalPages) {
      end = totalPages;
      start = totalPages - maxVisiblePages + 1;
    }

    if (start > 1) {
      pages.add(1);
      if (start > 2) pages.add(null); // ellipsis
    }

    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    if (end < totalPages) {
      if (end < totalPages - 1) pages.add(null); // ellipsis
      pages.add(totalPages);
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final canGoPrevious = currentPage > 1;
    final canGoNext = currentPage < totalPages;
    final pages = _buildPageNumbers();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous button
        _PageButton(
          enabled: canGoPrevious,
          isSelected: false,
          onTap: () => onPageChanged(currentPage - 1),
          child: Text(
            '\u25C0',
            style: TextStyle(
              fontSize: 10,
              color: canGoPrevious
                  ? colors.onSurface
                  : colors.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ),
        SizedBox(width: spacing.xs),
        // Page numbers
        ...pages.map((page) {
          if (page == null) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.xs),
              child: Text(
                '\u2026',
                style: typo.bodySmall.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.only(right: spacing.xs),
            child: _PageButton(
              enabled: true,
              isSelected: page == currentPage,
              onTap: () {
                if (page != currentPage) onPageChanged(page);
              },
              child: Text(
                '$page',
                style: typo.bodySmall.copyWith(
                  color: page == currentPage
                      ? colors.onPrimary
                      : colors.onSurface,
                ),
              ),
            ),
          );
        }),
        // Next button
        _PageButton(
          enabled: canGoNext,
          isSelected: false,
          onTap: () => onPageChanged(currentPage + 1),
          child: Text(
            '\u25B6',
            style: TextStyle(
              fontSize: 10,
              color: canGoNext
                  ? colors.onSurface
                  : colors.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageButton extends StatefulWidget {
  const _PageButton({
    required this.child,
    required this.enabled,
    required this.isSelected,
    required this.onTap,
  });

  final Widget child;
  final bool enabled;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_PageButton> createState() => _PageButtonState();
}

class _PageButtonState extends State<_PageButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    Color bgColor;
    if (widget.isSelected) {
      bgColor = colors.primary;
    } else if (_hovered && widget.enabled) {
      bgColor = colors.onSurface.withValues(alpha: 0.08);
    } else {
      bgColor = const Color(0x00000000);
    }

    List<BoxShadow>? shadows;
    if (widget.isSelected && theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.5),
          blurRadius: 8,
        ),
      ];
    }

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: spacing.radiusSm,
            border: widget.isSelected
                ? null
                : Border.all(
                    color: colors.border.withValues(alpha: 0.3),
                    width: theme.borderWidth,
                  ),
            boxShadow: shadows,
          ),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
