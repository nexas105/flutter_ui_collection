import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Adds consistent focus, keyboard activation, cursor and semantics behavior
/// to custom controls without depending on Material or Cupertino widgets.
class UiInteractiveRegion extends StatefulWidget {
  const UiInteractiveRegion({
    super.key,
    required this.child,
    required this.enabled,
    this.onActivate,
    this.semanticLabel,
    this.button = false,
    this.checked,
    this.selected,
    this.borderRadius,
    this.focusNode,
    this.autofocus = false,
    this.focusable,
    this.slider = false,
    this.value,
    this.increasedValue,
    this.decreasedValue,
    this.onIncrease,
    this.onDecrease,
  });

  final Widget child;
  final bool enabled;
  final VoidCallback? onActivate;
  final String? semanticLabel;
  final bool button;
  final bool? checked;
  final bool? selected;
  final BorderRadius? borderRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool? focusable;
  final bool slider;
  final String? value;
  final String? increasedValue;
  final String? decreasedValue;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  @override
  State<UiInteractiveRegion> createState() => _UiInteractiveRegionState();
}

class _UiInteractiveRegionState extends State<UiInteractiveRegion> {
  bool _focused = false;

  bool get _interactive =>
      widget.enabled &&
      (widget.onActivate != null ||
          widget.onIncrease != null ||
          widget.onDecrease != null);

  bool get _focusable => widget.focusable ?? _interactive;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final radius = widget.borderRadius ?? theme.components.controlBorderRadius;

    final content = Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (_focused)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: theme.components.focusRingWidth,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      button: widget.button,
      enabled: widget.enabled,
      focusable: widget.enabled && _focusable,
      focused: _focused,
      checked: widget.checked,
      selected: widget.selected,
      slider: widget.slider,
      value: widget.value,
      increasedValue: widget.increasedValue,
      decreasedValue: widget.decreasedValue,
      onIncrease: widget.enabled ? widget.onIncrease : null,
      onDecrease: widget.enabled ? widget.onDecrease : null,
      onTap: _interactive ? widget.onActivate : null,
      child: Shortcuts(
        shortcuts: {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          if (widget.onIncrease != null)
            const SingleActivator(LogicalKeyboardKey.arrowRight):
                const _IncreaseIntent(),
          if (widget.onIncrease != null)
            const SingleActivator(LogicalKeyboardKey.arrowUp):
                const _IncreaseIntent(),
          if (widget.onDecrease != null)
            const SingleActivator(LogicalKeyboardKey.arrowLeft):
                const _DecreaseIntent(),
          if (widget.onDecrease != null)
            const SingleActivator(LogicalKeyboardKey.arrowDown):
                const _DecreaseIntent(),
        },
        child: Actions(
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                if (_interactive) widget.onActivate!();
                return null;
              },
            ),
            _IncreaseIntent: CallbackAction<_IncreaseIntent>(
              onInvoke: (_) {
                if (widget.enabled) widget.onIncrease?.call();
                return null;
              },
            ),
            _DecreaseIntent: CallbackAction<_DecreaseIntent>(
              onInvoke: (_) {
                if (widget.enabled) widget.onDecrease?.call();
                return null;
              },
            ),
          },
          child: FocusableActionDetector(
            enabled: widget.enabled && _focusable,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            mouseCursor: _interactive
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden,
            onShowFocusHighlight: (value) {
              if (mounted) setState(() => _focused = value);
            },
            child: content,
          ),
        ),
      ),
    );
  }
}

class _IncreaseIntent extends Intent {
  const _IncreaseIntent();
}

class _DecreaseIntent extends Intent {
  const _DecreaseIntent();
}
