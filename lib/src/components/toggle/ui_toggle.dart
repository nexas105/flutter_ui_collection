import 'package:flutter/widgets.dart';

import '../../interaction/ui_interactive_region.dart';
import '../../theme/ui_theme.dart';

/// A themed toggle switch.
///
/// ```dart
/// UiToggle(
///   value: isOn,
///   onChanged: (v) => setState(() => isOn = v),
/// )
/// ```
class UiToggle extends StatelessWidget {
  const UiToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 24.0,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;
  final String? semanticLabel;

  bool get _enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;

    final trackWidth = size * 1.8;
    final trackHeight = size;
    final thumbSize = size * 0.75;
    final thumbPadding = (trackHeight - thumbSize) / 2;

    final trackColor = value ? colors.primary : colors.border;
    final thumbColor = value ? colors.onPrimary : colors.onSurface;

    List<BoxShadow>? glow;
    if (value && theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(color: colors.glow!.withValues(alpha: 0.4), blurRadius: 10),
      ];
    }

    final activate = _enabled ? () => onChanged!(!value) : null;

    return UiInteractiveRegion(
      enabled: _enabled,
      onActivate: activate,
      semanticLabel: semanticLabel,
      checked: value,
      borderRadius: BorderRadius.circular(trackHeight / 2),
      child: GestureDetector(
        onTap: activate,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Center(
            child: AnimatedContainer(
              duration: theme.animationDuration,
              curve: theme.animationCurve,
              width: trackWidth,
              height: trackHeight,
              decoration: BoxDecoration(
                color: _enabled
                    ? trackColor
                    : trackColor.withValues(
                        alpha: theme.components.disabledOpacity,
                      ),
                borderRadius: BorderRadius.circular(trackHeight / 2),
                boxShadow: glow,
              ),
              child: AnimatedAlign(
                duration: theme.animationDuration,
                curve: theme.animationCurve,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(thumbPadding),
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: thumbColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
