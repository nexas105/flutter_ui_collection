import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Typewriter text animation that reveals text character by character.
///
/// ```dart
/// UiTypewriter(
///   text: 'Welcome to the future.',
///   speed: Duration(milliseconds: 50),
///   style: theme.typography.headlineLarge,
/// )
/// ```
class UiTypewriter extends StatefulWidget {
  const UiTypewriter({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 60),
    this.startDelay = Duration.zero,
    this.cursor = '|',
    this.showCursor = true,
    this.onComplete,
    this.autoStart = true,
  });

  final String text;
  final TextStyle? style;

  /// Time between each character.
  final Duration speed;

  /// Delay before typing starts.
  final Duration startDelay;

  /// Cursor character shown at the end.
  final String cursor;

  final bool showCursor;

  /// Called when the full text has been typed.
  final VoidCallback? onComplete;

  final bool autoStart;

  @override
  State<UiTypewriter> createState() => UiTypewriterState();
}

class UiTypewriterState extends State<UiTypewriter> {
  int _charIndex = 0;
  Timer? _timer;
  bool _cursorVisible = true;
  Timer? _cursorTimer;
  bool _complete = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      Future.delayed(widget.startDelay, _startTyping);
    }
    if (widget.showCursor) {
      _cursorTimer = Timer.periodic(
        const Duration(milliseconds: 530),
        (_) {
          if (mounted) setState(() => _cursorVisible = !_cursorVisible);
        },
      );
    }
  }

  /// Manually start typing (if autoStart is false).
  void start() => _startTyping();

  /// Reset and optionally restart.
  void reset({bool autoStart = true}) {
    _timer?.cancel();
    setState(() {
      _charIndex = 0;
      _complete = false;
    });
    if (autoStart) {
      Future.delayed(widget.startDelay, _startTyping);
    }
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.speed, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_charIndex >= widget.text.length) {
        timer.cancel();
        setState(() => _complete = true);
        widget.onComplete?.call();
        return;
      }
      setState(() => _charIndex++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final resolvedStyle = widget.style ??
        theme.typography.bodyMedium.copyWith(
          color: theme.colorScheme.onBackground,
        );

    final displayText = widget.text.substring(0, _charIndex);
    final cursorStr =
        widget.showCursor && _cursorVisible && !_complete ? widget.cursor : '';

    return Text.rich(
      TextSpan(
        text: displayText,
        style: resolvedStyle,
        children: [
          if (cursorStr.isNotEmpty)
            TextSpan(
              text: cursorStr,
              style: resolvedStyle.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
