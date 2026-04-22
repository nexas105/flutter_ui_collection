import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A settings tile with a chevron arrow for navigation.
///
/// Optionally shows a badge (e.g. notification count) before the chevron.
///
/// ```dart
/// UiSettingsNavigation(
///   title: 'Notifications',
///   subtitle: 'Manage alerts and sounds',
///   badge: '3',
///   onTap: () => Navigator.push(...),
/// )
/// ```
class UiSettingsNavigation extends StatefulWidget {
  const UiSettingsNavigation({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
    this.badge,
    this.enabled = true,
  });

  /// Optional leading icon.
  final IconData? leading;

  /// Primary text label.
  final String title;

  /// Secondary description text.
  final String? subtitle;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  /// Optional badge text shown before the chevron (e.g. "3").
  final String? badge;

  /// Whether the tile is interactive.
  final bool enabled;

  @override
  State<UiSettingsNavigation> createState() => _UiSettingsNavigationState();
}

class _UiSettingsNavigationState extends State<UiSettingsNavigation> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final Color bgColor = _hovered && widget.enabled
        ? colors.onSurface.withValues(alpha: 0.04)
        : const Color(0x00000000);

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: MouseRegion(
          cursor: widget.enabled && widget.onTap != null
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
                  Icon(
                    widget.leading,
                    size: 22,
                    color: colors.primary,
                  ),
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
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.badge != null) ...[
                  SizedBox(width: spacing.sm),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: spacing.radiusFull,
                    ),
                    child: Text(
                      widget.badge!,
                      style: typo.labelSmall.copyWith(
                        color: colors.onPrimary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
                SizedBox(width: spacing.sm),
                // Chevron right
                Text(
                  '\u203A', // single right-pointing angle quotation mark
                  style: TextStyle(
                    fontSize: 22,
                    color: colors.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w300,
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
