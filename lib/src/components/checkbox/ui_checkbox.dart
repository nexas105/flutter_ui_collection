import 'package:flutter/widgets.dart';

import '../../interaction/ui_interactive_region.dart';
import '../../theme/ui_theme.dart';

/// A themed checkbox.
///
/// ```dart
/// UiCheckbox(
///   value: _agreed,
///   onChanged: (v) => setState(() => _agreed = v),
///   label: 'I agree to the terms',
/// )
/// ```
class UiCheckbox extends StatefulWidget {
  const UiCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.size = 22.0,
    this.enabled = true,
    this.tristate = false,
  });

  /// Current value. `null` represents indeterminate state when [tristate] is true.
  final bool? value;

  final ValueChanged<bool?>? onChanged;

  /// Optional label text shown next to the checkbox.
  final String? label;

  final double size;
  final bool enabled;

  /// If true, the checkbox cycles through true -> null -> false.
  final bool tristate;

  @override
  State<UiCheckbox> createState() => _UiCheckboxState();
}

class _UiCheckboxState extends State<UiCheckbox> {
  bool _hovered = false;

  void _toggle() {
    if (!widget.enabled || widget.onChanged == null) return;
    if (widget.tristate) {
      final next = switch (widget.value) {
        true => null,
        null => false,
        false => true,
      };
      widget.onChanged!(next);
    } else {
      widget.onChanged!(!(widget.value ?? false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final checked = widget.value == true;
    final indeterminate = widget.value == null && widget.tristate;
    final active = checked || indeterminate;

    final bgColor = active
        ? colors.primary
        : (_hovered
              ? colors.primary.withValues(alpha: 0.1)
              : const Color(0x00000000));
    final borderColor = active ? colors.primary : colors.border;

    List<BoxShadow>? glow;
    if (active && theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(color: colors.glow!.withValues(alpha: 0.25), blurRadius: 8),
      ];
    }

    final box = GestureDetector(
      onTap: _toggle,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          child: AnimatedContainer(
            duration: theme.animationDuration,
            curve: theme.animationCurve,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(widget.size * 0.2),
              border: Border.all(color: borderColor, width: theme.borderWidth),
              boxShadow: glow,
            ),
            child: active
                ? Center(
                    child: CustomPaint(
                      size: Size(widget.size * 0.55, widget.size * 0.55),
                      painter: indeterminate
                          ? _IndeterminatePainter(color: colors.onPrimary)
                          : _CheckPainter(color: colors.onPrimary),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );

    final content = widget.label == null
        ? Center(child: box)
        : GestureDetector(
            onTap: _toggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                box,
                SizedBox(width: spacing.sm),
                Flexible(
                  child: Text(
                    widget.label!,
                    style: typo.bodyMedium.copyWith(
                      color: widget.enabled
                          ? colors.onBackground
                          : colors.onBackground.withValues(
                              alpha: theme.components.disabledOpacity,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );

    return UiInteractiveRegion(
      enabled: widget.enabled && widget.onChanged != null,
      onActivate: _toggle,
      semanticLabel: widget.label,
      checked: widget.value,
      borderRadius: BorderRadius.circular(widget.size * 0.2),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        child: content,
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.5)
      ..lineTo(size.width * 0.4, size.height * 0.75)
      ..lineTo(size.width * 0.85, size.height * 0.2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => color != old.color;
}

class _IndeterminatePainter extends CustomPainter {
  _IndeterminatePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(_IndeterminatePainter old) => color != old.color;
}
