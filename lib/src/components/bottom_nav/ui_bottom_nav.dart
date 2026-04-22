import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A single bottom navigation item.
class UiBottomNavItem {
  const UiBottomNavItem({required this.icon, required this.label, this.badge});

  final IconData icon;
  final String label;

  /// Optional badge count (shown as a dot or number).
  final int? badge;
}

/// A themed bottom navigation bar.
///
/// ```dart
/// UiScaffold(
///   body: pages[_index],
///   bottomBar: UiBottomNav(
///     items: [
///       UiBottomNavItem(icon: UiIcons.home, label: 'Home'),
///       UiBottomNavItem(icon: UiIcons.search, label: 'Search'),
///       UiBottomNavItem(icon: UiIcons.person, label: 'Profile', badge: 3),
///     ],
///     selectedIndex: _index,
///     onChanged: (i) => setState(() => _index = i),
///   ),
/// )
/// ```
class UiBottomNav extends StatelessWidget {
  const UiBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.showLabels = true,
  });

  final List<UiBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border, width: theme.borderWidth)),
      ),
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: theme.animationDuration,
                            padding: EdgeInsets.all(spacing.xs),
                            decoration: i == selectedIndex && theme.useGlow && colors.glow != null
                                ? BoxDecoration(boxShadow: [
                                    BoxShadow(color: colors.glow!.withValues(alpha: 0.3), blurRadius: 10),
                                  ])
                                : null,
                            child: Icon(
                              items[i].icon,
                              size: 24,
                              color: i == selectedIndex ? colors.primary : colors.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          if (items[i].badge != null && items[i].badge! > 0)
                            Positioned(
                              right: -4,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: colors.error,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                constraints: const BoxConstraints(minWidth: 16),
                                child: Text(
                                  items[i].badge! > 99 ? '99+' : '${items[i].badge}',
                                  style: typo.labelSmall.copyWith(color: colors.onError, fontSize: 9),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (showLabels) ...[
                        SizedBox(height: 2),
                        Text(
                          items[i].label,
                          style: typo.labelSmall.copyWith(
                            color: i == selectedIndex ? colors.primary : colors.onSurface.withValues(alpha: 0.5),
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
