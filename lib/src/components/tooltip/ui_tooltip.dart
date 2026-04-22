import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// Position of the tooltip relative to the child.
enum UiTooltipPosition { top, bottom, left, right }

/// A themed tooltip that shows on hover/long press.
///
/// ```dart
/// UiTooltip(
///   message: 'Delete this item',
///   child: Icon(Icons.delete),
/// )
/// ```
class UiTooltip extends StatefulWidget {
  const UiTooltip({
    super.key,
    required this.message,
    required this.child,
    this.position = UiTooltipPosition.top,
    this.waitDuration = const Duration(milliseconds: 500),
  });

  final String message;
  final Widget child;
  final UiTooltipPosition position;
  final Duration waitDuration;

  @override
  State<UiTooltip> createState() => _UiTooltipState();
}

class _UiTooltipState extends State<UiTooltip> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _visible = false;
  Timer? _showTimer;

  void _scheduleShow() {
    _showTimer?.cancel();
    _showTimer = Timer(widget.waitDuration, () {
      if (mounted) _show();
    });
  }

  void _show() {
    if (_visible) return;
    _visible = true;

    final theme = UiTheme.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        link: _layerLink,
        message: widget.message,
        position: widget.position,
        theme: theme,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hide() {
    _showTimer?.cancel();
    _showTimer = null;
    _visible = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _scheduleShow(),
        onExit: (_) => _hide(),
        child: GestureDetector(
          onLongPress: _show,
          onLongPressUp: _hide,
          child: widget.child,
        ),
      ),
    );
  }
}

class _TooltipOverlay extends StatelessWidget {
  const _TooltipOverlay({
    required this.link,
    required this.message,
    required this.position,
    required this.theme,
  });

  final LayerLink link;
  final String message;
  final UiTooltipPosition position;
  final UiThemeData theme;

  Alignment get _targetAnchor {
    switch (position) {
      case UiTooltipPosition.top:
        return Alignment.topCenter;
      case UiTooltipPosition.bottom:
        return Alignment.bottomCenter;
      case UiTooltipPosition.left:
        return Alignment.centerLeft;
      case UiTooltipPosition.right:
        return Alignment.centerRight;
    }
  }

  Alignment get _followerAnchor {
    switch (position) {
      case UiTooltipPosition.top:
        return Alignment.bottomCenter;
      case UiTooltipPosition.bottom:
        return Alignment.topCenter;
      case UiTooltipPosition.left:
        return Alignment.centerRight;
      case UiTooltipPosition.right:
        return Alignment.centerLeft;
    }
  }

  Offset get _offset {
    const gap = 6.0;
    switch (position) {
      case UiTooltipPosition.top:
        return const Offset(0, -gap);
      case UiTooltipPosition.bottom:
        return const Offset(0, gap);
      case UiTooltipPosition.left:
        return const Offset(-gap, 0);
      case UiTooltipPosition.right:
        return const Offset(gap, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    List<BoxShadow>? shadows;
    if (theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(color: colors.glow!.withValues(alpha: 0.2), blurRadius: 8),
      ];
    } else if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.shadow,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return CompositedTransformFollower(
      link: link,
      offset: _offset,
      targetAnchor: _targetAnchor,
      followerAnchor: _followerAnchor,
      child: IgnorePointer(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.xs,
          ),
          decoration: BoxDecoration(
            color: colors.onBackground,
            borderRadius: spacing.radiusSm,
            boxShadow: shadows,
          ),
          child: Text(
            message,
            style: typo.bodySmall.copyWith(color: colors.background),
          ),
        ),
      ),
    );
  }
}
