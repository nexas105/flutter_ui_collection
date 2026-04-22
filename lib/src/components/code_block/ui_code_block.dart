import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../../theme/ui_theme.dart';

/// A themed code block with monospace font and copy button.
///
/// ```dart
/// UiCodeBlock(
///   code: 'void main() {\n  print("Hello");\n}',
///   language: 'dart',
/// )
/// ```
class UiCodeBlock extends StatefulWidget {
  const UiCodeBlock({
    super.key,
    required this.code,
    this.language,
    this.showLineNumbers = false,
    this.showCopyButton = true,
    this.maxHeight,
  });

  final String code;

  /// Optional language label shown in the header.
  final String? language;

  final bool showLineNumbers;
  final bool showCopyButton;

  /// Max height before scrolling.
  final double? maxHeight;

  @override
  State<UiCodeBlock> createState() => _UiCodeBlockState();
}

class _UiCodeBlockState extends State<UiCodeBlock> {
  bool _copied = false;

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final codeStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      color: colors.onSurface,
      height: 1.5,
    );

    final lines = widget.code.split('\n');

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: spacing.radiusMd,
        border: Border.all(color: colors.border, width: theme.borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          if (widget.language != null || widget.showCopyButton)
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm, vertical: spacing.xs),
              decoration: BoxDecoration(
                color: colors.border.withValues(alpha: 0.3),
                border: Border(
                  bottom: BorderSide(
                      color: colors.border, width: theme.borderWidth),
                ),
              ),
              child: Row(
                children: [
                  if (widget.language != null)
                    Text(
                      widget.language!,
                      style: typo.labelSmall.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  const Spacer(),
                  if (widget.showCopyButton)
                    GestureDetector(
                      onTap: _copy,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _copied
                                  ? const IconData(0xe156,
                                      fontFamily: 'MaterialIcons')
                                  : const IconData(0xe190,
                                      fontFamily: 'MaterialIcons'),
                              size: 14,
                              color: _copied
                                  ? colors.success
                                  : colors.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _copied ? 'Copied!' : 'Copy',
                              style: typo.labelSmall.copyWith(
                                color: _copied
                                    ? colors.success
                                    : colors.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Code
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: widget.maxHeight ?? double.infinity,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                padding: spacing.paddingSm,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.showLineNumbers)
                      Padding(
                        padding: EdgeInsets.only(right: spacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (int i = 0; i < lines.length; i++)
                              Text(
                                '${i + 1}',
                                style: codeStyle.copyWith(
                                  color:
                                      colors.onSurface.withValues(alpha: 0.3),
                                ),
                              ),
                          ],
                        ),
                      ),
                    Text(widget.code, style: codeStyle),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
