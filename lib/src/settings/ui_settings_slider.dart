import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A settings tile with a slider control.
///
/// Displays the title and current value label on top, with a
/// draggable slider below. Snaps to divisions if provided.
///
/// ```dart
/// UiSettingsSlider(
///   title: 'Font Size',
///   value: fontSize,
///   min: 12,
///   max: 24,
///   divisions: 6,
///   valueLabel: (v) => '${v.round()}px',
///   onChanged: (v) => setState(() => fontSize = v),
/// )
/// ```
class UiSettingsSlider extends StatefulWidget {
  const UiSettingsSlider({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.valueLabel,
    this.enabled = true,
  });

  /// Label displayed above the slider.
  final String title;

  /// Current value between [min] and [max].
  final double value;

  /// Called when the slider value changes.
  final ValueChanged<double>? onChanged;

  /// Minimum slider value.
  final double min;

  /// Maximum slider value.
  final double max;

  /// Number of discrete divisions. If null, the slider is continuous.
  final int? divisions;

  /// Custom label formatter for the current value.
  final String Function(double)? valueLabel;

  /// Whether the slider is interactive.
  final bool enabled;

  @override
  State<UiSettingsSlider> createState() => _UiSettingsSliderState();
}

class _UiSettingsSliderState extends State<UiSettingsSlider> {
  bool _dragging = false;

  double get _fraction =>
      ((widget.value - widget.min) / (widget.max - widget.min))
          .clamp(0.0, 1.0);

  void _updateValue(double localX, double trackWidth) {
    if (!widget.enabled || widget.onChanged == null) return;
    var fraction = (localX / trackWidth).clamp(0.0, 1.0);
    if (widget.divisions != null && widget.divisions! > 0) {
      fraction =
          (fraction * widget.divisions!).roundToDouble() / widget.divisions!;
    }
    final newValue = widget.min + fraction * (widget.max - widget.min);
    widget.onChanged!(newValue);
  }

  String get _label {
    if (widget.valueLabel != null) {
      return widget.valueLabel!(widget.value);
    }
    return widget.max >= 100
        ? widget.value.round().toString()
        : widget.value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    const double trackHeight = 6.0;
    const double thumbSize = 20.0;

    List<BoxShadow>? thumbGlow;
    if ((_dragging || theme.useGlow) && colors.glow != null) {
      thumbGlow = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: _dragging ? 0.5 : 0.2),
          blurRadius: _dragging ? 14 : 8,
        ),
      ];
    }

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm + spacing.xs / 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title + value label row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: typo.bodyMedium.copyWith(color: colors.onSurface),
                ),
                Text(
                  _label,
                  style: typo.labelMedium.copyWith(color: colors.primary),
                ),
              ],
            ),
            SizedBox(height: spacing.sm),
            // Slider
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
                        : SystemMouseCursors.basic,
                    child: SizedBox(
                      height: thumbSize,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        clipBehavior: Clip.none,
                        children: [
                          // Track background
                          Container(
                            height: trackHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colors.border,
                              borderRadius:
                                  BorderRadius.circular(trackHeight / 2),
                            ),
                          ),
                          // Active track
                          FractionallySizedBox(
                            widthFactor: _fraction,
                            child: Container(
                              height: trackHeight,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius:
                                    BorderRadius.circular(trackHeight / 2),
                              ),
                            ),
                          ),
                          // Thumb
                          Positioned(
                            left: _fraction * (trackWidth - thumbSize),
                            child: AnimatedContainer(
                              duration: theme.animationDuration,
                              width: thumbSize,
                              height: thumbSize,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: colors.surface, width: 2),
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
      ),
    );
  }
}
