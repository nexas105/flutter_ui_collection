import 'package:flutter/widgets.dart';

import '../../icons/ui_icons.dart';
import '../../interaction/ui_interactive_region.dart';
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
    this.enabled = true,
    this.loading = false,
    this.errorText,
    this.emptyText = 'No options available',
  });

  final T? value;
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final ValueChanged<T> onChanged;
  final String? placeholder;
  final bool enabled;
  final bool loading;
  final String? errorText;
  final String emptyText;

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

  bool get _interactive =>
      widget.enabled && !widget.loading && widget.items.isNotEmpty;

  void _toggle() {
    if (!_interactive) return;
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    if (!_interactive) return;
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

    final borderColor = widget.errorText != null
        ? colors.error
        : _isOpen
        ? colors.primary
        : colors.border;

    List<BoxShadow>? shadows;
    if (_isOpen && theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(color: colors.glow!.withValues(alpha: 0.2), blurRadius: 8),
      ];
    }

    Widget display;
    if (widget.loading) {
      display = Text(
        'Loading…',
        style: typo.bodyMedium.copyWith(
          color: colors.onSurface.withValues(alpha: 0.65),
        ),
      );
    } else if (widget.items.isEmpty) {
      display = Text(
        widget.emptyText,
        style: typo.bodyMedium.copyWith(
          color: colors.onSurface.withValues(alpha: 0.65),
        ),
      );
    } else if (widget.value != null) {
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

    final control = CompositedTransformTarget(
      link: _layerLink,
      child: UiInteractiveRegion(
        enabled: _interactive,
        onActivate: _toggle,
        semanticLabel: widget.placeholder,
        button: true,
        selected: _isOpen,
        borderRadius: theme.components.controlBorderRadius,
        child: GestureDetector(
          onTap: _interactive ? _toggle : null,
          child: AnimatedContainer(
            duration: theme.animationDuration,
            curve: theme.animationCurve,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: theme.components.controlBorderRadius,
              border: Border.all(color: borderColor, width: theme.borderWidth),
              boxShadow: shadows,
            ),
            constraints: BoxConstraints(
              minHeight: theme.components.controlHeightMedium,
            ),
            child: Row(
              children: [
                Expanded(child: display),
                SizedBox(width: spacing.xs),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0.0,
                  duration: theme.animationDuration,
                  child: Icon(
                    theme.icons.resolve(UiIcons.expandMore),
                    color: colors.onSurface.withValues(alpha: 0.5),
                    size: theme.components.iconSizeSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Opacity(
      opacity: widget.enabled ? 1 : theme.components.disabledOpacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          control,
          if (widget.errorText != null) ...[
            SizedBox(height: spacing.xs),
            Text(
              widget.errorText!,
              style: typo.bodySmall.copyWith(color: colors.error),
            ),
          ],
        ],
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
                borderRadius: theme.components.cardBorderRadius,
                border: Border.all(
                  color: colors.border,
                  width: theme.borderWidth,
                ),
                boxShadow: shadows,
              ),
              child: ClipRRect(
                borderRadius: theme.components.cardBorderRadius,
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
