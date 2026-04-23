import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A single emoji reaction with count and ownership state.
class UiReaction {
  const UiReaction({
    required this.emoji,
    this.count = 1,
    this.isMine = false,
  });

  /// The emoji string (e.g. "👍").
  final String emoji;

  /// How many users added this reaction.
  final int count;

  /// Whether the current user has added this reaction.
  final bool isMine;
}

/// Displays emoji reaction pills below a message bubble.
///
/// Each pill shows an emoji and its count. Reactions belonging to the current
/// user are highlighted with a primary-colored border.
///
/// ```dart
/// UiMessageReactions(
///   reactions: [
///     UiReaction(emoji: '👍', count: 3, isMine: true),
///     UiReaction(emoji: '❤️', count: 1),
///   ],
///   onReactionTap: (emoji) => toggleReaction(emoji),
/// )
/// ```
class UiMessageReactions extends StatelessWidget {
  const UiMessageReactions({
    super.key,
    required this.reactions,
    this.onReactionTap,
  });

  /// The list of reactions to display.
  final List<UiReaction> reactions;

  /// Called when a reaction pill is tapped, with the emoji string.
  final ValueChanged<String>? onReactionTap;

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Wrap(
      spacing: spacing.xs,
      runSpacing: spacing.xs / 2,
      children: reactions.map((reaction) {
        final borderColor =
            reaction.isMine ? colors.primary : colors.border;
        final bgColor = reaction.isMine
            ? colors.primary.withValues(alpha: 0.12)
            : colors.surface;

        return GestureDetector(
          onTap: onReactionTap != null
              ? () => onReactionTap!(reaction.emoji)
              : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs / 2,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: spacing.radiusFull,
              border: Border.all(
                color: borderColor,
                width: reaction.isMine ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reaction.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
                SizedBox(width: spacing.xs / 2),
                Text(
                  reaction.count.toString(),
                  style: typo.labelSmall.copyWith(
                    color: reaction.isMine
                        ? colors.primary
                        : colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
