import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../icons/ui_icons.dart';
import '../../theme/ui_color_scheme.dart';
import '../../theme/ui_theme.dart';

/// Avatar size presets.
enum UiAvatarSize { small, medium, large }

/// Status indicator for [UiAvatar].
enum UiAvatarStatus { online, offline, busy, away }

/// A circular avatar component.
///
/// Displays an image, initials, or icon inside a themed circle.
/// Supports an optional status indicator badge.
///
/// ```dart
/// UiAvatar(initials: 'TL', size: UiAvatarSize.large, status: UiAvatarStatus.online)
/// ```
class UiAvatar extends StatelessWidget {
  const UiAvatar({
    super.key,
    this.imageProvider,
    this.initials,
    this.icon,
    this.size = UiAvatarSize.medium,
    this.backgroundColor,
    this.status,
  });

  final ImageProvider? imageProvider;
  final String? initials;
  final IconData? icon;
  final UiAvatarSize size;
  final Color? backgroundColor;

  /// Optional status indicator shown in the bottom-right corner.
  final UiAvatarStatus? status;

  double _resolveSize() {
    switch (size) {
      case UiAvatarSize.small:
        return 32;
      case UiAvatarSize.medium:
        return 44;
      case UiAvatarSize.large:
        return 64;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final typo = theme.typography;

    final diameter = _resolveSize();
    final bgColor = backgroundColor ?? colors.primary;

    List<BoxShadow>? glow;
    if (theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(color: colors.glow!.withValues(alpha: 0.25), blurRadius: 10),
      ];
    }

    Widget child;
    if (imageProvider != null) {
      child = ClipOval(
        child: Image(
          image: imageProvider!,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
        ),
      );
    } else if (initials != null) {
      final displayText = initials!
          .substring(0, min(initials!.length, 2))
          .toUpperCase();
      child = Center(
        child: Text(
          displayText,
          style: typo.labelLarge.copyWith(
            color: colors.onPrimary,
            fontSize: diameter * 0.36,
          ),
        ),
      );
    } else {
      child = Center(
        child: Icon(
          icon ?? UiIcons.userPlaceholder,
          size: diameter * 0.5,
          color: colors.onPrimary,
        ),
      );
    }

    Widget avatar = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: imageProvider != null ? null : bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: colors.border, width: theme.borderWidth),
        boxShadow: glow,
      ),
      child: child,
    );

    if (status != null) {
      final statusSize = diameter * 0.28;
      final statusColor = _resolveStatusColor(colors);

      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: statusSize,
              height: statusSize,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 2),
              ),
            ),
          ),
        ],
      );
    }

    return avatar;
  }

  Color _resolveStatusColor(UiColorScheme colors) {
    switch (status!) {
      case UiAvatarStatus.online:
        return colors.success;
      case UiAvatarStatus.offline:
        return colors.border;
      case UiAvatarStatus.busy:
        return colors.error;
      case UiAvatarStatus.away:
        return colors.warning;
    }
  }
}
