import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A themed icon wrapper.
///
/// Automatically applies the theme's colors and optional glow effect.
///
/// ```dart
/// UiIcon(UiIcons.home, size: 24)
/// ```
class UiIcon extends StatelessWidget {
  const UiIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.useGlow = false,
  });

  final IconData icon;
  final double? size;
  final Color? color;

  /// Override to force glow regardless of theme.
  final bool useGlow;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final resolvedColor = color ?? theme.colorScheme.onSurface;
    final resolvedSize = size ?? theme.components.iconSizeMedium;
    final resolvedIcon = theme.icons.resolve(icon);

    final showGlow =
        useGlow || (theme.useGlow && theme.colorScheme.glow != null);

    if (showGlow) {
      final glowColor = theme.colorScheme.glow ?? resolvedColor;
      return Stack(
        alignment: Alignment.center,
        children: [
          // Glow layer
          Icon(
            resolvedIcon,
            size: resolvedSize,
            color: glowColor.withValues(alpha: 0.4),
            weight: theme.icons.weight,
            grade: theme.icons.grade,
            opticalSize: theme.icons.opticalSize,
            shadows: [
              Shadow(color: glowColor.withValues(alpha: 0.6), blurRadius: 12),
            ],
          ),
          // Main icon
          Icon(
            resolvedIcon,
            size: resolvedSize,
            color: resolvedColor,
            weight: theme.icons.weight,
            grade: theme.icons.grade,
            opticalSize: theme.icons.opticalSize,
          ),
        ],
      );
    }

    return Icon(
      resolvedIcon,
      size: resolvedSize,
      color: resolvedColor,
      weight: theme.icons.weight,
      grade: theme.icons.grade,
      opticalSize: theme.icons.opticalSize,
    );
  }
}

/// Built-in icon set using Unicode/Material icon codes.
///
/// These use the MaterialIcons font family that ships with Flutter,
/// so no extra font packages are needed.
abstract final class UiIcons {
  static const home = IconData(0xe318, fontFamily: 'MaterialIcons');
  static const settings = IconData(0xe57f, fontFamily: 'MaterialIcons');
  static const search = IconData(0xe567, fontFamily: 'MaterialIcons');
  static const close = IconData(0xe16a, fontFamily: 'MaterialIcons');
  static const menu = IconData(0xe3dc, fontFamily: 'MaterialIcons');
  static const add = IconData(0xe047, fontFamily: 'MaterialIcons');
  static const remove = IconData(0xe52b, fontFamily: 'MaterialIcons');
  static const edit = IconData(0xe22b, fontFamily: 'MaterialIcons');
  static const delete = IconData(0xe1b9, fontFamily: 'MaterialIcons');
  static const check = IconData(0xe156, fontFamily: 'MaterialIcons');
  static const arrowBack = IconData(0xe092, fontFamily: 'MaterialIcons');
  static const arrowForward = IconData(0xe094, fontFamily: 'MaterialIcons');
  static const arrowUp = IconData(0xe098, fontFamily: 'MaterialIcons');
  static const arrowDown = IconData(0xe096, fontFamily: 'MaterialIcons');
  static const chevronLeft = IconData(0xe14b, fontFamily: 'MaterialIcons');
  static const chevronRight = IconData(0xe14f, fontFamily: 'MaterialIcons');
  static const expandMore = IconData(0xe25c, fontFamily: 'MaterialIcons');
  static const expandLess = IconData(0xe25a, fontFamily: 'MaterialIcons');
  static const person = IconData(0xe491, fontFamily: 'MaterialIcons');
  static const group = IconData(0xe30a, fontFamily: 'MaterialIcons');
  static const email = IconData(0xe22a, fontFamily: 'MaterialIcons');
  static const phone = IconData(0xe4a2, fontFamily: 'MaterialIcons');
  static const notifications = IconData(0xe451, fontFamily: 'MaterialIcons');
  static const star = IconData(0xe5f9, fontFamily: 'MaterialIcons');
  static const starBorder = IconData(0xe5fa, fontFamily: 'MaterialIcons');
  static const favorite = IconData(0xe282, fontFamily: 'MaterialIcons');
  static const favoriteBorder = IconData(0xe283, fontFamily: 'MaterialIcons');
  static const share = IconData(0xe585, fontFamily: 'MaterialIcons');
  static const copy = IconData(0xe190, fontFamily: 'MaterialIcons');
  static const download = IconData(0xf090, fontFamily: 'MaterialIcons');
  static const upload = IconData(0xf093, fontFamily: 'MaterialIcons');
  static const refresh = IconData(0xe514, fontFamily: 'MaterialIcons');
  static const info = IconData(0xe335, fontFamily: 'MaterialIcons');
  static const warning = IconData(0xe645, fontFamily: 'MaterialIcons');
  static const error = IconData(0xe237, fontFamily: 'MaterialIcons');
  static const visibility = IconData(0xe640, fontFamily: 'MaterialIcons');
  static const visibilityOff = IconData(0xe641, fontFamily: 'MaterialIcons');
  static const lock = IconData(0xe3b1, fontFamily: 'MaterialIcons');
  static const lockOpen = IconData(0xe3b2, fontFamily: 'MaterialIcons');
  static const link = IconData(0xe399, fontFamily: 'MaterialIcons');
  static const code = IconData(0xe169, fontFamily: 'MaterialIcons');
  static const dashboard = IconData(0xe1b0, fontFamily: 'MaterialIcons');
  static const folder = IconData(0xe2c7, fontFamily: 'MaterialIcons');
  static const image = IconData(0xe332, fontFamily: 'MaterialIcons');
  static const moreVert = IconData(0xe434, fontFamily: 'MaterialIcons');
  static const moreHoriz = IconData(0xe432, fontFamily: 'MaterialIcons');
  static const darkMode = IconData(0xf159, fontFamily: 'MaterialIcons');
  static const lightMode = IconData(0xf15b, fontFamily: 'MaterialIcons');
  static const palette = IconData(0xe40a, fontFamily: 'MaterialIcons');
  static const userPlaceholder = IconData(0xE7FD, fontFamily: 'MaterialIcons');
  static const circle = IconData(0xe834, fontFamily: 'MaterialIcons');
  static const unavailable = IconData(0xe159, fontFamily: 'MaterialIcons');
  static const notFound = IconData(0xe1f6, fontFamily: 'MaterialIcons');
  static const maintenance = IconData(0xf1f3, fontFamily: 'MaterialIcons');
  static const offline = IconData(0xe0ce, fontFamily: 'MaterialIcons');
  static const increment = IconData(0xe145, fontFamily: 'MaterialIcons');
  static const decrement = IconData(0xe15b, fontFamily: 'MaterialIcons');
  static const cart = IconData(0xe854, fontFamily: 'MaterialIcons');
  static const clock = IconData(0xe8b5, fontFamily: 'MaterialIcons');
  static const shipping = IconData(0xe558, fontFamily: 'MaterialIcons');
  static const homeFilled = IconData(0xe30c, fontFamily: 'MaterialIcons');
  static const creditCard = IconData(0xe870, fontFamily: 'MaterialIcons');
  static const payment = IconData(0xe8a7, fontFamily: 'MaterialIcons');
  static const bank = IconData(0xe084, fontFamily: 'MaterialIcons');
  static const google = IconData(0xe1cb, fontFamily: 'MaterialIcons');
  static const apple = IconData(0xf04be, fontFamily: 'MaterialIcons');
  static const facebook = IconData(0xe27a, fontFamily: 'MaterialIcons');
  static const twitter = IconData(0xe602, fontFamily: 'MaterialIcons');
}
