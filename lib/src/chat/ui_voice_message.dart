import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_chat_models.dart';
import 'ui_message_status_icon.dart';

/// Renders a voice message bubble with play/pause, waveform, and duration.
///
/// Shows a circular play/pause button on the left, a waveform visualization
/// in the center painted via [CustomPaint], and a duration label on the right.
/// Progress is shown as a colored overlay filling the waveform from the left.
///
/// ```dart
/// UiVoiceMessage(
///   duration: Duration(seconds: 42),
///   isMe: true,
///   isPlaying: false,
///   progress: 0.0,
///   onPlayPause: () => togglePlay(),
///   timestamp: DateTime.now(),
///   status: UiMessageStatus.read,
/// )
/// ```
class UiVoiceMessage extends StatelessWidget {
  const UiVoiceMessage({
    super.key,
    required this.duration,
    required this.isMe,
    this.isPlaying = false,
    this.progress = 0.0,
    this.onPlayPause,
    required this.timestamp,
    required this.status,
  });

  /// Total duration of the voice message.
  final Duration duration;

  /// Whether this message was sent by the current user.
  final bool isMe;

  /// Whether the voice message is currently playing.
  final bool isPlaying;

  /// Playback progress from 0.0 to 1.0.
  final double progress;

  /// Called when the play/pause button is tapped.
  final VoidCallback? onPlayPause;

  /// When the message was sent.
  final DateTime timestamp;

  /// Delivery status of the message.
  final UiMessageStatus status;

  String get _durationLabel {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final bubbleColor = isMe ? colors.primary : colors.surface;
    final textColor = isMe ? colors.onPrimary : colors.onSurface;
    final activeColor = isMe ? colors.onPrimary : colors.primary;
    final inactiveColor = textColor.withValues(alpha: 0.3);

    final radius = Radius.circular(spacing.borderRadiusLg);
    final sharpRadius = Radius.circular(spacing.borderRadiusSm);
    final borderRadius = isMe
        ? BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: sharpRadius,
          )
        : BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: sharpRadius,
            bottomRight: radius,
          );

    List<BoxShadow>? shadows;
    if (theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.2),
          blurRadius: 8,
        ),
      ];
    } else if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, 1),
          blurRadius: 3,
        ),
      ];
    }

    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final timeLabel = '$hour:$minute';

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm + 2,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: borderRadius,
        border: isMe
            ? null
            : Border.all(color: colors.border, width: theme.borderWidth),
        boxShadow: shadows,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Play/pause button.
              GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                  ),
                  child: CustomPaint(
                    size: const Size(36, 36),
                    painter: isPlaying
                        ? _PauseIconPainter(
                            color: bubbleColor,
                          )
                        : _PlayIconPainter(
                            color: bubbleColor,
                          ),
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              // Waveform.
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: CustomPaint(
                    painter: _WaveformPainter(
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      progress: progress.clamp(0.0, 1.0),
                    ),
                    size: const Size(double.infinity, 28),
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              // Duration.
              Text(
                _durationLabel,
                style: typo.labelSmall.copyWith(
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs / 2),
          // Timestamp + status.
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spacer(),
              Text(
                timeLabel,
                style: typo.labelSmall.copyWith(
                  color: textColor.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
              if (isMe) ...[
                SizedBox(width: spacing.xs / 2),
                UiMessageStatusIcon(status: status),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Paints a waveform visualization with ~30 bars of varying height.
class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.activeColor,
    required this.inactiveColor,
    required this.progress,
  });

  final Color activeColor;
  final Color inactiveColor;
  final double progress;

  // Deterministic pseudo-random bar heights.
  static const List<double> _barHeights = [
    0.3, 0.5, 0.7, 0.4, 0.9, 0.6, 0.8, 0.35, 0.55, 0.95,
    0.4, 0.7, 0.5, 0.85, 0.3, 0.65, 0.9, 0.45, 0.75, 0.5,
    0.6, 0.8, 0.35, 0.7, 0.55, 0.9, 0.4, 0.6, 0.8, 0.45,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 30;
    final barWidth = size.width / (barCount * 2 - 1);
    final progressX = size.width * progress;

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth * 2;
      final barH = _barHeights[i] * size.height;
      final top = (size.height - barH) / 2;
      final isActive = x + barWidth <= progressX;

      final paint = Paint()
        ..color = isActive ? activeColor : inactiveColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, top, barWidth, barH),
          Radius.circular(barWidth / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      activeColor != oldDelegate.activeColor ||
      inactiveColor != oldDelegate.inactiveColor ||
      progress != oldDelegate.progress;
}

/// Paints a play triangle icon.
class _PlayIconPainter extends CustomPainter {
  _PlayIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) * 0.2;

    final path = Path()
      ..moveTo(cx - r * 0.6, cy - r)
      ..lineTo(cx + r, cy)
      ..lineTo(cx - r * 0.6, cy + r)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PlayIconPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Paints two vertical pause bars.
class _PauseIconPainter extends CustomPainter {
  _PauseIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final barH = size.height * 0.32;
    final barW = size.width * 0.065;
    final gap = size.width * 0.08;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx - gap, cy),
          width: barW,
          height: barH,
        ),
        Radius.circular(barW / 2),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + gap, cy),
          width: barW,
          height: barH,
        ),
        Radius.circular(barW / 2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PauseIconPainter oldDelegate) =>
      color != oldDelegate.color;
}
