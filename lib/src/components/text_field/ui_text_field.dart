import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed text input field.
///
/// Renders a styled text input that adapts to the active theme,
/// including focus glow, border colors, and typography.
class UiTextField extends StatefulWidget {
  const UiTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.label,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final String? label;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  @override
  State<UiTextField> createState() => _UiTextFieldState();
}

class _UiTextFieldState extends State<UiTextField> {
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final borderColor = _focused ? colors.primary : colors.border;

    List<BoxShadow>? shadows;
    if (_focused && theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.3),
          blurRadius: 12,
        ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: typo.labelMedium.copyWith(color: colors.onBackground),
          ),
          SizedBox(height: spacing.xs),
        ],
        AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: spacing.radiusMd,
            border: Border.all(
              color: borderColor,
              width: _focused ? theme.borderWidth + 0.5 : theme.borderWidth,
            ),
            boxShadow: shadows,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.sm,
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null)
                Padding(
                  padding: EdgeInsets.only(left: spacing.sm),
                  child: Icon(
                    widget.prefixIcon,
                    size: 18,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              Expanded(
                child: EditableText(
                  controller: widget.controller ?? TextEditingController(),
                  focusNode: _focusNode,
                  style: typo.bodyMedium.copyWith(color: colors.onSurface),
                  cursorColor: colors.primary,
                  backgroundCursorColor: colors.surface,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  obscureText: widget.obscureText,
                  maxLines: widget.maxLines,
                  keyboardAppearance: Brightness.dark,
                ),
              ),
              if (widget.suffixIcon != null)
                Padding(
                  padding: EdgeInsets.only(right: spacing.sm),
                  child: Icon(
                    widget.suffixIcon,
                    size: 18,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
