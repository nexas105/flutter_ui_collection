import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Base settings tile with leading icon, title, subtitle, and trailing widget.
///
/// Provides hover feedback and tap handling. Used as the foundation
/// for other settings widgets like [UiSettingsToggle] and [UiSettingsNavigation].
///
/// ```dart
/// UiSettingsTile(
///   leading: Icons.person,
///   title: 'Account',
///   subtitle: 'Manage your account settings',
///   trailing: Icon(Icons.chevron_right),
///   onTap: () {},
/// )
/// ```
class UiSettingsTile extends StatefulWidget {
  const UiSettingsTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  /// Optional leading icon.
  final IconData? leading;

  /// Primary text label.
  final String title;

  /// Secondary description text.
  final String? subtitle;

  /// Widget displayed on the right side.
  final Widget? trailing;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  /// Whether the tile is interactive.
  final bool enabled;

  @override
  State<UiSettingsTile> createState() => _UiSettingsTileState();
}

class _UiSettingsTileState extends State<UiSettingsTile> {
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
                if (widget.trailing != null) ...[
                  SizedBox(width: spacing.sm),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
