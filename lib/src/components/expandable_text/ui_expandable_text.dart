import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A text widget that truncates after [maxLines] and shows a
/// "Read more" / "Show less" toggle.
///
/// Uses [AnimatedCrossFade] for a smooth transition between
/// the collapsed and expanded states.
///
/// ```dart
/// UiExpandableText(
///   text: longDescription,
///   maxLines: 3,
/// )
/// ```
class UiExpandableText extends StatefulWidget {
  const UiExpandableText({
    super.key,
    required this.text,
    this.maxLines = 3,
    this.expandLabel = 'Read more',
    this.collapseLabel = 'Show less',
    this.style,
  });

  final String text;
  final int maxLines;
  final String expandLabel;
  final String collapseLabel;
  final TextStyle? style;

  @override
  State<UiExpandableText> createState() => _UiExpandableTextState();
}

class _UiExpandableTextState extends State<UiExpandableText> {
  bool _expanded = false;
  bool _needsExpansion = false;

  @override
  void didUpdateWidget(UiExpandableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.maxLines != widget.maxLines) {
      _needsExpansion = false;
      _expanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final textStyle = widget.style ?? typo.bodyMedium.copyWith(color: colors.onSurface);
    final linkStyle = typo.labelMedium.copyWith(color: colors.primary);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Measure whether text exceeds maxLines.
        final textSpan = TextSpan(text: widget.text, style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final exceedsMaxLines = textPainter.didExceedMaxLines;
        // Update after build to avoid setState during build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _needsExpansion != exceedsMaxLines) {
            setState(() => _needsExpansion = exceedsMaxLines);
          }
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedCrossFade(
              duration: theme.animationDuration,
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                widget.text,
                style: textStyle,
                maxLines: widget.maxLines,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                widget.text,
                style: textStyle,
              ),
            ),
            if (_needsExpansion || _expanded) ...[
              SizedBox(height: spacing.xs),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    _expanded ? widget.collapseLabel : widget.expandLabel,
                    style: linkStyle,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
