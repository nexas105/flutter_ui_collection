import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A link entry for [UiAboutScreen].
class UiAboutLink {
  const UiAboutLink({required this.label, required this.onTap, this.icon});

  /// Display label for the link.
  final String label;

  /// Called when the link is tapped.
  final VoidCallback onTap;

  /// Optional leading icon.
  final IconData? icon;
}

/// An about/app info screen showing the app identity, version,
/// description, and links.
///
/// ```dart
/// UiAboutScreen(
///   appName: 'My App',
///   version: '1.2.3',
///   description: 'A beautiful Flutter app.',
///   logo: FlutterLogo(size: 64),
///   links: [
///     UiAboutLink(label: 'Website', onTap: () {}),
///     UiAboutLink(label: 'Privacy Policy', onTap: () {}),
///   ],
/// )
/// ```
class UiAboutScreen extends StatelessWidget {
  const UiAboutScreen({
    super.key,
    required this.appName,
    required this.version,
    this.description,
    this.logo,
    this.links = const [],
  });

  /// The application name.
  final String appName;

  /// The application version string.
  final String version;

  /// Optional description text.
  final String? description;

  /// Optional logo widget displayed at the top.
  final Widget? logo;

  /// Navigation links (website, privacy, terms, etc.).
  final List<UiAboutLink> links;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final cardShadows = theme.surfaceShadows();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.lg,
      ),
      child: Column(
        children: [
          // Logo + App identity
          SizedBox(height: spacing.md),
          if (logo != null) ...[
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.resolvedSurfaceRaised,
                borderRadius: theme.components.cardBorderRadius,
                boxShadow: cardShadows,
              ),
              child: logo!,
            ),
            SizedBox(height: spacing.lg),
          ],
          Text(
            appName,
            style: typo.headlineLarge.copyWith(color: colors.onBackground),
          ),
          SizedBox(height: spacing.xs),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.primary.withValues(
                alpha: theme.components.tintOpacity,
              ),
              borderRadius: spacing.radiusFull,
            ),
            child: Text(
              'Version $version',
              style: typo.labelSmall.copyWith(color: colors.primary),
            ),
          ),
          if (description != null) ...[
            SizedBox(height: spacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(
                description!,
                style: typo.bodyLarge.copyWith(
                  color: colors.resolvedOnSurfaceMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          SizedBox(height: spacing.xl),
          // Links section
          if (links.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: colors.resolvedSurfaceRaised,
                borderRadius: theme.components.cardBorderRadius,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < links.length; i++) ...[
                    _UiAboutLinkTile(link: links[i]),
                    if (i < links.length - 1)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing.md),
                        child: Container(
                          height: theme.borderWidth,
                          color: colors.border,
                        ),
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _UiAboutLinkTile extends StatefulWidget {
  const _UiAboutLinkTile({required this.link});

  final UiAboutLink link;

  @override
  State<_UiAboutLinkTile> createState() => _UiAboutLinkTileState();
}

class _UiAboutLinkTileState extends State<_UiAboutLinkTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final Color bgColor = _hovered
        ? colors.onSurface.withValues(alpha: theme.components.subtleOpacity)
        : const Color(0x00000000);

    return GestureDetector(
      onTap: widget.link.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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
              if (widget.link.icon != null) ...[
                Icon(widget.link.icon, size: 20, color: colors.primary),
                SizedBox(width: spacing.md),
              ],
              Expanded(
                child: Text(
                  widget.link.label,
                  style: typo.bodyMedium.copyWith(color: colors.primary),
                ),
              ),
              Text(
                '\u203A',
                style: TextStyle(
                  fontSize: 22,
                  color: colors.resolvedOnSurfaceSubtle,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
