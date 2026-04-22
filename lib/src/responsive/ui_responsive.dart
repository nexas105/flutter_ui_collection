import 'package:flutter/widgets.dart';

/// Standard breakpoint thresholds.
///
/// Customize via [UiResponsive.custom].
class UiBreakpoints {
  const UiBreakpoints({
    this.mobile = 480,
    this.tablet = 768,
    this.desktop = 1024,
    this.wide = 1440,
  });

  final double mobile;
  final double tablet;
  final double desktop;
  final double wide;
}

/// The current device size category.
enum UiScreenSize { mobile, tablet, desktop, wide }

/// Responsive utilities for adapting layouts to screen size.
///
/// ```dart
/// // In a build method:
/// final screen = UiResponsive.of(context);
/// final columns = screen.value(mobile: 1, tablet: 2, desktop: 3);
///
/// // As a builder widget:
/// UiResponsive(
///   mobile: (context) => MobileLayout(),
///   tablet: (context) => TabletLayout(),
///   desktop: (context) => DesktopLayout(),
/// )
/// ```
class UiResponsive extends StatelessWidget {
  const UiResponsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.wide,
    this.breakpoints = const UiBreakpoints(),
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;
  final WidgetBuilder? wide;
  final UiBreakpoints breakpoints;

  /// Returns a [UiScreenInfo] for the current screen size.
  static UiScreenInfo of(
    BuildContext context, {
    UiBreakpoints breakpoints = const UiBreakpoints(),
  }) {
    final width = MediaQuery.sizeOf(context).width;
    return UiScreenInfo._(width: width, breakpoints: breakpoints);
  }

  @override
  Widget build(BuildContext context) {
    final info = of(context, breakpoints: breakpoints);

    switch (info.screenSize) {
      case UiScreenSize.wide:
        return (wide ?? desktop ?? tablet ?? mobile)(context);
      case UiScreenSize.desktop:
        return (desktop ?? tablet ?? mobile)(context);
      case UiScreenSize.tablet:
        return (tablet ?? mobile)(context);
      case UiScreenSize.mobile:
        return mobile(context);
    }
  }
}

/// Contains information about the current screen and provides
/// responsive value selection helpers.
class UiScreenInfo {
  const UiScreenInfo._({
    required this.width,
    required this.breakpoints,
  });

  /// Creates a [UiScreenInfo] from a raw width value (useful in tests).
  factory UiScreenInfo.forWidth(
    double width, {
    UiBreakpoints breakpoints = const UiBreakpoints(),
  }) {
    return UiScreenInfo._(width: width, breakpoints: breakpoints);
  }

  final double width;
  final UiBreakpoints breakpoints;

  UiScreenSize get screenSize {
    if (width >= breakpoints.wide) return UiScreenSize.wide;
    if (width >= breakpoints.desktop) return UiScreenSize.desktop;
    if (width >= breakpoints.tablet) return UiScreenSize.tablet;
    return UiScreenSize.mobile;
  }

  bool get isMobile => screenSize == UiScreenSize.mobile;
  bool get isTablet => screenSize == UiScreenSize.tablet;
  bool get isDesktop => screenSize == UiScreenSize.desktop;
  bool get isWide => screenSize == UiScreenSize.wide;

  /// Selects a value based on the current screen size.
  ///
  /// Falls back to the next smaller defined value.
  T value<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
  }) {
    switch (screenSize) {
      case UiScreenSize.wide:
        return wide ?? desktop ?? tablet ?? mobile;
      case UiScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case UiScreenSize.tablet:
        return tablet ?? mobile;
      case UiScreenSize.mobile:
        return mobile;
    }
  }
}
