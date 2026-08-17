import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A single item in a [UiProgressList].
class UiProgressItem {
  const UiProgressItem({
    required this.label,
    required this.value,
    this.color,
    this.trailing,
  });

  /// Label displayed to the left of the progress bar.
  final String label;

  /// Progress value from 0.0 to 1.0.
  final double value;

  /// Override color for this item's bar. Falls back to [UiColorScheme.primary].
  final Color? color;

  /// Optional trailing text (e.g. "72%") displayed to the right.
  final String? trailing;
}

/// A list of labeled progress bars.
///
/// ```dart
/// UiProgressList(
///   items: [
///     UiProgressItem(label: 'CSS', value: 0.9, trailing: '90%'),
///     UiProgressItem(label: 'HTML', value: 0.8, trailing: '80%'),
///     UiProgressItem(label: 'Dart', value: 0.65, trailing: '65%'),
///   ],
/// )
/// ```
class UiProgressList extends StatelessWidget {
  const UiProgressList({super.key, required this.items, this.animated = true});

  /// The progress items to display.
  final List<UiProgressItem> items;

  /// Whether to animate the progress bars.
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final spacing = theme.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _ProgressRow(item: items[i], animated: animated),
          if (i < items.length - 1) SizedBox(height: spacing.sm),
        ],
      ],
    );
  }
}

class _ProgressRow extends StatefulWidget {
  const _ProgressRow({required this.item, required this.animated});

  final UiProgressItem item;
  final bool animated;

  @override
  State<_ProgressRow> createState() => _ProgressRowState();
}

class _ProgressRowState extends State<_ProgressRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    if (widget.animated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_ProgressRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.value != oldWidget.item.value && widget.animated) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final barColor = widget.item.color ?? colors.primary;
    final clamped = widget.item.value.clamp(0.0, 1.0);

    return Row(
      children: [
        // Label
        SizedBox(
          width: 80,
          child: Text(
            widget.item.label,
            style: typo.bodySmall.copyWith(color: colors.onSurface),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: spacing.sm),

        // Progress bar
        Expanded(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  color: colors.resolvedBorderSubtle,
                  borderRadius: spacing.radiusFull,
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: clamped * _animation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: spacing.radiusFull,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Trailing text
        if (widget.item.trailing != null) ...[
          SizedBox(width: spacing.sm),
          SizedBox(
            width: 40,
            child: Text(
              widget.item.trailing!,
              style: typo.labelSmall.copyWith(
                color: colors.resolvedOnSurfaceMuted,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ],
    );
  }
}
