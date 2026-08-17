import 'package:flutter/widgets.dart';

import '../../interaction/ui_interactive_region.dart';
import '../../theme/ui_theme.dart';

/// A themed slider for selecting a value from a range.
///
/// ```dart
/// UiSlider(
///   value: _volume,
///   onChanged: (v) => setState(() => _volume = v),
///   label: 'Volume',
/// )
/// ```
class UiSlider extends StatefulWidget {
  const UiSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.label,
    this.showValue = false,
    this.height = 6.0,
    this.thumbSize = 20.0,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
  });

  /// Current value between [min] and [max].
  final double value;

  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final String? label;

  /// Show the current value as text.
  final bool showValue;

  /// Track height.
  final double height;

  /// Thumb diameter.
  final double thumbSize;

  final bool enabled;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<UiSlider> createState() => _UiSliderState();
}

class _UiSliderState extends State<UiSlider> {
  bool _dragging = false;

  double get _fraction =>
      ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  void _updateValue(double localX, double trackWidth) {
    if (!widget.enabled || widget.onChanged == null) return;
    final fraction = (localX / trackWidth).clamp(0.0, 1.0);
    final newValue = widget.min + fraction * (widget.max - widget.min);
    widget.onChanged!(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    List<BoxShadow>? thumbGlow;
    if ((_dragging || theme.useGlow) && colors.glow != null) {
      thumbGlow = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: _dragging ? 0.5 : 0.2),
          blurRadius: _dragging ? 14 : 8,
        ),
      ];
    }

    final control = Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null || widget.showValue)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.label != null)
                    Text(
                      widget.label!,
                      style: typo.labelMedium.copyWith(
                        color: colors.onBackground,
                      ),
                    ),
                  if (widget.showValue)
                    Text(
                      widget.value.toStringAsFixed(widget.max >= 100 ? 0 : 1),
                      style: typo.labelMedium.copyWith(color: colors.primary),
                    ),
                ],
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              return GestureDetector(
                onHorizontalDragStart: widget.enabled
                    ? (d) {
                        setState(() => _dragging = true);
                        _updateValue(d.localPosition.dx, trackWidth);
                      }
                    : null,
                onHorizontalDragUpdate: widget.enabled
                    ? (d) => _updateValue(d.localPosition.dx, trackWidth)
                    : null,
                onHorizontalDragEnd: widget.enabled
                    ? (_) => setState(() => _dragging = false)
                    : null,
                onTapDown: widget.enabled
                    ? (d) => _updateValue(d.localPosition.dx, trackWidth)
                    : null,
                child: MouseRegion(
                  cursor: widget.enabled
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.forbidden,
                  child: SizedBox(
                    height: widget.thumbSize,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      clipBehavior: Clip.none,
                      children: [
                        // Track background
                        Container(
                          height: widget.height,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colors.border,
                            borderRadius: BorderRadius.circular(
                              widget.height / 2,
                            ),
                          ),
                        ),
                        // Active track
                        FractionallySizedBox(
                          widthFactor: _fraction,
                          child: Container(
                            height: widget.height,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(
                                widget.height / 2,
                              ),
                            ),
                          ),
                        ),
                        // Thumb
                        Positioned(
                          left: (_fraction * (trackWidth - widget.thumbSize)),
                          child: AnimatedContainer(
                            duration: theme.animationDuration,
                            width: widget.thumbSize,
                            height: widget.thumbSize,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.surface,
                                width: 2,
                              ),
                              boxShadow: thumbGlow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

    final keyboardStep = (widget.max - widget.min) / 20;
    void changeBy(double delta) {
      if (!widget.enabled || widget.onChanged == null) return;
      widget.onChanged!((widget.value + delta).clamp(widget.min, widget.max));
    }

    String formatValue(double value) =>
        value.toStringAsFixed(widget.max >= 100 ? 0 : 1);

    return UiInteractiveRegion(
      enabled: widget.enabled && widget.onChanged != null,
      semanticLabel: widget.label,
      slider: true,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      value: formatValue(widget.value),
      increasedValue: formatValue(
        (widget.value + keyboardStep).clamp(widget.min, widget.max),
      ),
      decreasedValue: formatValue(
        (widget.value - keyboardStep).clamp(widget.min, widget.max),
      ),
      onIncrease: () => changeBy(keyboardStep),
      onDecrease: () => changeBy(-keyboardStep),
      borderRadius: theme.components.controlBorderRadius,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: control,
      ),
    );
  }
}
