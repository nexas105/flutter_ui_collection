import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_ecommerce_models.dart';

/// A horizontal stepper that tracks order progress through stages.
///
/// ```dart
/// UiOrderStatusTracker(
///   currentStatus: UiOrderStatus.shipped,
///   timestamps: {
///     UiOrderStatus.pending: DateTime(2026, 4, 20),
///     UiOrderStatus.confirmed: DateTime(2026, 4, 20),
///     UiOrderStatus.shipped: DateTime(2026, 4, 21),
///   },
/// )
/// ```
class UiOrderStatusTracker extends StatelessWidget {
  const UiOrderStatusTracker({
    super.key,
    required this.currentStatus,
    this.timestamps = const {},
  });

  /// The current order status.
  final UiOrderStatus currentStatus;

  /// Optional timestamps for each reached status.
  final Map<UiOrderStatus, DateTime> timestamps;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    // The display stages exclude 'cancelled' from the normal flow
    final stages = currentStatus == UiOrderStatus.cancelled
        ? [UiOrderStatus.pending, UiOrderStatus.cancelled]
        : [
            UiOrderStatus.pending,
            UiOrderStatus.confirmed,
            UiOrderStatus.shipped,
            UiOrderStatus.delivered,
          ];

    final currentIndex = stages.indexOf(currentStatus);

    return Container(
      padding: spacing.paddingMd,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: spacing.radiusMd,
        border: Border.all(color: colors.border, width: theme.borderWidth),
      ),
      child: Row(
        children: [
          for (int i = 0; i < stages.length; i++) ...[
            if (i > 0)
              Expanded(
                child: AnimatedContainer(
                  duration: theme.animationDuration,
                  height: 2,
                  color: i <= currentIndex ? colors.primary : colors.border,
                ),
              ),
            _StatusStep(
              status: stages[i],
              index: i,
              isActive: i == currentIndex,
              isCompleted: i < currentIndex,
              isCancelled: stages[i] == UiOrderStatus.cancelled,
              timestamp: timestamps[stages[i]],
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  const _StatusStep({
    required this.status,
    required this.index,
    required this.isActive,
    required this.isCompleted,
    required this.isCancelled,
    this.timestamp,
    required this.theme,
  });

  final UiOrderStatus status;
  final int index;
  final bool isActive;
  final bool isCompleted;
  final bool isCancelled;
  final DateTime? timestamp;
  final dynamic theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final Color circleColor;
    final Color iconColor;
    if (isCancelled) {
      circleColor = colors.error;
      iconColor = colors.onError;
    } else if (isCompleted || isActive) {
      circleColor = colors.primary;
      iconColor = colors.onPrimary;
    } else {
      circleColor = colors.border;
      iconColor = colors.onSurface;
    }

    List<BoxShadow>? glow;
    if (isActive && theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(
          color: circleColor.withValues(alpha: 0.4),
          blurRadius: 10,
        ),
      ];
    }

    final IconData icon;
    if (isCancelled) {
      icon = const IconData(0xe16a, fontFamily: 'MaterialIcons'); // close
    } else if (isCompleted) {
      icon = const IconData(0xe156, fontFamily: 'MaterialIcons'); // check
    } else {
      icon = _statusIcon(status);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: theme.animationDuration,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            boxShadow: glow,
          ),
          child: Center(
            child: Icon(icon, size: 18, color: iconColor),
          ),
        ),
        SizedBox(height: spacing.xs),
        Text(
          _statusLabel(status),
          style: (typo.labelSmall as TextStyle).copyWith(
            color: isActive || isCompleted
                ? colors.onSurface
                : (colors.onSurface as Color).withValues(alpha: 0.5),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        if (timestamp != null) ...[
          SizedBox(height: 2),
          Text(
            _formatDate(timestamp!),
            style: (typo.labelSmall as TextStyle).copyWith(
              color: (colors.onSurface as Color).withValues(alpha: 0.4),
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _statusLabel(UiOrderStatus status) {
    switch (status) {
      case UiOrderStatus.pending:
        return 'Pending';
      case UiOrderStatus.confirmed:
        return 'Confirmed';
      case UiOrderStatus.shipped:
        return 'Shipped';
      case UiOrderStatus.delivered:
        return 'Delivered';
      case UiOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _statusIcon(UiOrderStatus status) {
    switch (status) {
      case UiOrderStatus.pending:
        return const IconData(0xe8b5, fontFamily: 'MaterialIcons'); // schedule
      case UiOrderStatus.confirmed:
        return const IconData(0xe156, fontFamily: 'MaterialIcons'); // check
      case UiOrderStatus.shipped:
        return const IconData(0xe558, fontFamily: 'MaterialIcons'); // local_shipping
      case UiOrderStatus.delivered:
        return const IconData(0xe30c, fontFamily: 'MaterialIcons'); // home
      case UiOrderStatus.cancelled:
        return const IconData(0xe16a, fontFamily: 'MaterialIcons'); // close
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
