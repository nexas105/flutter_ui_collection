import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// A themed auto-complete input with a filterable suggestion overlay.
///
/// ```dart
/// UiAutoComplete<String>(
///   suggestions: ['Apple', 'Banana', 'Cherry'],
///   itemBuilder: (item) => Text(item),
///   onSelected: (item) => print(item),
///   filter: (item, query) => item.toLowerCase().contains(query.toLowerCase()),
///   placeholder: 'Search fruit...',
/// )
/// ```
class UiAutoComplete<T> extends StatefulWidget {
  const UiAutoComplete({
    super.key,
    required this.suggestions,
    required this.itemBuilder,
    required this.onSelected,
    required this.filter,
    this.placeholder,
    this.label,
    this.enabled = true,
  });

  final List<T> suggestions;
  final Widget Function(T item) itemBuilder;
  final ValueChanged<T> onSelected;
  final bool Function(T item, String query) filter;
  final String? placeholder;
  final String? label;
  final bool enabled;

  @override
  State<UiAutoComplete<T>> createState() => _UiAutoCompleteState<T>();
}

class _UiAutoCompleteState<T> extends State<UiAutoComplete<T>> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<T> _filteredSuggestions = [];
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _updateFiltered();
      if (_filteredSuggestions.isNotEmpty) {
        _open();
      }
    } else {
      // Delay close to allow tap on suggestion
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!_focusNode.hasFocus && mounted) {
          _close();
        }
      });
    }
  }

  void _onTextChanged() {
    _updateFiltered();
    if (_filteredSuggestions.isNotEmpty && _focusNode.hasFocus) {
      if (_isOpen) {
        _overlayEntry?.markNeedsBuild();
      } else {
        _open();
      }
    } else {
      _close();
    }
  }

  void _updateFiltered() {
    final query = _controller.text;
    if (query.isEmpty) {
      _filteredSuggestions = List.of(widget.suggestions);
    } else {
      _filteredSuggestions = widget.suggestions
          .where((item) => widget.filter(item, query))
          .toList();
    }
  }

  void _open() {
    if (_isOpen) return;
    final theme = UiTheme.of(context);
    final renderBox = context.findRenderObject()! as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _AutoCompleteOverlay<T>(
        link: _layerLink,
        width: size.width,
        items: _filteredSuggestions,
        itemBuilder: widget.itemBuilder,
        theme: theme,
        onSelect: (item) {
          widget.onSelected(item);
          _controller.clear();
          _close();
          _focusNode.unfocus();
        },
        onDismiss: () {
          _close();
          _focusNode.unfocus();
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    if (mounted) setState(() => _isOpen = true);
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final borderColor = _isOpen ? colors.primary : colors.border;
    final opacity = widget.enabled ? 1.0 : 0.5;

    List<BoxShadow>? shadows;
    if (_isOpen && theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(color: colors.glow!.withValues(alpha: 0.2), blurRadius: 8),
      ];
    }

    return Opacity(
      opacity: opacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.xs),
              child: Text(
                widget.label!,
                style: typo.labelMedium.copyWith(color: colors.onSurface),
              ),
            ),
          CompositedTransformTarget(
            link: _layerLink,
            child: AnimatedContainer(
              duration: theme.animationDuration,
              curve: theme.animationCurve,
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: spacing.radiusMd,
                border: Border.all(
                  color: borderColor,
                  width: theme.borderWidth,
                ),
                boxShadow: shadows,
              ),
              child: EditableText(
                controller: _controller,
                focusNode: _focusNode,
                style: typo.bodyMedium.copyWith(color: colors.onSurface),
                cursorColor: colors.primary,
                backgroundCursorColor: colors.surface,
                readOnly: !widget.enabled,
                onChanged: (_) {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoCompleteOverlay<T> extends StatelessWidget {
  const _AutoCompleteOverlay({
    required this.link,
    required this.width,
    required this.items,
    required this.itemBuilder,
    required this.theme,
    required this.onSelect,
    required this.onDismiss,
  });

  final LayerLink link;
  final double width;
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final UiThemeData theme;
  final ValueChanged<T> onSelect;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    List<BoxShadow>? shadows;
    if (theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.15),
          blurRadius: 16,
        ),
      ];
    } else if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.shadow,
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onDismiss,
      child: SizedBox.expand(
        child: CompositedTransformFollower(
          link: link,
          offset: Offset(0, spacing.xs),
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: width,
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: spacing.radiusMd,
                border: Border.all(
                  color: colors.border,
                  width: theme.borderWidth,
                ),
                boxShadow: shadows,
              ),
              child: ClipRRect(
                borderRadius: spacing.radiusMd,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: spacing.xs),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => onSelect(items[index]),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.sm,
                            vertical: spacing.sm,
                          ),
                          child: DefaultTextStyle(
                            style: theme.typography.bodyMedium.copyWith(
                              color: colors.onSurface,
                            ),
                            child: itemBuilder(items[index]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
