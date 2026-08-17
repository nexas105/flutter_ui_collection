import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../icons/ui_icons.dart';
import '../../theme/ui_theme.dart';

/// A themed text input field with full input support.
///
/// Supports placeholder text, error/helper text, selection,
/// copy/paste, and adapts to the active theme including
/// focus glow, border colors, and keyboard brightness.
///
/// ```dart
/// UiTextField(
///   label: 'Email',
///   placeholder: 'you@example.com',
///   errorText: _emailError,
///   prefixIcon: UiIcons.email,
/// )
/// ```
class UiTextField extends StatefulWidget {
  const UiTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.label,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixWidget,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.focusNode,
    this.textAlign = TextAlign.start,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final String? label;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  /// Custom suffix widget (takes priority over [suffixIcon]).
  final Widget? suffixWidget;

  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextAlign textAlign;

  bool get hasError => errorText != null;

  @override
  State<UiTextField> createState() => _UiTextFieldState();
}

class _UiTextFieldState extends State<UiTextField> {
  FocusNode? _internalFocusNode;
  TextEditingController? _internalController;
  bool _focused = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  bool get _isEmpty => _controller.text.isEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(UiTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)?.removeListener(
        _onFocusChanged,
      );
      _focusNode.addListener(_onFocusChanged);
    }
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internalController)?.removeListener(
        _onTextChanged,
      );
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _controller.removeListener(_onTextChanged);
    _internalFocusNode?.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() => _focused = _focusNode.hasFocus);
  }

  void _onTextChanged() {
    if (mounted) setState(() {}); // rebuild for placeholder visibility
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    // Border color by state
    final Color borderColor;
    if (!widget.enabled) {
      borderColor = colors.border.withValues(alpha: 0.4);
    } else if (widget.hasError) {
      borderColor = colors.error;
    } else if (_focused) {
      borderColor = colors.primary;
    } else {
      borderColor = colors.border;
    }

    // Glow
    List<BoxShadow>? shadows;
    if (_focused && widget.enabled && theme.useGlow && colors.glow != null) {
      final glowColor = widget.hasError ? colors.error : colors.glow!;
      shadows = [
        BoxShadow(color: glowColor.withValues(alpha: 0.3), blurRadius: 12),
      ];
    }

    // Keyboard brightness
    final bgLuminance = colors.background.computeLuminance();
    final keyboardBrightness = bgLuminance > 0.5
        ? Brightness.light
        : Brightness.dark;

    // Text styles
    final inputStyle = typo.bodyMedium.copyWith(color: colors.onSurface);
    final placeholderStyle = typo.bodyMedium.copyWith(
      color: colors.onSurface.withValues(alpha: 0.35),
    );

    // The actual input widget
    final inputWidget = EditableText(
      controller: _controller,
      focusNode: _focusNode,
      style: inputStyle,
      cursorColor: widget.hasError ? colors.error : colors.primary,
      backgroundCursorColor: colors.surface,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      readOnly: widget.readOnly || !widget.enabled,
      autofocus: widget.autofocus,
      keyboardAppearance: keyboardBrightness,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      textAlign: widget.textAlign,
      selectionColor: (widget.hasError ? colors.error : colors.primary)
          .withValues(alpha: 0.3),
      enableInteractiveSelection: true,
    );

    // Suffix resolution
    Widget? suffix;
    if (widget.hasError) {
      suffix = Icon(UiIcons.error, size: 18, color: colors.error);
    } else if (widget.suffixWidget != null) {
      suffix = widget.suffixWidget;
    } else if (widget.suffixIcon != null) {
      suffix = Icon(
        widget.suffixIcon,
        size: 18,
        color: colors.onSurface.withValues(alpha: 0.5),
      );
    }

    return Opacity(
      opacity: widget.enabled ? 1.0 : theme.components.disabledOpacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: typo.labelMedium.copyWith(
                color: widget.hasError ? colors.error : colors.onBackground,
              ),
            ),
            SizedBox(height: spacing.xs),
          ],

          // Input container
          GestureDetector(
            onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
            child: AnimatedContainer(
              duration: theme.animationDuration,
              curve: theme.animationCurve,
              decoration: BoxDecoration(
                color: widget.enabled
                    ? colors.surface
                    : colors.surface.withValues(alpha: 0.5),
                borderRadius: theme.components.controlBorderRadius,
                border: Border.all(
                  color: borderColor,
                  width: _focused
                      ? theme.components.focusRingWidth
                      : theme.borderWidth,
                ),
                boxShadow: shadows,
              ),
              constraints: BoxConstraints(
                minHeight: theme.components.controlHeightMedium,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.sm,
              ),
              child: Row(
                crossAxisAlignment: widget.maxLines > 1
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  if (widget.prefixIcon != null)
                    Padding(
                      padding: EdgeInsets.only(right: spacing.sm),
                      child: Icon(
                        widget.prefixIcon,
                        size: 18,
                        color: widget.hasError
                            ? colors.error
                            : colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  Expanded(
                    child: Stack(
                      children: [
                        // Placeholder
                        if (_isEmpty && widget.placeholder != null)
                          IgnorePointer(
                            child: Text(
                              widget.placeholder!,
                              style: placeholderStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        // Actual input
                        inputWidget,
                      ],
                    ),
                  ),
                  if (suffix != null)
                    Padding(
                      padding: EdgeInsets.only(left: spacing.sm),
                      child: suffix,
                    ),
                ],
              ),
            ),
          ),

          // Helper / error text + counter
          if (widget.errorText != null ||
              widget.helperText != null ||
              widget.maxLength != null) ...[
            SizedBox(height: spacing.xs),
            Row(
              children: [
                if (widget.errorText != null || widget.helperText != null)
                  Expanded(
                    child: Text(
                      widget.errorText ?? widget.helperText!,
                      style: typo.bodySmall.copyWith(
                        color: widget.hasError
                            ? colors.error
                            : colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (widget.maxLength != null)
                  Text(
                    '${_controller.text.length}/${widget.maxLength}',
                    style: typo.bodySmall.copyWith(
                      color: _controller.text.length > widget.maxLength!
                          ? colors.error
                          : colors.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
