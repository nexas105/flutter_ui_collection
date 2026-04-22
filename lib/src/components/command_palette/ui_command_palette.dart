import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A single command entry for [UiCommandPalette].
class UiCommand {
  const UiCommand({
    required this.label,
    this.icon,
    this.description,
    required this.onSelect,
  });

  final String label;
  final Widget? icon;
  final String? description;
  final VoidCallback onSelect;
}

/// A themed command palette (Cmd+K style).
///
/// Use the static [show] method to display it:
/// ```dart
/// UiCommandPalette.show(
///   context: context,
///   commands: [
///     UiCommand(label: 'Open file', onSelect: () {}),
///   ],
/// );
/// ```
class UiCommandPalette extends StatefulWidget {
  const UiCommandPalette._({
    required this.commands,
  });

  final List<UiCommand> commands;

  /// Shows the command palette as a full-screen overlay.
  static void show({
    required BuildContext context,
    required List<UiCommand> commands,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: UiCommandPalette._(commands: commands),
          );
        },
      ),
    );
  }

  @override
  State<UiCommandPalette> createState() => _UiCommandPaletteState();
}

class _UiCommandPaletteState extends State<UiCommandPalette> {
  String _query = '';

  List<UiCommand> get _filtered {
    if (_query.isEmpty) return widget.commands;
    final lower = _query.toLowerCase();
    return widget.commands.where((cmd) {
      return cmd.label.toLowerCase().contains(lower) ||
          (cmd.description?.toLowerCase().contains(lower) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final List<BoxShadow> shadows = [];
    if (theme.useGlow && colors.glow != null) {
      shadows.add(BoxShadow(
        color: colors.glow!.withValues(alpha: 0.25),
        blurRadius: 24,
        spreadRadius: 2,
      ));
    } else if (theme.useShadows) {
      shadows.add(BoxShadow(
        color: colors.shadow,
        blurRadius: 24,
        offset: const Offset(0, 8),
      ));
    }

    final filtered = _filtered;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: colors.background.withValues(alpha: 0.6),
        alignment: const Alignment(0, -0.3),
        child: GestureDetector(
          onTap: () {}, // absorb taps on the palette itself
          child: Container(
            width: 520,
            constraints: const BoxConstraints(maxHeight: 420),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: spacing.radiusLg,
              border: Border.all(color: colors.border, width: theme.borderWidth),
              boxShadow: shadows,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search field
                Container(
                  padding: EdgeInsets.all(spacing.md),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colors.border,
                        width: theme.borderWidth,
                      ),
                    ),
                  ),
                  child: EditableText(
                    controller: TextEditingController(),
                    focusNode: FocusNode()..requestFocus(),
                    style: typo.bodyLarge.copyWith(color: colors.onSurface),
                    cursorColor: colors.primary,
                    backgroundCursorColor: colors.surface,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                // Results
                if (filtered.isEmpty)
                  Padding(
                    padding: spacing.paddingMd,
                    child: Text(
                      'No commands found',
                      style: typo.bodyMedium.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: spacing.xs),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final cmd = filtered[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            cmd.onSelect();
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.md,
                                vertical: spacing.sm,
                              ),
                              color: const Color(0x00000000),
                              child: Row(
                                children: [
                                  if (cmd.icon != null) ...[
                                    cmd.icon!,
                                    SizedBox(width: spacing.sm),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          cmd.label,
                                          style: typo.bodyMedium.copyWith(
                                            color: colors.onSurface,
                                          ),
                                        ),
                                        if (cmd.description != null)
                                          Text(
                                            cmd.description!,
                                            style: typo.bodySmall.copyWith(
                                              color: colors.onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
