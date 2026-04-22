import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A drawing pad for capturing signatures.
///
/// ```dart
/// UiSignaturePad(
///   onCompleted: (imageData) => saveSignature(imageData),
///   height: 200,
/// )
/// ```
class UiSignaturePad extends StatefulWidget {
  const UiSignaturePad({
    super.key,
    this.onCompleted,
    this.penColor,
    this.penWidth = 2.0,
    this.backgroundColor,
    this.height = 200.0,
    this.showControls = true,
  });

  /// Called with PNG byte data when the user finishes signing.
  final ValueChanged<ui.Image>? onCompleted;

  /// Pen stroke color. Defaults to `onSurface`.
  final Color? penColor;

  /// Pen stroke width. Defaults to `2.0`.
  final double penWidth;

  /// Background color. Defaults to `surface`.
  final Color? backgroundColor;

  /// Height of the pad. Defaults to `200.0`.
  final double height;

  /// Whether to show clear/undo control buttons.
  final bool showControls;

  @override
  State<UiSignaturePad> createState() => _UiSignaturePadState();
}

class _UiSignaturePadState extends State<UiSignaturePad> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentStroke = [details.localPosition];
      _strokes.add(_currentStroke);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStroke.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // Stroke is already added to _strokes.
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.removeLast();
    });
  }

  Future<void> _complete(Size size) async {
    if (widget.onCompleted == null || _strokes.isEmpty) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final theme = UiTheme.of(context);
    final penColor = widget.penColor ?? theme.colorScheme.onSurface;

    final paint = Paint()
      ..color = penColor
      ..strokeWidth = widget.penWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in _strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke[0].dx, stroke[0].dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    widget.onCompleted!(image);
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final bgColor = widget.backgroundColor ?? colors.surface;
    final penColor = widget.penColor ?? colors.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: spacing.radiusMd,
            border: Border.all(color: colors.border, width: theme.borderWidth),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _SignaturePainter(
                    strokes: _strokes,
                    color: penColor,
                    strokeWidth: widget.penWidth,
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.showControls) ...[
          SizedBox(height: spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _undo,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: spacing.radiusSm,
                      border: Border.all(
                        color: colors.border,
                        width: theme.borderWidth,
                      ),
                    ),
                    child: Text(
                      'Undo',
                      style: typo.labelSmall.copyWith(color: colors.onSurface),
                    ),
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              GestureDetector(
                onTap: _clear,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.1),
                      borderRadius: spacing.radiusSm,
                      border: Border.all(
                        color: colors.error.withValues(alpha: 0.3),
                        width: theme.borderWidth,
                      ),
                    ),
                    child: Text(
                      'Clear',
                      style: typo.labelSmall.copyWith(color: colors.error),
                    ),
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onTap: () => _complete(
                      Size(constraints.maxWidth, widget.height),
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.sm,
                          vertical: spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: spacing.radiusSm,
                        ),
                        child: Text(
                          'Done',
                          style:
                              typo.labelSmall.copyWith(color: colors.onPrimary),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({
    required this.strokes,
    required this.color,
    required this.strokeWidth,
  });

  final List<List<Offset>> strokes;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke[0].dx, stroke[0].dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => true;
}
