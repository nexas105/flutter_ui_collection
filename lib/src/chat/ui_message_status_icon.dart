import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_chat_models.dart';

/// Displays an icon representing the delivery status of a chat message.
///
/// ```dart
/// UiMessageStatusIcon(status: UiMessageStatus.read)
/// ```
class UiMessageStatusIcon extends StatelessWidget {
  const UiMessageStatusIcon({
    super.key,
    required this.status,
    this.size = 14.0,
  });

  /// The delivery status to represent.
  final UiMessageStatus status;

  /// Icon size. Defaults to 14.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;

    switch (status) {
      case UiMessageStatus.sending:
        return _ClockIcon(size: size, color: colors.resolvedOnSurfaceSubtle);
      case UiMessageStatus.sent:
        return _CheckIcon(size: size, color: colors.resolvedOnSurfaceSubtle);
      case UiMessageStatus.delivered:
        return _DoubleCheckIcon(
          size: size,
          color: colors.resolvedOnSurfaceSubtle,
        );
      case UiMessageStatus.read:
        return _DoubleCheckIcon(size: size, color: colors.primary);
      case UiMessageStatus.failed:
        return _ErrorIcon(size: size, color: colors.error);
    }
  }
}

class _ClockIcon extends StatelessWidget {
  const _ClockIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ClockPainter(color: color)),
    );
  }
}

class _ClockPainter extends CustomPainter {
  _ClockPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, radius, paint);

    // Hour hand
    canvas.drawLine(center, Offset(center.dx, center.dy - radius * 0.5), paint);
    // Minute hand
    canvas.drawLine(center, Offset(center.dx + radius * 0.4, center.dy), paint);
  }

  @override
  bool shouldRepaint(_ClockPainter oldDelegate) => color != oldDelegate.color;
}

class _CheckIcon extends StatelessWidget {
  const _CheckIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CheckPainter(color: color)),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.45, size.height * 0.75)
      ..lineTo(size.width * 0.8, size.height * 0.25);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => color != oldDelegate.color;
}

class _DoubleCheckIcon extends StatelessWidget {
  const _DoubleCheckIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DoubleCheckPainter(color: color)),
    );
  }
}

class _DoubleCheckPainter extends CustomPainter {
  _DoubleCheckPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // First check (back)
    final path1 = Path()
      ..moveTo(size.width * 0.05, size.height * 0.5)
      ..lineTo(size.width * 0.3, size.height * 0.75)
      ..lineTo(size.width * 0.65, size.height * 0.25);
    canvas.drawPath(path1, paint);

    // Second check (front)
    final path2 = Path()
      ..moveTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.75)
      ..lineTo(size.width * 0.9, size.height * 0.25);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(_DoubleCheckPainter oldDelegate) =>
      color != oldDelegate.color;
}

class _ErrorIcon extends StatelessWidget {
  const _ErrorIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ErrorPainter(color: color)),
    );
  }
}

class _ErrorPainter extends CustomPainter {
  _ErrorPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, radius, paint);

    // Exclamation mark body
    canvas.drawLine(
      Offset(center.dx, size.height * 0.2),
      Offset(center.dx, size.height * 0.6),
      paint..strokeWidth = 1.5,
    );

    // Exclamation mark dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx, size.height * 0.78), 1.2, dotPaint);
  }

  @override
  bool shouldRepaint(_ErrorPainter oldDelegate) => color != oldDelegate.color;
}
