import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed scaffold that provides standard app layout structure.
///
/// Combines app bar, body, sidebar, bottom navigation, and floating action
/// button into a single, responsive layout. On mobile, the sidebar
/// automatically hides (use [UiDrawer] for mobile navigation).
///
/// ```dart
/// UiScaffold(
///   appBar: UiAppBar(title: Text('Home')),
///   sidebar: UiSidebar(items: [...], selectedIndex: 0, onChanged: ...),
///   body: MyContent(),
///   floatingAction: UiButton(label: '+', variant: UiButtonVariant.glow, onPressed: () {}),
/// )
/// ```
class UiScaffold extends StatelessWidget {
  const UiScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.sidebar,
    this.bottomBar,
    this.floatingAction,
    this.floatingActionAlignment = Alignment.bottomRight,
    this.backgroundColor,
    this.sidebarBreakpoint = 768,
  });

  /// The main content area.
  final Widget body;

  /// Optional top bar.
  final Widget? appBar;

  /// Optional sidebar. Automatically hidden below [sidebarBreakpoint].
  /// On narrow screens, use [UiDrawer] to show it on demand.
  final Widget? sidebar;

  /// Optional bottom navigation bar.
  final Widget? bottomBar;

  /// Optional floating action widget (e.g. a UiButton).
  final Widget? floatingAction;

  /// Alignment of the floating action within the body area.
  final Alignment floatingActionAlignment;

  /// Background color override.
  final Color? backgroundColor;

  /// Screen width below which the sidebar is hidden.
  final double sidebarBreakpoint;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final showSidebar = sidebar != null && screenWidth >= sidebarBreakpoint;

    return ColoredBox(
      color: backgroundColor ?? colors.background,
      child: Column(
        children: [
          // App bar
          ?appBar,

          // Body + Sidebar
          Expanded(
            child: Row(
              children: [
                // Sidebar (desktop only)
                if (showSidebar) sidebar!,

                // Main content area
                Expanded(
                  child: Stack(
                    children: [
                      // Body
                      Positioned.fill(child: body),

                      // Floating action
                      if (floatingAction != null)
                        Positioned(
                          right: floatingActionAlignment == Alignment.bottomRight ||
                                  floatingActionAlignment == Alignment.topRight
                              ? spacing.lg
                              : null,
                          left: floatingActionAlignment == Alignment.bottomLeft ||
                                  floatingActionAlignment == Alignment.topLeft
                              ? spacing.lg
                              : null,
                          bottom: floatingActionAlignment == Alignment.bottomRight ||
                                  floatingActionAlignment == Alignment.bottomLeft
                              ? spacing.lg
                              : null,
                          top: floatingActionAlignment == Alignment.topRight ||
                                  floatingActionAlignment == Alignment.topLeft
                              ? spacing.lg
                              : null,
                          child: floatingAction!,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom bar
          ?bottomBar,
        ],
      ),
    );
  }
}

/// A simple responsive body that switches layouts based on screen size.
///
/// Convenience widget for the most common responsive pattern:
/// one column on mobile, two/three columns on wider screens.
///
/// ```dart
/// UiResponsiveBody(
///   child: MyContent(),
///   maxWidth: 800,
///   padding: EdgeInsets.all(16),
/// )
/// ```
class UiResponsiveBody extends StatelessWidget {
  const UiResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = 960,
    this.padding,
    this.center = true,
  });

  final Widget child;

  /// Maximum width of the content area.
  final double maxWidth;

  /// Padding around the content.
  final EdgeInsets? padding;

  /// Whether to center the content horizontally.
  final bool center;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final resolvedPadding = padding ?? theme.spacing.paddingMd;

    Widget content = Padding(
      padding: resolvedPadding,
      child: child,
    );

    if (maxWidth < double.infinity) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      );
    }

    return content;
  }
}
