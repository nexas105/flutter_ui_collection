import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed group of connected toggle buttons.
///
/// Supports single or multi-select mode.
///
/// ```dart
/// UiButtonGroup(
///   labels: ['Day', 'Week', 'Month'],
///   selectedIndex: 0,
///   onChanged: (index) { ... },
/// )
/// ```
class UiButtonGroup extends StatelessWidget {
  const UiButtonGroup({
    super.key,
    required this.labels,
    this.selectedIndex,
    this.onChanged,
    this.multiSelect = false,
    this.selectedIndices = const {},
    this.onMultiChanged,
  });

  final List<String> labels;

  /// Selected index for single-select mode.
  final int? selectedIndex;

  /// Callback for single-select mode.
  final void Function(int index)? onChanged;

  /// Enable multi-select mode.
  final bool multiSelect;

  /// Selected indices for multi-select mode.
  final Set<int> selectedIndices;

  /// Callback for multi-select mode.
  final void Function(Set<int> indices)? onMultiChanged;

  bool _isSelected(int index) {
    if (multiSelect) return selectedIndices.contains(index);
    return selectedIndex == index;
  }

  void _handleTap(int index) {
    if (multiSelect) {
      final next = Set<int>.from(selectedIndices);
      if (next.contains(index)) {
        next.remove(index);
      } else {
        next.add(index);
      }
      onMultiChanged?.call(next);
    } else {
      onChanged?.call(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final List<BoxShadow>? glowShadow = theme.useGlow && colors.glow != null
        ? [
            BoxShadow(
              color: colors.glow!.withValues(alpha: 0.15),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ]
        : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: spacing.radiusMd,
        border: Border.all(color: colors.border, width: theme.borderWidth),
        boxShadow: glowShadow,
      ),
      child: ClipRRect(
        borderRadius: spacing.radiusMd,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < labels.length; i++) ...[
              if (i > 0)
                Container(
                  width: theme.borderWidth,
                  height: 36,
                  color: colors.border,
                ),
              GestureDetector(
                onTap: () => _handleTap(i),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.sm,
                    ),
                    color: _isSelected(i)
                        ? colors.primary
                        : colors.surface,
                    child: Text(
                      labels[i],
                      style: typo.labelMedium.copyWith(
                        color: _isSelected(i)
                            ? colors.onPrimary
                            : colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
