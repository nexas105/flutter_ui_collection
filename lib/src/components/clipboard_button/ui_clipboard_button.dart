import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A button that copies text to the clipboard and shows confirmation.
///
/// ```dart
/// UiClipboardButton(text: 'npm install flutter_ui')
/// UiClipboardButton(
///   text: 'secret-token-123',
///   child: Text('Copy Token'),
/// )
/// ```
class UiClipboardButton extends StatefulWidget {
  const UiClipboardButton({
    super.key,
    required this.text,
    this.child,
    this.copiedLabel = 'Copied!',
    this.onCopied,
  });

  /// The text to copy to the clipboard.
  final String text;

  /// Optional custom trigger widget. Falls back to a copy icon button.
  final Widget? child;

  /// Label shown after a successful copy. Defaults to `'Copied!'`.
  final String copiedLabel;

  /// Called after the text has been copied.
  final VoidCallback? onCopied;

  @override
  State<UiClipboardButton> createState() => _UiClipboardButtonState();
}

class _UiClipboardButtonState extends State<UiClipboardButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    widget.onCopied?.call();
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    List<BoxShadow>? glow;
    if (theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.15),
          blurRadius: 6,
        ),
      ];
    }

    final defaultChild = AnimatedSwitcher(
      duration: theme.animationDuration,
      child: _copied
          ? Row(
              key: const ValueKey('copied'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  const IconData(0xe156, fontFamily: 'MaterialIcons'),
                  size: 16,
                  color: colors.success,
                ),
                SizedBox(width: spacing.xs),
                Text(
                  widget.copiedLabel,
                  style: typo.labelSmall.copyWith(color: colors.success),
                ),
              ],
            )
          : Icon(
              key: const ValueKey('copy'),
              const IconData(0xe190, fontFamily: 'MaterialIcons'),
              size: 16,
              color: colors.onSurface,
            ),
    );

    return GestureDetector(
      onTap: _copied ? null : _copy,
      child: MouseRegion(
        cursor: _copied
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.all(spacing.xs),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: spacing.radiusSm,
            border: Border.all(color: colors.border, width: theme.borderWidth),
            boxShadow: glow,
          ),
          child: widget.child ?? defaultChild,
        ),
      ),
    );
  }
}
