import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// Toast position on the screen.
enum UiToastPosition { top, bottom }

/// Toast severity determines the color.
enum UiToastSeverity { info, success, warning, error }

/// Manages toast overlay entries.
///
/// Use [UiToast.show] to display a brief, auto-dismissing message.
///
/// ```dart
/// UiToast.show(
///   context: context,
///   message: 'Saved successfully!',
///   severity: UiToastSeverity.success,
/// );
/// ```
class UiToast {
  UiToast._();

  static OverlayEntry? _currentEntry;
  static Timer? _currentTimer;

  /// Shows a toast message that auto-dismisses.
  static void show({
    required BuildContext context,
    required String message,
    UiToastSeverity severity = UiToastSeverity.info,
    UiToastPosition position = UiToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    _currentTimer?.cancel();
    _currentEntry?.remove();

    final overlay = Overlay.of(context);
    final theme = UiTheme.of(context);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _UiToastWidget(
        message: message,
        severity: severity,
        position: position,
        theme: theme,
        onTap: onTap,
        onDismiss: () {
          entry.remove();
          if (_currentEntry == entry) _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    _currentTimer = Timer(duration, () {
      if (_currentEntry == entry) {
        entry.remove();
        _currentEntry = null;
      }
    });
  }

  /// Dismisses the current toast immediately.
  static void dismiss() {
    _currentTimer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _UiToastWidget extends StatefulWidget {
  const _UiToastWidget({
    required this.message,
    required this.severity,
    required this.position,
    required this.theme,
    this.onTap,
    this.onDismiss,
  });

  final String message;
  final UiToastSeverity severity;
  final UiToastPosition position;
  final UiThemeData theme;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  State<_UiToastWidget> createState() => _UiToastWidgetState();
}

class _UiToastWidgetState extends State<_UiToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.theme.animationDuration,
    );

    final beginOffset = widget.position == UiToastPosition.top
        ? const Offset(0, -1)
        : const Offset(0, 1);

    _slideAnimation = Tween<Offset>(begin: beginOffset, end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: widget.theme.animationCurve,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _resolveColor() {
    final colors = widget.theme.colorScheme;
    switch (widget.severity) {
      case UiToastSeverity.info:
        return colors.primary;
      case UiToastSeverity.success:
        return colors.success;
      case UiToastSeverity.warning:
        return colors.warning;
      case UiToastSeverity.error:
        return colors.error;
    }
  }

  Color _resolveFgColor() {
    final colors = widget.theme.colorScheme;
    switch (widget.severity) {
      case UiToastSeverity.info:
        return colors.onPrimary;
      case UiToastSeverity.success:
        return colors.onSuccess;
      case UiToastSeverity.warning:
        return colors.onWarning;
      case UiToastSeverity.error:
        return colors.onError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final spacing = theme.spacing;
    final typo = theme.typography;
    final bgColor = _resolveColor();
    final fgColor = _resolveFgColor();

    List<BoxShadow>? shadows;
    if (theme.useGlow) {
      shadows = [
        BoxShadow(color: bgColor.withValues(alpha: 0.4), blurRadius: 16),
      ];
    } else if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: theme.colorScheme.shadow,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }

    return Positioned(
      top: widget.position == UiToastPosition.top ? spacing.xxl : null,
      bottom: widget.position == UiToastPosition.bottom ? spacing.xxl : null,
      left: spacing.lg,
      right: spacing.lg,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: widget.onTap ?? widget.onDismiss,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: spacing.radiusMd,
                  boxShadow: shadows,
                ),
                child: Text(
                  widget.message,
                  style: typo.bodyMedium.copyWith(color: fgColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
