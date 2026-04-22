import 'package:flutter/widgets.dart';

import '../../theme/ui_color_scheme.dart';
import '../../theme/ui_spacing.dart';
import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';
import '../../theme/ui_typography.dart';

/// A themed date picker that opens an inline calendar popup.
///
/// ```dart
/// UiDatePicker(
///   value: _selectedDate,
///   onChanged: (date) => setState(() => _selectedDate = date),
///   label: 'Start date',
///   placeholder: 'Select date...',
/// )
/// ```
class UiDatePicker extends StatefulWidget {
  const UiDatePicker({
    super.key,
    this.value,
    required this.onChanged,
    this.label,
    this.placeholder,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? label;
  final String? placeholder;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  @override
  State<UiDatePicker> createState() => _UiDatePickerState();
}

class _UiDatePickerState extends State<UiDatePicker> {
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
      builder: (context) => _DatePickerOverlay(
        link: _layerLink,
        width: size.width < 280 ? 280 : size.width,
        theme: theme,
        value: widget.value,
        firstDate: widget.firstDate ?? DateTime(1900),
        lastDate: widget.lastDate ?? DateTime(2100),
        onSelect: (date) {
          widget.onChanged(date);
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

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
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
        ? _formatDate(widget.value!)
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
                        '\u{1F4C5}',
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

class _DatePickerOverlay extends StatefulWidget {
  const _DatePickerOverlay({
    required this.link,
    required this.width,
    required this.theme,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onSelect,
    required this.onDismiss,
  });

  final LayerLink link;
  final double width;
  final UiThemeData theme;
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onDismiss;

  @override
  State<_DatePickerOverlay> createState() => _DatePickerOverlayState();
}

class _DatePickerOverlayState extends State<_DatePickerOverlay> {
  late int _displayedMonth;
  late int _displayedYear;

  @override
  void initState() {
    super.initState();
    final initial = widget.value ?? DateTime.now();
    _displayedMonth = initial.month;
    _displayedYear = initial.year;
  }

  void _previousMonth() {
    setState(() {
      if (_displayedMonth == 1) {
        _displayedMonth = 12;
        _displayedYear--;
      } else {
        _displayedMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_displayedMonth == 12) {
        _displayedMonth = 1;
        _displayedYear++;
      } else {
        _displayedMonth++;
      }
    });
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _firstWeekdayOfMonth(int year, int month) {
    // Monday = 1, Sunday = 7
    return DateTime(year, month, 1).weekday;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static const _dayHeaders = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

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

    final daysInMonth = _daysInMonth(_displayedYear, _displayedMonth);
    final firstWeekday = _firstWeekdayOfMonth(_displayedYear, _displayedMonth);
    // firstWeekday: 1=Monday. Offset so Monday is column 0.
    final startOffset = firstWeekday - 1;

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
              onTap: () {}, // absorb taps inside calendar
              child: Container(
                width: widget.width,
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
                    // Month/year navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _previousMonth,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Padding(
                              padding: EdgeInsets.all(spacing.xs),
                              child: Text(
                                '\u25C0',
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${_monthNames[_displayedMonth - 1]} $_displayedYear',
                          style: typo.titleSmall.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                        GestureDetector(
                          onTap: _nextMonth,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Padding(
                              padding: EdgeInsets.all(spacing.xs),
                              child: Text(
                                '\u25B6',
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.sm),
                    // Day headers
                    Row(
                      children: _dayHeaders.map((d) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: typo.labelSmall.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: spacing.xs),
                    // Day grid
                    _buildDayGrid(
                      daysInMonth: daysInMonth,
                      startOffset: startOffset,
                      colors: colors,
                      spacing: spacing,
                      typo: typo,
                      theme: theme,
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

  Widget _buildDayGrid({
    required int daysInMonth,
    required int startOffset,
    required UiColorScheme colors,
    required UiSpacing spacing,
    required UiTypography typo,
    required UiThemeData theme,
  }) {
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final index = row * 7 + col;
            if (index < startOffset || index >= startOffset + daysInMonth) {
              return const Expanded(child: SizedBox(height: 32));
            }

            final day = index - startOffset + 1;
            final date = DateTime(_displayedYear, _displayedMonth, day);
            final isSelected = widget.value != null &&
                _isSameDay(date, widget.value!);
            final isInRange = !date.isBefore(widget.firstDate) &&
                !date.isAfter(widget.lastDate);

            List<BoxShadow>? dayShadows;
            if (isSelected && theme.useGlow && colors.glow != null) {
              dayShadows = [
                BoxShadow(
                  color: colors.glow!.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ];
            }

            return Expanded(
              child: GestureDetector(
                onTap: isInRange ? () => widget.onSelect(date) : null,
                child: MouseRegion(
                  cursor: isInRange
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.basic,
                  child: Container(
                    height: 32,
                    margin: EdgeInsets.all(spacing.xs / 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary
                          : const Color(0x00000000),
                      borderRadius: spacing.radiusSm,
                      boxShadow: dayShadows,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: typo.bodySmall.copyWith(
                        color: isSelected
                            ? colors.onPrimary
                            : isInRange
                                ? colors.onSurface
                                : colors.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
