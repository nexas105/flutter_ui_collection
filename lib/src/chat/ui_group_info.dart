import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_chat_models.dart';

/// A group member with admin status.
class UiGroupMember {
  const UiGroupMember({
    required this.user,
    this.isAdmin = false,
  });

  /// The chat user.
  final UiChatUser user;

  /// Whether this member is an admin of the group.
  final bool isAdmin;
}

/// Group info view showing avatar, name, description, and members list.
///
/// Displays a large group avatar circle with initials, the group name,
/// member count, an optional description, and a scrollable list of members
/// with role badges.
///
/// ```dart
/// UiGroupInfo(
///   name: 'Flutter Devs',
///   description: 'A group for Flutter enthusiasts',
///   members: [
///     UiGroupMember(user: alice, isAdmin: true),
///     UiGroupMember(user: bob),
///   ],
///   onMemberTap: (user) => showProfile(user),
///   onLeave: () => leaveGroup(),
/// )
/// ```
class UiGroupInfo extends StatelessWidget {
  const UiGroupInfo({
    super.key,
    required this.name,
    this.description,
    required this.members,
    this.onMemberTap,
    this.onLeave,
  });

  /// The group name.
  final String name;

  /// Optional group description.
  final String? description;

  /// List of group members.
  final List<UiGroupMember> members;

  /// Called when a member row is tapped.
  final ValueChanged<UiChatUser>? onMemberTap;

  /// Called when the leave action is triggered.
  final VoidCallback? onLeave;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Column(
      children: [
        // Header section.
        Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            children: [
              // Large avatar.
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.secondary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: typo.headlineMedium.copyWith(
                    color: colors.onSecondary,
                  ),
                ),
              ),
              SizedBox(height: spacing.md),
              // Group name.
              Text(
                name,
                style: typo.titleLarge.copyWith(color: colors.onSurface),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.xs),
              // Member count.
              Text(
                '${members.length} member${members.length == 1 ? '' : 's'}',
                style: typo.bodySmall.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              // Description.
              if (description != null && description!.isNotEmpty) ...[
                SizedBox(height: spacing.md),
                Text(
                  description!,
                  style: typo.bodyMedium.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        // Divider.
        Container(
          height: theme.borderWidth,
          color: colors.border,
        ),
        // Members header.
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Members',
              style: typo.labelLarge.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
        // Members list.
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final user = member.user;
              final userInitials = user.name.isNotEmpty
                  ? user.name[0].toUpperCase()
                  : '?';

              return GestureDetector(
                onTap: onMemberTap != null
                    ? () => onMemberTap!(user)
                    : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.sm,
                  ),
                  child: Row(
                    children: [
                      // Member avatar.
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.secondary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          userInitials,
                          style: typo.labelMedium.copyWith(
                            color: colors.onSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: spacing.sm),
                      // Name + online indicator.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.name,
                              style: typo.bodyMedium.copyWith(
                                color: colors.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (user.isOnline)
                              Text(
                                'Online',
                                style: typo.bodySmall.copyWith(
                                  color: colors.success,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Role badge.
                      if (member.isAdmin)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.sm,
                            vertical: spacing.xs / 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: spacing.radiusFull,
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.4),
                              width: theme.borderWidth,
                            ),
                          ),
                          child: Text(
                            'Admin',
                            style: typo.labelSmall.copyWith(
                              color: colors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Leave button.
        if (onLeave != null) ...[
          Container(
            height: theme.borderWidth,
            color: colors.border,
          ),
          GestureDetector(
            onTap: onLeave,
            child: Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Text(
                'Leave Group',
                style: typo.labelLarge.copyWith(color: colors.error),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
