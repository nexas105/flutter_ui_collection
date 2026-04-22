import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// A simple time-of-day representation without Material dependency.
class UiTimeOfDay {
  const UiTimeOfDay({required this.hour, required this.minute});

  final int hour;
  final int minute;

  String format({bool use24Hour = true}) {
    if (use24Hour) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UiTimeOfDay && hour == other.hour && minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}

/// A themed time picker that opens a popup with hour and minute columns.
///
/// ```dart
/// UiTimePicker(
///   value: _selectedTime,
///   onChanged: (time) => setState(() => _selectedTime = time),
///   label: 'Meeting time',
/// )
/// ```
class UiTimePicker extends StatefulWidget {
  const UiTimePicker({
    super.key,
    this.value,
    required this.onChanged,
    this.label,
    this.placeholder,
    this.use24Hour = true,
    this.minuteInterval = 1,
    this.enabled = true,
  });

  final UiTimeOfDay? value;
  final ValueChanged<UiTimeOfDay> onChanged;
  final String? label;
  final String? placeholder;
  final bool use24Hour;
  final int minuteInterval;
  final bool enabled;

  @override
  State<UiTimePicker> createState() => _UiTimePickerState();
}

class _UiTimePickerState extends State<UiTimePicker> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggle() {
    if (!widget.enabled) return;
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    final theme = UiTheme.of(context);
    final renderBox = context.findRenderObject()! as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _TimePickerOverlay(
        link: _layerLink,
        width: size.width < 200 ? 200 : size.width,
        theme: theme,
        value: widget.value,
        use24Hour: widget.use24Hour,
        minuteInterval: widget.minuteInterval,
        onSelect: (time) {
          widget.onChanged(time);
          _close();
        },
        onDismiss: _close,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final borderColor = _isOpen ? colors.primary : colors.border;
    final opacity = widget.enabled ? 1.0 : 0.5;

    List<BoxShadow>? shadows;
    if (_isOpen && theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(color: colors.glow!.withValues(alpha: 0.2), blurRadius: 8),
      ];
    }

    final displayText = widget.value != null
        ? widget.value!.format(use24Hour: widget.use24Hour)
        : (widget.placeholder ?? '');
    final displayColor = widget.value != null
        ? colors.onSurface
        : colors.onSurface.withValues(alpha: 0.5);

    return Opacity(
      opacity: opacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.xs),
              child: Text(
                widget.label!,
                style: typo.labelMedium.copyWith(color: colors.onSurface),
              ),
            ),
          CompositedTransformTarget(
            link: _layerLink,
            child: GestureDetector(
              onTap: _toggle,
              child: MouseRegion(
                cursor: widget.enabled
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.forbidden,
                child: AnimatedContainer(
                  duration: theme.animationDuration,
                  curve: theme.animationCurve,
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: spacing.radiusMd,
                    border: Border.all(
                      color: borderColor,
                      width: theme.borderWidth,
                    ),
                    boxShadow: shadows,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayText,
                          style: typo.bodyMedium.copyWith(color: displayColor),
                        ),
                      ),
                      SizedBox(width: spacing.xs),
                      Text(
                        '\u{1F552}',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimePickerOverlay extends StatefulWidget {
  const _TimePickerOverlay({
    required this.link,
    required this.width,
    required this.theme,
    required this.value,
    required this.use24Hour,
    required this.minuteInterval,
    required this.onSelect,
    required this.onDismiss,
  });

  final LayerLink link;
  final double width;
  final UiThemeData theme;
  final UiTimeOfDay? value;
  final bool use24Hour;
  final int minuteInterval;
  final ValueChanged<UiTimeOfDay> onSelect;
  final VoidCallback onDismiss;

  @override
  State<_TimePickerOverlay> createState() => _TimePickerOverlayState();
}

class _TimePickerOverlayState extends State<_TimePickerOverlay> {
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.value?.hour ?? 0;
    _selectedMinute = widget.value?.minute ?? 0;
  }

  int get _maxHour => widget.use24Hour ? 23 : 12;
  int get _minHour => widget.use24Hour ? 0 : 1;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    List<BoxShadow>? shadows;
    if (theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.15),
          blurRadius: 16,
        ),
      ];
    } else if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.shadow,
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
    }

    final hours = List.generate(
      _maxHour - _minHour + 1,
      (i) => _minHour + i,
    );
    final minutes = List.generate(
      60 ~/ widget.minuteInterval,
      (i) => i * widget.minuteInterval,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onDismiss,
      child: SizedBox.expand(
        child: CompositedTransformFollower(
          link: widget.link,
          offset: Offset(0, spacing.xs),
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          child: Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: widget.width,
                constraints: const BoxConstraints(maxHeight: 280),
                padding: spacing.paddingMd,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: spacing.radiusMd,
                  border: Border.all(
                    color: colors.border,
                    width: theme.borderWidth,
                  ),
                  boxShadow: shadows,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'Hour',
                              style: typo.labelMedium.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Minute',
                              style: typo.labelMedium.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.sm),
                    // Columns
                    SizedBox(
                      height: 200,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hours column
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: hours.length,
                              itemBuilder: (context, index) {
                                final hour = hours[index];
                                final isSelected = hour == _selectedHour;
                                return _buildTimeCell(
                                  label: hour.toString().padLeft(2, '0'),
                                  isSelected: isSelected,
                                  theme: theme,
                                  onTap: () {
                                    setState(() => _selectedHour = hour);
                                    widget.onSelect(UiTimeOfDay(
                                      hour: _selectedHour,
                                      minute: _selectedMinute,
                                    ));
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(width: spacing.sm),
                          // Minutes column
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: minutes.length,
                              itemBuilder: (context, index) {
                                final minute = minutes[index];
                                final isSelected = minute == _selectedMinute;
                                return _buildTimeCell(
                                  label: minute.toString().padLeft(2, '0'),
                                  isSelected: isSelected,
                                  theme: theme,
                                  onTap: () {
                                    setState(() => _selectedMinute = minute);
                                    widget.onSelect(UiTimeOfDay(
                                      hour: _selectedHour,
                                      minute: _selectedMinute,
                                    ));
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCell({
    required String label,
    required bool isSelected,
    required UiThemeData theme,
    required VoidCallback onTap,
  }) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    List<BoxShadow>? shadows;
    if (isSelected && theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.4),
          blurRadius: 6,
        ),
      ];
    }

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: spacing.xs,
            horizontal: spacing.sm,
          ),
          margin: EdgeInsets.only(bottom: spacing.xs / 2),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : const Color(0x00000000),
            borderRadius: spacing.radiusSm,
            boxShadow: shadows,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: typo.bodyMedium.copyWith(
              color: isSelected ? colors.onPrimary : colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
