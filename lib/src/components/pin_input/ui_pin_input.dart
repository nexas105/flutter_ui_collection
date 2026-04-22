import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// A themed PIN/OTP code input.
///
/// ```dart
/// UiPinInput(
///   length: 6,
///   onCompleted: (code) => _verify(code),
/// )
/// ```
class UiPinInput extends StatefulWidget {
  const UiPinInput({
    super.key,
    this.length = 4,
    this.obscure = false,
    this.onChanged,
    this.onCompleted,
    this.autofocus = true,
    this.cellSize = 48.0,
    this.spacing = 12.0,
  });

  final int length;
  final bool obscure;
  final ValueChanged<String>? onChanged;

  /// Called when all cells are filled.
  final ValueChanged<String>? onCompleted;

  final bool autofocus;
  final double cellSize;
  final double spacing;

  @override
  State<UiPinInput> createState() => _UiPinInputState();
}

class _UiPinInputState extends State<UiPinInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
    final text = _controller.text;
    widget.onChanged?.call(text);
    if (text.length == widget.length) {
      widget.onCompleted?.call(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);

    final text = _controller.text;
    final focusedIndex = text.length.clamp(0, widget.length - 1);

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        children: [
          // Hidden text input
          Opacity(
            opacity: 0,
            child: SizedBox(
              width: 1,
              height: 1,
              child: EditableText(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(fontSize: 1),
                cursorColor: const Color(0x00000000),
                backgroundCursorColor: const Color(0x00000000),
                autofocus: widget.autofocus,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
              ),
            ),
          ),
          // Visual cells
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < widget.length; i++) ...[
                if (i > 0) SizedBox(width: widget.spacing),
                _PinCell(
                  value: i < text.length
                      ? (widget.obscure ? '\u2022' : text[i])
                      : null,
                  isFocused: _focusNode.hasFocus && i == focusedIndex,
                  size: widget.cellSize,
                  theme: theme,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PinCell extends StatelessWidget {
  const _PinCell({
    this.value,
    required this.isFocused,
    required this.size,
    required this.theme,
  });

  final String? value;
  final bool isFocused;
  final double size;
  final UiThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final typo = theme.typography;

    final borderColor = isFocused ? colors.primary : colors.border;
    final hasValue = value != null;

    List<BoxShadow>? glow;
    if (isFocused && theme.useGlow && colors.glow != null) {
      glow = [BoxShadow(color: colors.glow!.withValues(alpha: 0.3), blurRadius: 10)];
    }

    return AnimatedContainer(
      duration: theme.animationDuration,
      curve: theme.animationCurve,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: theme.spacing.radiusMd,
        border: Border.all(
          color: borderColor,
          width: isFocused ? theme.borderWidth + 0.5 : theme.borderWidth,
        ),
        boxShadow: glow,
      ),
      alignment: Alignment.center,
      child: hasValue
          ? Text(
              value!,
              style: typo.headlineSmall.copyWith(color: colors.onSurface),
            )
          : (isFocused
              ? Container(
                  width: 2,
                  height: size * 0.4,
                  color: colors.primary,
                )
              : null),
    );
  }
}
