import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Renders text with tappable @mentions and #hashtags highlighted.
///
/// Parses the [text] for patterns matching `@username` and `#hashtag`,
/// rendering them in distinct colors. Tapping on a mention or hashtag
/// triggers the corresponding callback.
///
/// ```dart
/// UiMentionText(
///   text: 'Hello @jane! Check out #flutter',
///   onMentionTap: (mention) => print(mention),
///   onHashtagTap: (tag) => print(tag),
/// )
/// ```
class UiMentionText extends StatelessWidget {
  const UiMentionText({
    super.key,
    required this.text,
    this.style,
    this.onMentionTap,
    this.onHashtagTap,
    this.mentionColor,
    this.hashtagColor,
    this.maxLines,
    this.overflow,
  });

  /// The raw text to parse for @mentions and #hashtags.
  final String text;

  /// Base text style. Falls back to theme bodyMedium.
  final TextStyle? style;

  /// Called when a @mention is tapped, with the username (without @).
  final ValueChanged<String>? onMentionTap;

  /// Called when a #hashtag is tapped, with the tag (without #).
  final ValueChanged<String>? onHashtagTap;

  /// Color for @mentions. Falls back to theme primary.
  final Color? mentionColor;

  /// Color for #hashtags. Falls back to theme secondary.
  final Color? hashtagColor;

  /// Maximum number of lines before truncation.
  final int? maxLines;

  /// How overflowing text is handled.
  final TextOverflow? overflow;

  static final RegExp _pattern = RegExp(r'(@\w+|#\w+)');

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final baseStyle = style ?? theme.typography.bodyMedium.copyWith(
      color: colors.onSurface,
    );
    final mColor = mentionColor ?? colors.primary;
    final hColor = hashtagColor ?? colors.secondary;

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in _pattern.allMatches(text)) {
      // Add plain text before this match.
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      final token = match.group(0)!;
      final isMention = token.startsWith('@');
      final value = token.substring(1); // strip @ or #

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: () {
              if (isMention) {
                onMentionTap?.call(value);
              } else {
                onHashtagTap?.call(value);
              }
            },
            child: Text(
              token,
              style: baseStyle.copyWith(
                color: isMention ? mColor : hColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );

      lastEnd = match.end;
    }

    // Add any remaining plain text.
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
