import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Avatar size presets.
enum UiAvatarSize { small, medium, large }

/// A circular avatar component.
///
/// Displays an image, initials, or icon inside a themed circle.
///
/// ```dart
/// UiAvatar(initials: 'TL', size: UiAvatarSize.large)
/// ```
class UiAvatar extends StatelessWidget {
  const UiAvatar({
    super.key,
    this.imageProvider,
    this.initials,
    this.icon,
    this.size = UiAvatarSize.medium,
    this.backgroundColor,
  });

  final ImageProvider? imageProvider;
  final String? initials;
  final IconData? icon;
  final UiAvatarSize size;
  final Color? backgroundColor;

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
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.25),
          blurRadius: 10,
        ),
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
      child = Center(
        child: Text(
          initials!.substring(0, initials!.length.clamp(0, 2)).toUpperCase(),
          style: typo.labelLarge.copyWith(
            color: colors.onPrimary,
            fontSize: diameter * 0.36,
          ),
        ),
      );
    } else {
      child = Center(
        child: Icon(
          icon ?? const IconData(0xE7FD, fontFamily: 'MaterialIcons'),
          size: diameter * 0.5,
          color: colors.onPrimary,
        ),
      );
    }

    return Container(
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
  }
}
