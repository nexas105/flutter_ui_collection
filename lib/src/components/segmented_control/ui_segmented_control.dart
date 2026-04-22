import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// An iOS-style segmented control with an animated sliding highlight.
///
/// ```dart
/// UiSegmentedControl(
///   segments: ['Day', 'Week', 'Month'],
///   selectedIndex: _index,
///   onChanged: (i) => setState(() => _index = i),
/// )
/// ```
class UiSegmentedControl extends StatefulWidget {
  const UiSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    this.expand = true,
  });

  /// The labels for each segment.
  final List<String> segments;

  /// The index of the currently selected segment.
  final int selectedIndex;

  /// Called when the user taps a segment.
  final ValueChanged<int> onChanged;

  /// Whether the control should expand to fill the available width.
  final bool expand;

  @override
  State<UiSegmentedControl> createState() => _UiSegmentedControlState();
}

class _UiSegmentedControlState extends State<UiSegmentedControl> {
  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    List<BoxShadow>? highlightShadows;
    if (theme.useGlow && colors.glow != null) {
      highlightShadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.25),
          blurRadius: 8,
        ),
      ];
    } else if (theme.useShadows) {
      highlightShadows = [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.15),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: spacing.radiusMd,
        border: Border.all(color: colors.border, width: theme.borderWidth),
      ),
      padding: EdgeInsets.all(spacing.xs / 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentCount = widget.segments.length;
          final segmentWidth = widget.expand
              ? (constraints.maxWidth - spacing.xs) / segmentCount
              : null;

          return Stack(
            children: [
              // Animated highlight
              AnimatedPositioned(
                duration: theme.animationDuration,
                curve: theme.animationCurve,
                left: segmentWidth != null
                    ? widget.selectedIndex * segmentWidth
                    : null,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(
                      spacing.borderRadiusMd - 2,
                    ),
                    boxShadow: highlightShadows,
                  ),
                ),
              ),
              // Segments
              Row(
                mainAxisSize:
                    widget.expand ? MainAxisSize.max : MainAxisSize.min,
                children: List.generate(segmentCount, (index) {
                  final isSelected = index == widget.selectedIndex;
                  return Expanded(
                    flex: widget.expand ? 1 : 0,
                    child: GestureDetector(
                      onTap: () => widget.onChanged(index),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          color: const Color(0x00000000),
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.md,
                            vertical: spacing.sm,
                          ),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: theme.animationDuration,
                              curve: theme.animationCurve,
                              style: typo.labelMedium.copyWith(
                                color: isSelected
                                    ? colors.onPrimary
                                    : colors.onSurface,
                              ),
                              child: Text(widget.segments[index]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
