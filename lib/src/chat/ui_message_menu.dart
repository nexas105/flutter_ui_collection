import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Actions available in the message context menu.
enum UiMessageAction { reply, forward, copy, delete, pin }

/// Long-press message overlay menu with themed action rows.
///
/// Displays a vertical list of actions, each with an icon and label.
/// The delete action is shown in the error color. The menu uses themed
/// card styling with shadow or glow.
///
/// ```dart
/// UiMessageMenu(
///   actions: UiMessageAction.values,
///   onAction: (action) => handleAction(action),
/// )
/// ```
class UiMessageMenu extends StatelessWidget {
  const UiMessageMenu({super.key, required this.actions, this.onAction});

  /// The list of actions to display.
  final List<UiMessageAction> actions;

  /// Called when an action row is tapped.
  final ValueChanged<UiMessageAction>? onAction;

  static String _labelFor(UiMessageAction action) {
    switch (action) {
      case UiMessageAction.reply:
        return 'Reply';
      case UiMessageAction.forward:
        return 'Forward';
      case UiMessageAction.copy:
        return 'Copy';
      case UiMessageAction.delete:
        return 'Delete';
      case UiMessageAction.pin:
        return 'Pin';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final shadows = theme.surfaceShadows(emphasized: true);

    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: spacing.radiusMd,
        border: Border.all(color: colors.border, width: theme.borderWidth),
        boxShadow: shadows,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < actions.length; i++) ...[
            if (i > 0)
              Container(
                height: theme.borderWidth,
                margin: EdgeInsets.symmetric(horizontal: spacing.sm),
                color: colors.border.withValues(alpha: 0.5),
              ),
            _ActionRow(
              action: actions[i],
              label: _labelFor(actions[i]),
              isDestructive: actions[i] == UiMessageAction.delete,
              onTap: onAction != null ? () => onAction!(actions[i]) : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.action,
    required this.label,
    this.isDestructive = false,
    this.onTap,
  });

  final UiMessageAction action;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final iconColor = isDestructive ? colors.error : colors.onSurface;
    final textColor = isDestructive ? colors.error : colors.onSurface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm + 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CustomPaint(
                painter: _ActionIconPainter(action: action, color: iconColor),
              ),
            ),
            SizedBox(width: spacing.sm + 2),
            Text(label, style: typo.bodyMedium.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }
}

/// Paints an icon for each message action.
class _ActionIconPainter extends CustomPainter {
  _ActionIconPainter({required this.action, required this.color});

  final UiMessageAction action;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    switch (action) {
      case UiMessageAction.reply:
        // Curved reply arrow.
        final path = Path()
          ..moveTo(w * 0.6, h * 0.2)
          ..lineTo(w * 0.2, h * 0.5)
          ..lineTo(w * 0.6, h * 0.8);
        canvas.drawPath(path, paint);
        final linePath = Path()
          ..moveTo(w * 0.2, h * 0.5)
          ..quadraticBezierTo(w * 0.85, h * 0.5, w * 0.85, h * 0.85);
        canvas.drawPath(linePath, paint);

      case UiMessageAction.forward:
        // Forward arrow.
        final path = Path()
          ..moveTo(w * 0.4, h * 0.2)
          ..lineTo(w * 0.8, h * 0.5)
          ..lineTo(w * 0.4, h * 0.8);
        canvas.drawPath(path, paint);
        final linePath = Path()
          ..moveTo(w * 0.8, h * 0.5)
          ..quadraticBezierTo(w * 0.15, h * 0.5, w * 0.15, h * 0.85);
        canvas.drawPath(linePath, paint);

      case UiMessageAction.copy:
        // Two overlapping rectangles.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.05, h * 0.2, w * 0.55, h * 0.6),
            const Radius.circular(2),
          ),
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.3, h * 0.05, w * 0.55, h * 0.6),
            const Radius.circular(2),
          ),
          paint,
        );

      case UiMessageAction.delete:
        // Trash can.
        canvas.drawLine(
          Offset(w * 0.2, h * 0.25),
          Offset(w * 0.8, h * 0.25),
          paint,
        );
        canvas.drawLine(
          Offset(w * 0.4, h * 0.1),
          Offset(w * 0.6, h * 0.1),
          paint,
        );
        canvas.drawLine(
          Offset(w * 0.4, h * 0.1),
          Offset(w * 0.4, h * 0.25),
          paint,
        );
        canvas.drawLine(
          Offset(w * 0.6, h * 0.1),
          Offset(w * 0.6, h * 0.25),
          paint,
        );
        final bodyPath = Path()
          ..moveTo(w * 0.25, h * 0.25)
          ..lineTo(w * 0.3, h * 0.9)
          ..lineTo(w * 0.7, h * 0.9)
          ..lineTo(w * 0.75, h * 0.25);
        canvas.drawPath(bodyPath, paint);

      case UiMessageAction.pin:
        // Pin icon.
        final path = Path()
          ..moveTo(w * 0.5, h * 0.9)
          ..lineTo(w * 0.5, h * 0.55)
          ..moveTo(w * 0.25, h * 0.55)
          ..lineTo(w * 0.75, h * 0.55)
          ..moveTo(w * 0.3, h * 0.55)
          ..lineTo(w * 0.35, h * 0.2)
          ..lineTo(w * 0.65, h * 0.2)
          ..lineTo(w * 0.7, h * 0.55);
        canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ActionIconPainter oldDelegate) =>
      action != oldDelegate.action || color != oldDelegate.color;
}
