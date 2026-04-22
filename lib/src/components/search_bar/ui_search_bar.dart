import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed search bar with clear button and search icon.
///
/// ```dart
/// UiSearchBar(
///   placeholder: 'Search...',
///   onChanged: (q) => _filterResults(q),
///   onSubmitted: (q) => _search(q),
/// )
/// ```
class UiSearchBar extends StatefulWidget {
  const UiSearchBar({
    super.key,
    this.controller,
    this.placeholder = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool enabled;

  @override
  State<UiSearchBar> createState() => _UiSearchBarState();
}

class _UiSearchBarState extends State<UiSearchBar> {
  late final FocusNode _focusNode;
  TextEditingController? _internalController;
  bool _focused = false;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  bool get _hasText => _controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    _focusNode.requestFocus();
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
        BoxShadow(color: colors.glow!.withValues(alpha: 0.2), blurRadius: 10),
      ];
    }

    return AnimatedContainer(
      duration: theme.animationDuration,
      curve: theme.animationCurve,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: spacing.radiusFull,
        border: Border.all(color: borderColor, width: theme.borderWidth),
        boxShadow: shadows,
      ),
      padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.xs),
      child: Row(
        children: [
          Icon(
            const IconData(0xe567, fontFamily: 'MaterialIcons'),
            size: 20,
            color: colors.onSurface.withValues(alpha: 0.4),
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Stack(
              children: [
                if (!_hasText)
                  IgnorePointer(
                    child: Text(
                      widget.placeholder,
                      style: typo.bodyMedium.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                EditableText(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: typo.bodyMedium.copyWith(color: colors.onSurface),
                  cursorColor: colors.primary,
                  backgroundCursorColor: colors.surface,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  autofocus: widget.autofocus,
                  keyboardAppearance: colors.background.computeLuminance() > 0.5
                      ? Brightness.light
                      : Brightness.dark,
                  selectionColor: colors.primary.withValues(alpha: 0.3),
                  enableInteractiveSelection: true,
                ),
              ],
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: _clear,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: EdgeInsets.only(left: spacing.sm),
                  child: Icon(
                    const IconData(0xe16a, fontFamily: 'MaterialIcons'),
                    size: 18,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
