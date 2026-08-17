import 'package:flutter/widgets.dart';

/// Shared geometry and interaction values for core UI components.
///
/// Presets can replace these values to establish their own component grammar
/// instead of relying on hard-coded dimensions inside individual widgets.
class UiComponentTokens {
  const UiComponentTokens({
    this.controlHeightSmall = 36,
    this.controlHeightMedium = 44,
    this.controlHeightLarge = 52,
    this.controlRadius = 12,
    this.cardRadius = 16,
    this.cardPadding = 20,
    this.appBarHeight = 64,
    this.iconSizeSmall = 16,
    this.iconSizeMedium = 20,
    this.iconSizeLarge = 24,
    this.hoverOpacity = 0.08,
    this.pressedOpacity = 0.16,
    this.subtleOpacity = 0.04,
    this.tintOpacity = 0.1,
    this.strongTintOpacity = 0.2,
    this.disabledOpacity = 0.42,
    this.focusRingWidth = 2,
    this.shadowBlur = 18,
    this.shadowOffset = const Offset(0, 6),
    this.contentMaxWidth = 1120,
  });

  final double controlHeightSmall;
  final double controlHeightMedium;
  final double controlHeightLarge;
  final double controlRadius;
  final double cardRadius;
  final double cardPadding;
  final double appBarHeight;
  final double iconSizeSmall;
  final double iconSizeMedium;
  final double iconSizeLarge;
  final double hoverOpacity;
  final double pressedOpacity;
  final double subtleOpacity;
  final double tintOpacity;
  final double strongTintOpacity;
  final double disabledOpacity;
  final double focusRingWidth;
  final double shadowBlur;
  final Offset shadowOffset;
  final double contentMaxWidth;

  BorderRadius get controlBorderRadius => BorderRadius.circular(controlRadius);
  BorderRadius get cardBorderRadius => BorderRadius.circular(cardRadius);

  UiComponentTokens copyWith({
    double? controlHeightSmall,
    double? controlHeightMedium,
    double? controlHeightLarge,
    double? controlRadius,
    double? cardRadius,
    double? cardPadding,
    double? appBarHeight,
    double? iconSizeSmall,
    double? iconSizeMedium,
    double? iconSizeLarge,
    double? hoverOpacity,
    double? pressedOpacity,
    double? subtleOpacity,
    double? tintOpacity,
    double? strongTintOpacity,
    double? disabledOpacity,
    double? focusRingWidth,
    double? shadowBlur,
    Offset? shadowOffset,
    double? contentMaxWidth,
  }) {
    return UiComponentTokens(
      controlHeightSmall: controlHeightSmall ?? this.controlHeightSmall,
      controlHeightMedium: controlHeightMedium ?? this.controlHeightMedium,
      controlHeightLarge: controlHeightLarge ?? this.controlHeightLarge,
      controlRadius: controlRadius ?? this.controlRadius,
      cardRadius: cardRadius ?? this.cardRadius,
      cardPadding: cardPadding ?? this.cardPadding,
      appBarHeight: appBarHeight ?? this.appBarHeight,
      iconSizeSmall: iconSizeSmall ?? this.iconSizeSmall,
      iconSizeMedium: iconSizeMedium ?? this.iconSizeMedium,
      iconSizeLarge: iconSizeLarge ?? this.iconSizeLarge,
      hoverOpacity: hoverOpacity ?? this.hoverOpacity,
      pressedOpacity: pressedOpacity ?? this.pressedOpacity,
      subtleOpacity: subtleOpacity ?? this.subtleOpacity,
      tintOpacity: tintOpacity ?? this.tintOpacity,
      strongTintOpacity: strongTintOpacity ?? this.strongTintOpacity,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
    );
  }
}
