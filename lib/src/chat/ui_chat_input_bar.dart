import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_chat_models.dart';
import 'ui_reply_preview.dart';

/// A themed chat input bar with optional attachment button and reply preview.
///
/// Uses raw [EditableText] to avoid Material dependencies. Shows a
/// placeholder via a [Stack] overlay and an optional reply preview bar
/// above the input when [replyTo] is set.
///
/// ```dart
/// UiChatInputBar(
///   onSend: (text) => sendMessage(text),
///   onAttach: () => pickAttachment(),
///   replyTo: replyMessage,
///   onCancelReply: () => setState(() => _reply = null),
/// )
/// ```
class UiChatInputBar extends StatefulWidget {
  const UiChatInputBar({
    super.key,
    required this.onSend,
    this.onAttach,
    this.replyTo,
    this.onCancelReply,
    this.placeholder = 'Type a message...',
    this.enabled = true,
  });

  /// Called with the trimmed text when the user taps send.
  final ValueChanged<String> onSend;

  /// Called when the attachment button is tapped. When null, no
  /// attachment button is shown.
  final VoidCallback? onAttach;

  /// When non-null, shows a reply preview bar above the input.
  final UiChatMessage? replyTo;

  /// Called when the user dismisses the reply preview.
  final VoidCallback? onCancelReply;

  /// Placeholder text shown when the input is empty.
  final String placeholder;

  /// Whether the input is enabled.
  final bool enabled;

  @override
  State<UiChatInputBar> createState() => _UiChatInputBarState();
}

class _UiChatInputBarState extends State<UiChatInputBar> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    List<BoxShadow>? sendGlow;
    if (theme.useGlow && colors.glow != null) {
      sendGlow = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.4),
          blurRadius: 8,
        ),
      ];
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reply preview bar.
        if (widget.replyTo != null)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                bottom: BorderSide(
                  color: colors.border.withValues(alpha: 0.3),
                  width: theme.borderWidth,
                ),
              ),
            ),
            child: UiChatReplyPreview(
              message: widget.replyTo!,
              onDismiss: widget.onCancelReply,
            ),
          ),
        // Input row.
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              top: BorderSide(
                color: colors.border,
                width: theme.borderWidth,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment button.
              if (widget.onAttach != null)
                GestureDetector(
                  onTap: widget.enabled ? widget.onAttach : null,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: spacing.sm,
                      bottom: spacing.xs / 2,
                    ),
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CustomPaint(
                        painter: _AttachPainter(
                          color: widget.enabled
                              ? colors.onSurface.withValues(alpha: 0.6)
                              : colors.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              // Text input.
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 36, maxHeight: 120),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: spacing.radiusFull,
                    border: Border.all(
                      color: colors.border,
                      width: theme.borderWidth,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (!_hasText)
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.placeholder,
                              style: typo.bodyMedium.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                      EditableText(
                        controller: _textController,
                        focusNode: _focusNode,
                        style: typo.bodyMedium.copyWith(
                          color: colors.onSurface,
                        ),
                        cursorColor: colors.primary,
                        backgroundCursorColor: colors.border,
                        maxLines: null,
                        readOnly: !widget.enabled,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              // Send button.
              GestureDetector(
                onTap: (_hasText && widget.enabled) ? _handleSend : null,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (_hasText && widget.enabled)
                        ? colors.primary
                        : colors.primary.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    boxShadow: (_hasText && widget.enabled) ? sendGlow : null,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CustomPaint(
                        painter: _SendArrowPainter(color: colors.onPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SendArrowPainter extends CustomPainter {
  _SendArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Rightward-pointing send arrow.
    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.5)
      ..lineTo(size.width * 0.15, size.height * 0.9)
      ..lineTo(size.width * 0.25, size.height * 0.5)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SendArrowPainter oldDelegate) =>
      color != oldDelegate.color;
}

class _AttachPainter extends CustomPainter {
  _AttachPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Plus / add icon.
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.8),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(_AttachPainter oldDelegate) => color != oldDelegate.color;
}
