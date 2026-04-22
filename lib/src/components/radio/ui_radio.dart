import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed radio button.
///
/// ```dart
/// UiRadio<String>(
///   value: 'dark',
///   groupValue: _selectedTheme,
///   onChanged: (v) => setState(() => _selectedTheme = v),
///   label: 'Dark Mode',
/// )
/// ```
class UiRadio<T> extends StatefulWidget {
  const UiRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.size = 22.0,
    this.enabled = true,
  });

  /// The value this radio represents.
  final T value;

  /// The currently selected value in the group.
  final T? groupValue;

  final ValueChanged<T>? onChanged;
  final String? label;
  final double size;
  final bool enabled;

  bool get _selected => value == groupValue;

  @override
  State<UiRadio<T>> createState() => _UiRadioState<T>();
}

class _UiRadioState<T> extends State<UiRadio<T>> {
  bool _hovered = false;

  void _select() {
    if (!widget.enabled || widget.onChanged == null) return;
    widget.onChanged!(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final borderColor = widget._selected ? colors.primary : colors.border;
    final bgColor = _hovered && !widget._selected
        ? colors.primary.withValues(alpha: 0.08)
        : const Color(0x00000000);

    List<BoxShadow>? glow;
    if (widget._selected && theme.useGlow && colors.glow != null) {
      glow = [BoxShadow(color: colors.glow!.withValues(alpha: 0.25), blurRadius: 8)];
    }

    final radio = GestureDetector(
      onTap: _select,
      child: MouseRegion(
        cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          child: AnimatedContainer(
            duration: theme.animationDuration,
            curve: theme.animationCurve,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: widget._selected ? theme.borderWidth + 1 : theme.borderWidth,
              ),
              boxShadow: glow,
            ),
            child: widget._selected
                ? Center(
                    child: AnimatedContainer(
                      duration: theme.animationDuration,
                      width: widget.size * 0.45,
                      height: widget.size * 0.45,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );

    if (widget.label == null) return radio;

    return GestureDetector(
      onTap: _select,
      child: MouseRegion(
        cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            radio,
            SizedBox(width: spacing.sm),
            Flexible(
              child: Text(
                widget.label!,
                style: typo.bodyMedium.copyWith(
                  color: widget.enabled ? colors.onBackground : colors.onBackground.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
