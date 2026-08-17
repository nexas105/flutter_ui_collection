import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Represents a selectable option for [UiSettingsSelect].
class UiSettingsOption<T> {
  const UiSettingsOption({required this.value, required this.label, this.icon});

  /// The option's value.
  final T value;

  /// Display label for the option.
  final String label;

  /// Optional icon displayed before the label.
  final IconData? icon;
}

/// A settings tile that shows the current selection and expands
/// to reveal options when tapped.
///
/// ```dart
/// UiSettingsSelect<String>(
///   title: 'Language',
///   options: [
///     UiSettingsOption(value: 'en', label: 'English'),
///     UiSettingsOption(value: 'de', label: 'Deutsch'),
///   ],
///   value: selectedLang,
///   onChanged: (v) => setState(() => selectedLang = v),
/// )
/// ```
class UiSettingsSelect<T> extends StatefulWidget {
  const UiSettingsSelect({
    super.key,
    this.leading,
    required this.title,
    required this.options,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  /// Optional leading icon.
  final IconData? leading;

  /// Primary text label.
  final String title;

  /// Available options.
  final List<UiSettingsOption<T>> options;

  /// Currently selected value.
  final T value;

  /// Called when a new option is selected.
  final ValueChanged<T>? onChanged;

  /// Whether the select is interactive.
  final bool enabled;

  @override
  State<UiSettingsSelect<T>> createState() => _UiSettingsSelectState<T>();
}

class _UiSettingsSelectState<T> extends State<UiSettingsSelect<T>>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _hovered = false;

  String get _selectedLabel {
    for (final option in widget.options) {
      if (option.value == widget.value) return option.label;
    }
    return '';
  }

  bool get _interactive => widget.enabled && widget.onChanged != null;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final Color bgColor = _hovered && _interactive
        ? colors.onSurface.withValues(alpha: theme.components.subtleOpacity)
        : const Color(0x00000000);

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          GestureDetector(
            onTap: _interactive
                ? () => setState(() => _expanded = !_expanded)
                : null,
            child: MouseRegion(
              cursor: _interactive
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: AnimatedContainer(
                duration: theme.animationDuration,
                curve: theme.animationCurve,
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: spacing.sm + spacing.xs / 2,
                ),
                color: bgColor,
                child: Row(
                  children: [
                    if (widget.leading != null) ...[
                      Icon(widget.leading, size: 22, color: colors.primary),
                      SizedBox(width: spacing.md),
                    ],
                    Expanded(
                      child: Text(
                        widget.title,
                        style: typo.bodyMedium.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      _selectedLabel,
                      style: typo.bodySmall.copyWith(
                        color: colors.resolvedOnSurfaceMuted,
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    AnimatedRotation(
                      turns: _expanded ? 0.25 : 0.0,
                      duration: theme.animationDuration,
                      curve: theme.animationCurve,
                      child: Text(
                        '\u203A',
                        style: TextStyle(
                          fontSize: 22,
                          color: colors.resolvedOnSurfaceSubtle,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Options list
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: _buildOptionsList(context),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: theme.animationDuration,
            sizeCurve: theme.animationCurve,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList(BuildContext context) {
    final colors = UiTheme.of(context).colorScheme;
    return Container(
      color: colors.background.withValues(alpha: 0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in widget.options)
            _UiSettingsOptionTile<T>(
              option: option,
              selected: option.value == widget.value,
              onTap: () {
                widget.onChanged?.call(option.value);
                setState(() => _expanded = false);
              },
            ),
        ],
      ),
    );
  }
}

class _UiSettingsOptionTile<T> extends StatefulWidget {
  const _UiSettingsOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final UiSettingsOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_UiSettingsOptionTile<T>> createState() =>
      _UiSettingsOptionTileState<T>();
}

class _UiSettingsOptionTileState<T> extends State<_UiSettingsOptionTile<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final Color bgColor;
    if (widget.selected) {
      bgColor = colors.primary.withValues(alpha: theme.components.hoverOpacity);
    } else if (_hovered) {
      bgColor = colors.onSurface.withValues(
        alpha: theme.components.subtleOpacity,
      );
    } else {
      bgColor = const Color(0x00000000);
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md + spacing.lg,
            vertical: spacing.sm,
          ),
          color: bgColor,
          child: Row(
            children: [
              if (widget.option.icon != null) ...[
                Icon(
                  widget.option.icon,
                  size: 18,
                  color: widget.selected
                      ? colors.primary
                      : colors.resolvedOnSurfaceMuted,
                ),
                SizedBox(width: spacing.sm),
              ],
              Expanded(
                child: Text(
                  widget.option.label,
                  style: typo.bodyMedium.copyWith(
                    color: widget.selected ? colors.primary : colors.onSurface,
                    fontWeight: widget.selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              if (widget.selected)
                Text(
                  '\u2713', // checkmark
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
