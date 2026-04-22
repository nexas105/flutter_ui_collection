import 'package:flutter/widgets.dart';

/// Spacing tokens for consistent layout across all components.
class UiSpacing {
  const UiSpacing({
    this.xs = 4.0,
    this.sm = 8.0,
    this.md = 16.0,
    this.lg = 24.0,
    this.xl = 32.0,
    this.xxl = 48.0,
    this.borderRadiusSm = 4.0,
    this.borderRadiusMd = 8.0,
    this.borderRadiusLg = 16.0,
    this.borderRadiusXl = 24.0,
    this.borderRadiusFull = 999.0,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double borderRadiusSm;
  final double borderRadiusMd;
  final double borderRadiusLg;
  final double borderRadiusXl;
  final double borderRadiusFull;

  BorderRadius get radiusSm => BorderRadius.circular(borderRadiusSm);
  BorderRadius get radiusMd => BorderRadius.circular(borderRadiusMd);
  BorderRadius get radiusLg => BorderRadius.circular(borderRadiusLg);
  BorderRadius get radiusXl => BorderRadius.circular(borderRadiusXl);
  BorderRadius get radiusFull => BorderRadius.circular(borderRadiusFull);

  EdgeInsets get paddingSm => EdgeInsets.all(sm);
  EdgeInsets get paddingMd => EdgeInsets.all(md);
  EdgeInsets get paddingLg => EdgeInsets.all(lg);

  EdgeInsets horizontalSm() => EdgeInsets.symmetric(horizontal: sm);
  EdgeInsets horizontalMd() => EdgeInsets.symmetric(horizontal: md);
  EdgeInsets horizontalLg() => EdgeInsets.symmetric(horizontal: lg);

  UiSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? borderRadiusSm,
    double? borderRadiusMd,
    double? borderRadiusLg,
    double? borderRadiusXl,
    double? borderRadiusFull,
  }) {
    return UiSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      borderRadiusSm: borderRadiusSm ?? this.borderRadiusSm,
      borderRadiusMd: borderRadiusMd ?? this.borderRadiusMd,
      borderRadiusLg: borderRadiusLg ?? this.borderRadiusLg,
      borderRadiusXl: borderRadiusXl ?? this.borderRadiusXl,
      borderRadiusFull: borderRadiusFull ?? this.borderRadiusFull,
    );
  }
}
