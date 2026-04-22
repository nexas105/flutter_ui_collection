import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A shopping cart icon with an animated item count badge.
///
/// The count badge animates in/out and scales on change.
///
/// ```dart
/// UiCartBadge(
///   count: 3,
///   onTap: () => openCart(),
/// )
/// ```
class UiCartBadge extends StatefulWidget {
  const UiCartBadge({
    super.key,
    this.count = 0,
    this.onTap,
    this.iconSize = 24.0,
  });

  /// Number of items in the cart. When 0, the badge is hidden.
  final int count;

  /// Called when the icon is tapped.
  final VoidCallback? onTap;

  /// Size of the cart icon.
  final double iconSize;

  @override
  State<UiCartBadge> createState() => _UiCartBadgeState();
}

class _UiCartBadgeState extends State<UiCartBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(UiCartBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _bounce.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;

    List<BoxShadow>? glow;
    if (theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.4),
          blurRadius: 8,
        ),
      ];
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: SizedBox(
          width: widget.iconSize + 12,
          height: widget.iconSize + 8,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Cart icon
              Positioned(
                left: 0,
                bottom: 0,
                child: Icon(
                  const IconData(0xe854, fontFamily: 'MaterialIcons'), // shopping_cart
                  size: widget.iconSize,
                  color: colors.onSurface,
                ),
              ),
              // Count badge
              if (widget.count > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: AnimatedBuilder(
                    animation: _bounce,
                    builder: (context, child) {
                      final scale = 1.0 + 0.3 * _bounceCurve(_bounce.value);
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: colors.error,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: glow,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.count > 99 ? '99+' : '${widget.count}',
                        style: theme.typography.labelSmall.copyWith(
                          color: colors.onError,
                          fontSize: 10,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// An ease-out bounce approximation: quick overshoot then settle.
  double _bounceCurve(double t) {
    if (t < 0.5) {
      return 4 * t * t;
    } else {
      return 1.0 - (2 * t - 2) * (2 * t - 2) + 1.0;
    }
  }
}
