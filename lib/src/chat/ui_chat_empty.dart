import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Empty state widget for a chat view.
///
/// Displays a large centered icon, title, and subtitle text. Uses theme
/// colors with reduced opacity for a subtle, non-intrusive appearance.
///
/// ```dart
/// UiChatEmpty(
///   title: 'No messages yet',
///   subtitle: 'Send a message to start the conversation',
/// )
/// ```
class UiChatEmpty extends StatelessWidget {
  const UiChatEmpty({
    super.key,
    this.icon,
    required this.title,
    this.subtitle = '',
  });

  /// Optional icon to display above the title. When provided, it is drawn
  /// using [CustomPaint] as a chat bubble shape. When `null`, a default
  /// chat bubble icon is shown.
  final IconData? icon;

  /// Primary text shown below the icon.
  final String title;

  /// Secondary text shown below the title.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final iconColor = colors.onSurface.withValues(alpha: 0.25);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon.
            if (icon != null)
              Text(
                String.fromCharCode(icon!.codePoint),
                style: TextStyle(
                  fontFamily: icon!.fontFamily,
                  package: icon!.fontPackage,
                  fontSize: 64,
                  color: iconColor,
                ),
              )
            else
              SizedBox(
                width: 64,
                height: 64,
                child: CustomPaint(
                  painter: _ChatBubbleIconPainter(color: iconColor),
                ),
              ),
            SizedBox(height: spacing.md),
            // Title.
            Text(
              title,
              style: typo.titleMedium.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle.isNotEmpty) ...[
              SizedBox(height: spacing.xs),
              Text(
                subtitle,
                style: typo.bodySmall.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.4),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Paints a simple chat bubble icon.
class _ChatBubbleIconPainter extends CustomPainter {
  _ChatBubbleIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.2, h * 0.15)
      ..lineTo(w * 0.8, h * 0.15)
      ..quadraticBezierTo(w * 0.95, h * 0.15, w * 0.95, h * 0.3)
      ..lineTo(w * 0.95, h * 0.55)
      ..quadraticBezierTo(w * 0.95, h * 0.7, w * 0.8, h * 0.7)
      ..lineTo(w * 0.4, h * 0.7)
      ..lineTo(w * 0.2, h * 0.88)
      ..lineTo(w * 0.2, h * 0.7)
      ..quadraticBezierTo(w * 0.05, h * 0.7, w * 0.05, h * 0.55)
      ..lineTo(w * 0.05, h * 0.3)
      ..quadraticBezierTo(w * 0.05, h * 0.15, w * 0.2, h * 0.15);

    canvas.drawPath(path, paint);

    // Three dots inside the bubble.
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dotY = h * 0.43;
    const dotR = 2.5;
    canvas.drawCircle(Offset(w * 0.35, dotY), dotR, dotPaint);
    canvas.drawCircle(Offset(w * 0.5, dotY), dotR, dotPaint);
    canvas.drawCircle(Offset(w * 0.65, dotY), dotR, dotPaint);
  }

  @override
  bool shouldRepaint(_ChatBubbleIconPainter oldDelegate) =>
      color != oldDelegate.color;
}
