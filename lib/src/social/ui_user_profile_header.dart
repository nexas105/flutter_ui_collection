import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_social_models.dart';

/// A social media profile header with cover image area, overlapping avatar,
/// user info, stats row, and action buttons.
///
/// Inspired by Twitter/X, Instagram, and Facebook profile layouts.
///
/// ```dart
/// UiUserProfileHeader(
///   user: someUser,
///   bio: 'Flutter enthusiast and open source contributor.',
///   postCount: 128,
///   followerCount: 4200,
///   followingCount: 312,
///   isFollowing: false,
///   onFollow: () => followUser(),
///   onMessage: () => openChat(),
/// )
/// ```
class UiUserProfileHeader extends StatelessWidget {
  const UiUserProfileHeader({
    super.key,
    required this.user,
    this.bio,
    this.postCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    this.coverImage,
    this.onFollow,
    this.onMessage,
    this.onEditProfile,
    this.onUserTap,
    this.coverHeight = 140,
    this.avatarRadius = 40,
  });

  /// The user whose profile is displayed.
  final UiSocialUser user;

  /// Bio or description text.
  final String? bio;

  /// Number of posts.
  final int postCount;

  /// Number of followers.
  final int followerCount;

  /// Number of accounts this user follows.
  final int followingCount;

  /// Whether the current user is following this user.
  final bool isFollowing;

  /// Optional cover image URL (renders as colored placeholder).
  final String? coverImage;

  /// Called when the follow button is tapped.
  final VoidCallback? onFollow;

  /// Called when the message button is tapped.
  final VoidCallback? onMessage;

  /// Called when the edit profile button is tapped (shown instead of
  /// follow/message when viewing own profile).
  final VoidCallback? onEditProfile;

  /// Called when the avatar or name is tapped.
  final ValueChanged<UiSocialUser>? onUserTap;

  /// Height of the cover image area.
  final double coverHeight;

  /// Radius of the profile avatar.
  final double avatarRadius;

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final avatarDiameter = avatarRadius * 2;
    final avatarOverlap = avatarRadius; // half sticking out above.

    final initial =
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    final shadows = theme.useShadows
        ? [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : <BoxShadow>[];

    final glowShadows = theme.useGlow && colors.glow != null
        ? [
            BoxShadow(
              color: colors.glow!.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ]
        : <BoxShadow>[];

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: spacing.radiusMd,
        border: Border.all(
          color: colors.border,
          width: theme.borderWidth,
        ),
        boxShadow: [...shadows, ...glowShadows],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cover + avatar overlap area.
          SizedBox(
            height: coverHeight + avatarOverlap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover image area.
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(spacing.borderRadiusMd),
                    topRight: Radius.circular(spacing.borderRadiusMd),
                  ),
                  child: Container(
                    height: coverHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors.gradient ??
                            [
                              colors.primary.withValues(alpha: 0.3),
                              colors.secondary.withValues(alpha: 0.3),
                            ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                // Avatar circle overlapping cover.
                Positioned(
                  left: spacing.md,
                  top: coverHeight - avatarOverlap,
                  child: GestureDetector(
                    onTap: onUserTap != null
                        ? () => onUserTap!(user)
                        : null,
                    child: Container(
                      width: avatarDiameter,
                      height: avatarDiameter,
                      decoration: BoxDecoration(
                        color: colors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.surface,
                          width: 3,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: typo.titleLarge.copyWith(
                          color: colors.onSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.sm),
          // Name + username + verified badge.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        style: typo.titleLarge.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isVerified) ...[
                      SizedBox(width: spacing.xs),
                      _VerifiedBadge(
                        color: colors.primary,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                Text(
                  '@${user.username}',
                  style: typo.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          // Bio.
          if (bio != null && bio!.isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.md),
              child: Text(
                bio!,
                style: typo.bodyMedium.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
          SizedBox(height: spacing.md),
          // Stats row.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.md),
            child: Row(
              children: [
                _StatItem(
                  count: _formatCount(postCount),
                  label: 'Posts',
                  typo: typo,
                  colors: colors,
                ),
                SizedBox(width: spacing.lg),
                _StatItem(
                  count: _formatCount(followerCount),
                  label: 'Followers',
                  typo: typo,
                  colors: colors,
                ),
                SizedBox(width: spacing.lg),
                _StatItem(
                  count: _formatCount(followingCount),
                  label: 'Following',
                  typo: typo,
                  colors: colors,
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.md),
          // Action buttons.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.md),
            child: onEditProfile != null
                ? _ActionButton(
                    label: 'Edit Profile',
                    filled: false,
                    onTap: onEditProfile!,
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: isFollowing ? 'Following' : 'Follow',
                          filled: !isFollowing,
                          onTap: onFollow ?? () {},
                        ),
                      ),
                      if (onMessage != null) ...[
                        SizedBox(width: spacing.sm),
                        Expanded(
                          child: _ActionButton(
                            label: 'Message',
                            filled: false,
                            onTap: onMessage!,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          SizedBox(height: spacing.md),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.count,
    required this.label,
    required this.typo,
    required this.colors,
  });

  final String count;
  final String label;
  final dynamic typo;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: (typo.titleSmall as TextStyle).copyWith(
            color: colors.onSurface as Color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: (typo.labelSmall as TextStyle).copyWith(
            color: (colors.onSurface as Color).withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final bgColor = widget.filled
        ? (_pressed
            ? colors.primary.withValues(alpha: 0.85)
            : colors.primary)
        : (_pressed
            ? colors.primary.withValues(alpha: 0.08)
            : colors.surface);
    final textColor =
        widget.filled ? colors.onPrimary : colors.primary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: theme.animationDuration,
        curve: theme.animationCurve,
        padding: EdgeInsets.symmetric(
          vertical: spacing.sm,
          horizontal: spacing.md,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: spacing.radiusFull,
          border: Border.all(
            color: colors.primary,
            width: theme.borderWidth,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: typo.labelMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Custom-painted verified badge (checkmark in circle).
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _VerifiedPainter(color: color),
    );
  }
}

class _VerifiedPainter extends CustomPainter {
  _VerifiedPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), w / 2, bgPaint);

    final checkPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(w * 0.28, h * 0.5)
      ..lineTo(w * 0.44, h * 0.66)
      ..lineTo(w * 0.72, h * 0.34);

    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(_VerifiedPainter oldDelegate) =>
      oldDelegate.color != color;
}
