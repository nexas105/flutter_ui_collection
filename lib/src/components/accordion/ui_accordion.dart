import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// A single accordion section.
class UiAccordionSection {
  const UiAccordionSection({
    required this.title,
    required this.content,
    this.leading,
  });

  final String title;
  final Widget content;
  final Widget? leading;
}

/// A themed expandable accordion / collapsible sections.
///
/// ```dart
/// UiAccordion(
///   sections: [
///     UiAccordionSection(title: 'FAQ 1', content: Text('Answer 1')),
///     UiAccordionSection(title: 'FAQ 2', content: Text('Answer 2')),
///   ],
/// )
/// ```
class UiAccordion extends StatefulWidget {
  const UiAccordion({
    super.key,
    required this.sections,
    this.allowMultiple = false,
    this.initiallyExpanded = const {},
  });

  final List<UiAccordionSection> sections;

  /// Allow multiple sections to be open simultaneously.
  final bool allowMultiple;

  /// Indices of initially expanded sections.
  final Set<int> initiallyExpanded;

  @override
  State<UiAccordion> createState() => _UiAccordionState();
}

class _UiAccordionState extends State<UiAccordion> {
  late Set<int> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = Set.of(widget.initiallyExpanded);
  }

  void _toggle(int index) {
    setState(() {
      if (_expanded.contains(index)) {
        _expanded.remove(index);
      } else {
        if (!widget.allowMultiple) _expanded.clear();
        _expanded.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < widget.sections.length; i++) ...[
          if (i > 0)
            Container(height: theme.borderWidth, color: colors.border),
          _AccordionItem(
            section: widget.sections[i],
            expanded: _expanded.contains(i),
            onTap: () => _toggle(i),
            theme: theme,
          ),
        ],
      ],
    );
  }
}

class _AccordionItem extends StatelessWidget {
  const _AccordionItem({
    required this.section,
    required this.expanded,
    required this.onTap,
    required this.theme,
  });

  final UiAccordionSection section;
  final bool expanded;
  final VoidCallback onTap;
  final UiThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        GestureDetector(
          onTap: onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm + 2,
              ),
              color: const Color(0x00000000),
              child: Row(
                children: [
                  if (section.leading != null) ...[
                    section.leading!,
                    SizedBox(width: spacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      section.title,
                      style: typo.titleSmall.copyWith(color: colors.onSurface),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0,
                    duration: theme.animationDuration,
                    child: Text(
                      '\u25BE',
                      style: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Content
        ClipRect(
          child: AnimatedAlign(
            duration: theme.animationDuration,
            curve: theme.animationCurve,
            alignment: Alignment.topCenter,
            heightFactor: expanded ? 1.0 : 0.0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(spacing.md, 0, spacing.md, spacing.md),
              child: DefaultTextStyle(
                style: typo.bodyMedium.copyWith(color: colors.onSurface),
                child: section.content,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
