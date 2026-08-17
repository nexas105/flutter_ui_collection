import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// WhatsApp-style chat header bar with avatar, name, status, and action icons.
///
/// Shows a back arrow, avatar circle with initials, name with subtitle
/// (online status, last seen, or typing indicator), and action buttons
/// for call, video, and more.
///
/// ```dart
/// UiChatHeader(
///   name: 'Alice',
///   avatarInitials: 'A',
///   isOnline: true,
///   onBack: () => Navigator.pop(context),
///   onCall: () => startCall(),
///   onVideo: () => startVideo(),
///   onMore: () => showMenu(),
/// )
/// ```
class UiChatHeader extends StatelessWidget {
  const UiChatHeader({
    super.key,
    required this.name,
    required this.avatarInitials,
    this.isOnline = false,
    this.lastSeen,
    this.isTyping = false,
    this.onBack,
    this.onCall,
    this.onVideo,
    this.onMore,
  });

  /// Display name shown in the header.
  final String name;

  /// Initials rendered inside the avatar circle.
  final String avatarInitials;

  /// Whether the user is currently online.
  final bool isOnline;

  /// When the user was last seen. Ignored if [isOnline] or [isTyping].
  final DateTime? lastSeen;

  /// Whether the other user is currently typing.
  final bool isTyping;

  /// Called when the back arrow is tapped.
  final VoidCallback? onBack;

  /// Called when the phone icon is tapped.
  final VoidCallback? onCall;

  /// Called when the video icon is tapped.
  final VoidCallback? onVideo;

  /// Called when the more (3-dots) icon is tapped.
  final VoidCallback? onMore;

  String get _subtitle {
    if (isTyping) return 'typing...';
    if (isOnline) return 'Online';
    if (lastSeen != null) {
      final now = DateTime.now();
      final diff = now.difference(lastSeen!);
      if (diff.inMinutes < 1) return 'Last seen just now';
      if (diff.inMinutes < 60) return 'Last seen ${diff.inMinutes}m ago';
      if (diff.inHours < 24) return 'Last seen ${diff.inHours}h ago';
      return 'Last seen ${lastSeen!.day}/${lastSeen!.month}/${lastSeen!.year}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.border, width: theme.borderWidth),
        ),
      ),
      child: Row(
        children: [
          // Back arrow.
          GestureDetector(
            onTap: onBack,
            child: SizedBox(
              width: 32,
              height: 32,
              child: CustomPaint(
                painter: _BackArrowPainter(color: colors.onSurface),
              ),
            ),
          ),
          SizedBox(width: spacing.sm),
          // Avatar.
          Container(
            width: theme.components.controlHeightSmall,
            height: theme.components.controlHeightSmall,
            decoration: BoxDecoration(
              color: colors.secondary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              avatarInitials,
              style: typo.labelMedium.copyWith(color: colors.onSecondary),
            ),
          ),
          SizedBox(width: spacing.sm),
          // Name + subtitle.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: typo.titleSmall.copyWith(color: colors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_subtitle.isNotEmpty)
                  Text(
                    _subtitle,
                    style: typo.bodySmall.copyWith(
                      color: isTyping
                          ? colors.primary
                          : colors.resolvedOnSurfaceMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          // Action icons.
          if (onCall != null)
            GestureDetector(
              onTap: onCall,
              child: Padding(
                padding: EdgeInsets.all(spacing.sm),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CustomPaint(
                    painter: _PhoneIconPainter(color: colors.onSurface),
                  ),
                ),
              ),
            ),
          if (onVideo != null)
            GestureDetector(
              onTap: onVideo,
              child: Padding(
                padding: EdgeInsets.all(spacing.sm),
                child: SizedBox(
                  width: 22,
                  height: 18,
                  child: CustomPaint(
                    painter: _VideoIconPainter(color: colors.onSurface),
                  ),
                ),
              ),
            ),
          if (onMore != null)
            GestureDetector(
              onTap: onMore,
              child: Padding(
                padding: EdgeInsets.all(spacing.sm),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CustomPaint(
                    painter: _MoreIconPainter(color: colors.onSurface),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Paints a left-pointing arrow (back button).
class _BackArrowPainter extends CustomPainter {
  _BackArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cy = size.height / 2;
    final path = Path()
      ..moveTo(size.width * 0.55, size.height * 0.2)
      ..lineTo(size.width * 0.25, cy)
      ..lineTo(size.width * 0.55, size.height * 0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BackArrowPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Paints a simple phone icon.
class _PhoneIconPainter extends CustomPainter {
  _PhoneIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.13, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.55,
        size.width * 0.38,
        size.height * 0.72,
      )
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.88,
        size.width * 0.87,
        size.height * 0.8,
      )
      ..lineTo(size.width * 0.75, size.height * 0.62)
      ..lineTo(size.width * 0.55, size.height * 0.55)
      ..lineTo(size.width * 0.48, size.height * 0.48)
      ..lineTo(size.width * 0.4, size.height * 0.4)
      ..lineTo(size.width * 0.35, size.height * 0.28)
      ..lineTo(size.width * 0.28, size.height * 0.15)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PhoneIconPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Paints a video camera icon.
class _VideoIconPainter extends CustomPainter {
  _VideoIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Camera body.
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        0,
        size.height * 0.15,
        size.width * 0.65,
        size.height * 0.7,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(bodyRect, paint);

    // Lens triangle.
    final lensPath = Path()
      ..moveTo(size.width * 0.65, size.height * 0.3)
      ..lineTo(size.width * 0.95, size.height * 0.15)
      ..lineTo(size.width * 0.95, size.height * 0.85)
      ..lineTo(size.width * 0.65, size.height * 0.7);

    canvas.drawPath(lensPath, paint);
  }

  @override
  bool shouldRepaint(_VideoIconPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Paints three vertical dots (more menu).
class _MoreIconPainter extends CustomPainter {
  _MoreIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    const dotRadius = 2.0;

    canvas.drawCircle(Offset(cx, size.height * 0.2), dotRadius, paint);
    canvas.drawCircle(Offset(cx, size.height * 0.5), dotRadius, paint);
    canvas.drawCircle(Offset(cx, size.height * 0.8), dotRadius, paint);
  }

  @override
  bool shouldRepaint(_MoreIconPainter oldDelegate) =>
      color != oldDelegate.color;
}
