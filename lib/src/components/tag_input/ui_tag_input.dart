import 'package:flutter/widgets.dart';

import '../../icons/ui_icons.dart';
import '../../theme/ui_theme.dart';

/// A chip-based tag input with a text field for adding new tags.
///
/// Shows existing tags as deletable chips in a wrap layout,
/// with an inline text field for entering new tags.
/// Tags are submitted on Enter or comma.
///
/// ```dart
/// UiTagInput(
///   tags: ['Flutter', 'Dart'],
///   onTagAdded: (tag) => setState(() => _tags.add(tag)),
///   onTagRemoved: (tag) => setState(() => _tags.remove(tag)),
/// )
/// ```
class UiTagInput extends StatefulWidget {
  const UiTagInput({
    super.key,
    required this.tags,
    required this.onTagAdded,
    required this.onTagRemoved,
    this.placeholder = 'Add a tag...',
    this.maxTags,
    this.enabled = true,
  });

  final List<String> tags;
  final ValueChanged<String> onTagAdded;
  final ValueChanged<String> onTagRemoved;
  final String placeholder;
  final int? maxTags;
  final bool enabled;

  @override
  State<UiTagInput> createState() => _UiTagInputState();
}

class _UiTagInputState extends State<UiTagInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() => _focused = _focusNode.hasFocus);
  }

  bool get _canAddMore =>
      widget.maxTags == null || widget.tags.length < widget.maxTags!;

  void _submitTag(String raw) {
    final tag = raw.replaceAll(',', '').trim();
    if (tag.isEmpty) return;
    if (!_canAddMore) return;
    if (widget.tags.contains(tag)) return;
    widget.onTagAdded(tag);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final borderColor = _focused ? colors.primary : colors.border;

    List<BoxShadow>? shadows;
    if (_focused && widget.enabled && theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(color: colors.glow!.withValues(alpha: 0.3), blurRadius: 12),
      ];
    }

    final bgLuminance = colors.background.computeLuminance();
    final keyboardBrightness = bgLuminance > 0.5
        ? Brightness.light
        : Brightness.dark;

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
        child: AnimatedContainer(
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
            vertical: spacing.xs,
          ),
          child: Wrap(
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tag in widget.tags)
                _TagChip(
                  label: tag,
                  onDelete: widget.enabled
                      ? () => widget.onTagRemoved(tag)
                      : null,
                ),
              if (_canAddMore && widget.enabled)
                SizedBox(
                  width: 120,
                  child: Stack(
                    children: [
                      if (_controller.text.isEmpty)
                        IgnorePointer(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: spacing.xs),
                            child: Text(
                              widget.placeholder,
                              style: typo.bodyMedium.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.35),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      EditableText(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: typo.bodyMedium.copyWith(
                          color: colors.onSurface,
                        ),
                        cursorColor: colors.primary,
                        backgroundCursorColor: colors.surface,
                        keyboardAppearance: keyboardBrightness,
                        onChanged: (value) {
                          if (value.contains(',')) {
                            _submitTag(value);
                          }
                          setState(() {});
                        },
                        onSubmitted: (value) {
                          _submitTag(value);
                          _focusNode.requestFocus();
                        },
                        selectionColor: colors.primary.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, this.onDelete});

  final String label;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return AnimatedContainer(
      duration: theme.animationDuration,
      curve: theme.animationCurve,
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.15),
        borderRadius: spacing.radiusFull,
        border: Border.all(color: colors.primary, width: theme.borderWidth),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: typo.labelSmall.copyWith(color: colors.primary)),
          if (onDelete != null) ...[
            SizedBox(width: spacing.xs),
            GestureDetector(
              onTap: onDelete,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Icon(
                  UiIcons.close,
                  size: 12,
                  color: colors.primary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
