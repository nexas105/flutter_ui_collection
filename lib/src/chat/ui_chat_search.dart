import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// In-chat search bar with result navigation.
///
/// Provides a text input for searching, a result count label, and up/down
/// arrows for navigating between matches.
///
/// ```dart
/// UiChatSearch(
///   onSearch: (query) => search(query),
///   resultCount: 12,
///   currentResult: 3,
///   onNext: () => nextResult(),
///   onPrevious: () => prevResult(),
///   onClose: () => closeSearch(),
/// )
/// ```
class UiChatSearch extends StatelessWidget {
  const UiChatSearch({
    super.key,
    this.onSearch,
    this.resultCount = 0,
    this.currentResult = 0,
    this.onNext,
    this.onPrevious,
    this.onClose,
  });

  /// Called when the search query changes.
  final ValueChanged<String>? onSearch;

  /// Total number of search results.
  final int resultCount;

  /// The 1-based index of the currently focused result.
  final int currentResult;

  /// Called to navigate to the next result.
  final VoidCallback? onNext;

  /// Called to navigate to the previous result.
  final VoidCallback? onPrevious;

  /// Called when the search bar is dismissed.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.border, width: theme.borderWidth),
        ),
      ),
      child: Row(
        children: [
          // Search input.
          Expanded(
            child: Container(
              height: 36,
              padding: EdgeInsets.symmetric(horizontal: spacing.sm),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: spacing.radiusFull,
                border: Border.all(
                  color: colors.border,
                  width: theme.borderWidth,
                ),
              ),
              child: EditableText(
                controller: TextEditingController(),
                focusNode: FocusNode(),
                style: typo.bodyMedium.copyWith(color: colors.onSurface),
                cursorColor: colors.primary,
                backgroundCursorColor: colors.onSurface.withValues(alpha: 0.1),
                onChanged: onSearch,
              ),
            ),
          ),
          // Result count.
          if (resultCount > 0) ...[
            SizedBox(width: spacing.sm),
            Text(
              '$currentResult of $resultCount',
              style: typo.labelSmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          // Up arrow.
          SizedBox(width: spacing.xs),
          GestureDetector(
            onTap: onPrevious,
            child: SizedBox(
              width: 28,
              height: 28,
              child: CustomPaint(
                painter: _ArrowPainter(
                  color: colors.onSurface.withValues(
                    alpha: onPrevious != null ? 0.8 : 0.3,
                  ),
                  pointsUp: true,
                ),
              ),
            ),
          ),
          // Down arrow.
          GestureDetector(
            onTap: onNext,
            child: SizedBox(
              width: 28,
              height: 28,
              child: CustomPaint(
                painter: _ArrowPainter(
                  color: colors.onSurface.withValues(
                    alpha: onNext != null ? 0.8 : 0.3,
                  ),
                  pointsUp: false,
                ),
              ),
            ),
          ),
          // Close button.
          SizedBox(width: spacing.xs),
          GestureDetector(
            onTap: onClose,
            child: SizedBox(
              width: 28,
              height: 28,
              child: CustomPaint(
                painter: _CloseIconPainter(
                  color: colors.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints an up or down chevron arrow.
class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.color, required this.pointsUp});

  final Color color;
  final bool pointsUp;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    if (pointsUp) {
      final path = Path()
        ..moveTo(cx - size.width * 0.2, size.height * 0.6)
        ..lineTo(cx, size.height * 0.35)
        ..lineTo(cx + size.width * 0.2, size.height * 0.6);
      canvas.drawPath(path, paint);
    } else {
      final path = Path()
        ..moveTo(cx - size.width * 0.2, size.height * 0.35)
        ..lineTo(cx, size.height * 0.6)
        ..lineTo(cx + size.width * 0.2, size.height * 0.35);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) =>
      color != oldDelegate.color || pointsUp != oldDelegate.pointsUp;
}

/// Paints an X (close) icon.
class _CloseIconPainter extends CustomPainter {
  _CloseIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final inset = size.width * 0.28;
    canvas.drawLine(
      Offset(inset, inset),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CloseIconPainter oldDelegate) =>
      color != oldDelegate.color;
}
