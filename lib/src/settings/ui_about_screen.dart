import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A link entry for [UiAboutScreen].
class UiAboutLink {
  const UiAboutLink({
    required this.label,
    required this.onTap,
    this.icon,
  });

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

    List<BoxShadow>? cardShadows;
    if (theme.useGlow && colors.glow != null) {
      cardShadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.1),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
    } else if (theme.useShadows) {
      cardShadows = [
        BoxShadow(
          color: colors.shadow,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.lg,
      ),
      child: Column(
        children: [
          // Logo + App identity
          SizedBox(height: spacing.lg),
          if (logo != null) ...[
            logo!,
            SizedBox(height: spacing.md),
          ],
          Text(
            appName,
            style: typo.headlineMedium.copyWith(color: colors.onBackground),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Version $version',
            style: typo.bodySmall.copyWith(
              color: colors.onBackground.withValues(alpha: 0.6),
            ),
          ),
          if (description != null) ...[
            SizedBox(height: spacing.md),
            Text(
              description!,
              style: typo.bodyMedium.copyWith(
                color: colors.onBackground.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: spacing.xl),
          // Links section
          if (links.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: spacing.radiusMd,
                border: Border.all(
                  color: colors.border,
                  width: theme.borderWidth,
                ),
                boxShadow: cardShadows,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < links.length; i++) ...[
                    _UiAboutLinkTile(link: links[i]),
                    if (i < links.length - 1)
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: spacing.md),
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
        ? colors.onSurface.withValues(alpha: 0.04)
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
                Icon(
                  widget.link.icon,
                  size: 20,
                  color: colors.primary,
                ),
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
                  color: colors.onSurface.withValues(alpha: 0.4),
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
