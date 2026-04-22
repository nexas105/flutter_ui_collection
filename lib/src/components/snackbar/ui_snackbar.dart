import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// A themed snackbar with optional action button.
///
/// ```dart
/// UiSnackbar.show(
///   context: context,
///   message: 'Item deleted',
///   action: UiSnackbarAction(label: 'UNDO', onPressed: () {}),
/// );
/// ```
class UiSnackbar {
  UiSnackbar._();

  static OverlayEntry? _currentEntry;
  static Timer? _currentTimer;

  /// Shows a snackbar at the bottom of the screen.
  static void show({
    required BuildContext context,
    required String message,
    UiSnackbarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    _currentTimer?.cancel();
    _currentEntry?.remove();

    final overlay = Overlay.of(context);
    final theme = UiTheme.of(context);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _UiSnackbarWidget(
        message: message,
        action: action,
        theme: theme,
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

  /// Dismisses the current snackbar.
  static void dismiss() {
    _currentTimer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

/// An action button displayed in the snackbar.
class UiSnackbarAction {
  const UiSnackbarAction({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;
}

class _UiSnackbarWidget extends StatefulWidget {
  const _UiSnackbarWidget({
    required this.message,
    this.action,
    required this.theme,
    this.onDismiss,
  });

  final String message;
  final UiSnackbarAction? action;
  final UiThemeData theme;
  final VoidCallback? onDismiss;

  @override
  State<_UiSnackbarWidget> createState() => _UiSnackbarWidgetState();
}

class _UiSnackbarWidgetState extends State<_UiSnackbarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.theme.animationDuration,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.theme.animationCurve,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    List<BoxShadow>? shadows;
    if (theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(color: colors.glow!.withValues(alpha: 0.2), blurRadius: 12),
      ];
    } else if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.shadow,
          blurRadius: 12,
          offset: const Offset(0, -2),
        ),
      ];
    }

    return Positioned(
      bottom: spacing.lg,
      left: spacing.lg,
      right: spacing.lg,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: spacing.radiusMd,
              border: Border.all(color: colors.border, width: theme.borderWidth),
              boxShadow: shadows,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.message,
                    style: typo.bodyMedium.copyWith(color: colors.onSurface),
                  ),
                ),
                if (widget.action != null) ...[
                  SizedBox(width: spacing.md),
                  GestureDetector(
                    onTap: () {
                      widget.action!.onPressed();
                      widget.onDismiss?.call();
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        widget.action!.label,
                        style: typo.labelMedium.copyWith(color: colors.primary),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
