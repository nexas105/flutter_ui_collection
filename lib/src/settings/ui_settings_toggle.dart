import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A settings tile with a toggle switch on the right.
///
/// Uses the theme's primary color when on and border color when off.
///
/// ```dart
/// UiSettingsToggle(
///   title: 'Dark Mode',
///   subtitle: 'Use dark theme',
///   value: isDark,
///   onChanged: (v) => setState(() => isDark = v),
/// )
/// ```
class UiSettingsToggle extends StatefulWidget {
  const UiSettingsToggle({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  /// Optional leading icon.
  final IconData? leading;

  /// Primary text label.
  final String title;

  /// Secondary description text.
  final String? subtitle;

  /// Current toggle state.
  final bool value;

  /// Called when the toggle is changed.
  final ValueChanged<bool>? onChanged;

  /// Whether the toggle is interactive.
  final bool enabled;

  @override
  State<UiSettingsToggle> createState() => _UiSettingsToggleState();
}

class _UiSettingsToggleState extends State<UiSettingsToggle> {
  bool _hovered = false;

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

    // Toggle dimensions
    const double toggleSize = 22.0;
    final trackWidth = toggleSize * 1.8;
    final trackHeight = toggleSize;
    final thumbSize = toggleSize * 0.75;
    final thumbPadding = (trackHeight - thumbSize) / 2;

    final trackColor = widget.value ? colors.primary : colors.border;
    final thumbColor = widget.value ? colors.onPrimary : colors.onSurface;

    final glow = widget.value
        ? theme.surfaceShadows(accent: colors.primary)
        : null;

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: _interactive ? () => widget.onChanged!(!widget.value) : null,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: typo.bodyMedium.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: typo.bodySmall.copyWith(
                            color: colors.resolvedOnSurfaceMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: spacing.sm),
                // Inline toggle
                AnimatedContainer(
                  duration: theme.animationDuration,
                  curve: theme.animationCurve,
                  width: trackWidth,
                  height: trackHeight,
                  decoration: BoxDecoration(
                    color: _interactive
                        ? trackColor
                        : trackColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(trackHeight / 2),
                    boxShadow: glow,
                  ),
                  child: AnimatedAlign(
                    duration: theme.animationDuration,
                    curve: theme.animationCurve,
                    alignment: widget.value
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(thumbPadding),
                      child: Container(
                        width: thumbSize,
                        height: thumbSize,
                        decoration: BoxDecoration(
                          color: thumbColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
