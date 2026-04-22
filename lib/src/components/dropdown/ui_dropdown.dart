import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// A themed dropdown menu.
///
/// ```dart
/// UiDropdown<String>(
///   value: _selected,
///   items: ['Apple', 'Banana', 'Cherry'],
///   itemBuilder: (item) => Text(item),
///   onChanged: (v) => setState(() => _selected = v),
///   placeholder: 'Select fruit...',
/// )
/// ```
class UiDropdown<T> extends StatefulWidget {
  const UiDropdown({
    super.key,
    this.value,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    this.placeholder,
    this.selectedBuilder,
  });

  final T? value;
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final ValueChanged<T> onChanged;
  final String? placeholder;

  /// Custom builder for the selected value display.
  /// If null, uses [itemBuilder].
  final Widget Function(T item)? selectedBuilder;

  @override
  State<UiDropdown<T>> createState() => _UiDropdownState<T>();
}

class _UiDropdownState<T> extends State<UiDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    final theme = UiTheme.of(context);
    final renderBox = context.findRenderObject()! as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _DropdownOverlay<T>(
        link: _layerLink,
        width: size.width,
        items: widget.items,
        itemBuilder: widget.itemBuilder,
        theme: theme,
        onSelect: (item) {
          widget.onChanged(item);
          _close();
        },
        onDismiss: _close,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final borderColor = _isOpen ? colors.primary : colors.border;

    List<BoxShadow>? shadows;
    if (_isOpen && theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(color: colors.glow!.withValues(alpha: 0.2), blurRadius: 8),
      ];
    }

    Widget display;
    if (widget.value != null) {
      final builder = widget.selectedBuilder ?? widget.itemBuilder;
      display = DefaultTextStyle(
        style: typo.bodyMedium.copyWith(color: colors.onSurface),
        child: builder(widget.value as T),
      );
    } else {
      display = Text(
        widget.placeholder ?? '',
        style: typo.bodyMedium.copyWith(
          color: colors.onSurface.withValues(alpha: 0.5),
        ),
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: theme.animationDuration,
            curve: theme.animationCurve,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: spacing.radiusMd,
              border: Border.all(color: borderColor, width: theme.borderWidth),
              boxShadow: shadows,
            ),
            child: Row(
              children: [
                Expanded(child: display),
                SizedBox(width: spacing.xs),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0.0,
                  duration: theme.animationDuration,
                  child: Text(
                    '\u25BE',
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownOverlay<T> extends StatelessWidget {
  const _DropdownOverlay({
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
        BoxShadow(color: colors.glow!.withValues(alpha: 0.15), blurRadius: 16),
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
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: spacing.radiusMd,
                border: Border.all(color: colors.border, width: theme.borderWidth),
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
