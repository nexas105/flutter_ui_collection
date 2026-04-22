import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// A themed monthly calendar widget.
///
/// ```dart
/// UiCalendar(
///   selectedDate: _selectedDate,
///   onDateSelected: (d) => setState(() => _selectedDate = d),
///   markedDates: {DateTime(2026, 4, 15), DateTime(2026, 4, 22)},
/// )
/// ```
class UiCalendar extends StatefulWidget {
  const UiCalendar({
    super.key,
    this.selectedDate,
    this.onDateSelected,
    this.initialMonth,
    this.markedDates = const {},
    this.firstDayOfWeek = DateTime.monday,
    this.dayLabels = const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  /// Initial displayed month. Defaults to today's month.
  final DateTime? initialMonth;

  /// Dates to show with a dot indicator.
  final Set<DateTime> markedDates;

  /// First day of the week (1 = Monday, 7 = Sunday).
  final int firstDayOfWeek;

  /// Day header labels.
  final List<String> dayLabels;

  @override
  State<UiCalendar> createState() => _UiCalendarState();
}

class _UiCalendarState extends State<UiCalendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final now = widget.initialMonth ?? widget.selectedDate ?? DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isMarked(DateTime date) =>
      widget.markedDates.any((d) => _isSameDay(d, date));

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final today = DateTime.now();
    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;

    // Day of week for the 1st (adjusted for firstDayOfWeek)
    final firstWeekday = DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday;
    final startOffset = (firstWeekday - widget.firstDayOfWeek + 7) % 7;

    // Month name
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final monthLabel = '${months[_displayedMonth.month - 1]} ${_displayedMonth.year}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Month navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _previousMonth,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: EdgeInsets.all(spacing.xs),
                  child: Icon(
                    const IconData(0xe14b, fontFamily: 'MaterialIcons'),
                    size: 20,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
            Text(monthLabel, style: typo.titleSmall.copyWith(color: colors.onSurface)),
            GestureDetector(
              onTap: _nextMonth,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: EdgeInsets.all(spacing.xs),
                  child: Icon(
                    const IconData(0xe14f, fontFamily: 'MaterialIcons'),
                    size: 20,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.sm),

        // Day headers
        Row(
          children: [
            for (final label in widget.dayLabels)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: typo.labelSmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: spacing.xs),

        // Day grid
        for (int week = 0; week < 6; week++) ...[
          Row(
            children: [
              for (int weekday = 0; weekday < 7; weekday++) ...[
                Expanded(
                  child: _buildDay(
                    week * 7 + weekday - startOffset + 1,
                    daysInMonth,
                    today,
                    theme,
                  ),
                ),
              ],
            ],
          ),
          // Stop if we've passed all days
          if ((week + 1) * 7 - startOffset >= daysInMonth && week >= 3)
            ...[],
        ],
      ],
    );
  }

  Widget _buildDay(
    int day,
    int daysInMonth,
    DateTime today,
    UiThemeData theme,
  ) {
    final colors = theme.colorScheme;
    final typo = theme.typography;

    if (day < 1 || day > daysInMonth) {
      return const SizedBox(height: 36);
    }

    final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
    final isToday = _isSameDay(date, today);
    final isSelected =
        widget.selectedDate != null && _isSameDay(date, widget.selectedDate!);
    final isMarked = _isMarked(date);

    List<BoxShadow>? glow;
    if (isSelected && theme.useGlow && colors.glow != null) {
      glow = [BoxShadow(color: colors.glow!.withValues(alpha: 0.3), blurRadius: 6)];
    }

    return GestureDetector(
      onTap: widget.onDateSelected != null ? () => widget.onDateSelected!(date) : null,
      child: MouseRegion(
        cursor: widget.onDateSelected != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: SizedBox(
          height: 36,
          child: Center(
            child: AnimatedContainer(
              duration: theme.animationDuration,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary
                    : (isToday ? colors.primary.withValues(alpha: 0.1) : null),
                shape: BoxShape.circle,
                border: isToday && !isSelected
                    ? Border.all(color: colors.primary, width: 1)
                    : null,
                boxShadow: glow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: typo.bodySmall.copyWith(
                      color: isSelected
                          ? colors.onPrimary
                          : colors.onSurface,
                      fontWeight: isToday ? FontWeight.w700 : null,
                    ),
                  ),
                  if (isMarked && !isSelected)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
