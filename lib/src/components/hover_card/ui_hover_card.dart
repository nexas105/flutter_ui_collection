import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed card that appears on hover after a delay.
///
/// Uses [CompositedTransformTarget] / [CompositedTransformFollower]
/// and an [OverlayEntry] to position the preview near the trigger.
///
/// ```dart
/// UiHoverCard(
///   child: Text('Hover me'),
///   content: Text('Rich preview content'),
/// )
/// ```
class UiHoverCard extends StatefulWidget {
  const UiHoverCard({
    super.key,
    required this.child,
    required this.content,
    this.width = 280,
    this.openDelay = const Duration(milliseconds: 400),
  });

  /// The trigger widget.
  final Widget child;

  /// The preview content shown on hover.
  final Widget content;

  /// Width of the hover card.
  final double width;

  /// Delay before the card appears on hover.
  final Duration openDelay;

  @override
  State<UiHoverCard> createState() => _UiHoverCardState();
}

class _UiHoverCardState extends State<UiHoverCard> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _timer;
  bool _isHoveringCard = false;
  bool _isHoveringTrigger = false;

  void _showCard() {
    if (_overlayEntry != null) return;
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (_) => _HoverCardOverlay(
        link: _layerLink,
        width: widget.width,
        content: widget.content,
        onEnter: () {
          _isHoveringCard = true;
        },
        onExit: () {
          _isHoveringCard = false;
          _scheduleDismiss();
        },
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _hideCard() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _scheduleDismiss() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 100), () {
      if (!_isHoveringCard && !_isHoveringTrigger) {
        _hideCard();
      }
    });
  }

  void _onTriggerEnter() {
    _isHoveringTrigger = true;
    _timer?.cancel();
    _timer = Timer(widget.openDelay, _showCard);
  }

  void _onTriggerExit() {
    _isHoveringTrigger = false;
    _scheduleDismiss();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hideCard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _onTriggerEnter(),
        onExit: (_) => _onTriggerExit(),
        child: widget.child,
      ),
    );
  }
}

class _HoverCardOverlay extends StatelessWidget {
  const _HoverCardOverlay({
    required this.link,
    required this.width,
    required this.content,
    required this.onEnter,
    required this.onExit,
  });

  final LayerLink link;
  final double width;
  final Widget content;
  final VoidCallback onEnter;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    final List<BoxShadow> shadows = [];
    if (theme.useGlow && colors.glow != null) {
      shadows.add(BoxShadow(
        color: colors.glow!.withValues(alpha: 0.2),
        blurRadius: 16,
        spreadRadius: 1,
      ));
    } else if (theme.useShadows) {
      shadows.add(BoxShadow(
        color: colors.shadow,
        blurRadius: 12,
        offset: const Offset(0, 4),
      ));
    }

    return UnconstrainedBox(
      child: CompositedTransformFollower(
        link: link,
        offset: const Offset(0, 8),
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        showWhenUnlinked: false,
        child: MouseRegion(
          onEnter: (_) => onEnter(),
          onExit: (_) => onExit(),
          child: Container(
            width: width,
            padding: spacing.paddingMd,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: spacing.radiusMd,
              border:
                  Border.all(color: colors.border, width: theme.borderWidth),
              boxShadow: shadows,
            ),
            child: DefaultTextStyle(
              style: theme.typography.bodyMedium
                  .copyWith(color: colors.onSurface),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
