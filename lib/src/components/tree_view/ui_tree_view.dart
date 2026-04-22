import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// A node in the tree hierarchy.
class UiTreeNode {
  const UiTreeNode({
    required this.label,
    this.children = const [],
    this.icon,
    this.expanded = false,
  });

  final String label;
  final List<UiTreeNode> children;
  final Widget? icon;
  final bool expanded;

  bool get isExpandable => children.isNotEmpty;
}

/// A themed hierarchical tree view.
///
/// ```dart
/// UiTreeView(
///   nodes: [
///     UiTreeNode(label: 'Root', children: [
///       UiTreeNode(label: 'Child 1'),
///       UiTreeNode(label: 'Child 2'),
///     ]),
///   ],
/// )
/// ```
class UiTreeView extends StatefulWidget {
  const UiTreeView({
    super.key,
    required this.nodes,
    this.onNodeTap,
    this.indent = 24.0,
  });

  final List<UiTreeNode> nodes;
  final void Function(UiTreeNode node)? onNodeTap;
  final double indent;

  @override
  State<UiTreeView> createState() => _UiTreeViewState();
}

class _UiTreeViewState extends State<UiTreeView> {
  final Set<String> _expandedKeys = {};
  String? _activeKey;

  String _keyForNode(UiTreeNode node, int depth, int index) {
    return '$depth-$index-${node.label}';
  }

  @override
  void initState() {
    super.initState();
    _initExpanded(widget.nodes, 0);
  }

  void _initExpanded(List<UiTreeNode> nodes, int depth) {
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].expanded && nodes[i].isExpandable) {
        _expandedKeys.add(_keyForNode(nodes[i], depth, i));
      }
      _initExpanded(nodes[i].children, depth + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _buildNodes(widget.nodes, 0, theme),
    );
  }

  List<Widget> _buildNodes(
      List<UiTreeNode> nodes, int depth, UiThemeData theme) {
    final List<Widget> widgets = [];
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final key = _keyForNode(node, depth, i);
      final isExpanded = _expandedKeys.contains(key);
      final isActive = _activeKey == key;

      widgets.add(
        _TreeNodeTile(
          node: node,
          depth: depth,
          indent: widget.indent,
          isExpanded: isExpanded,
          isActive: isActive,
          theme: theme,
          onTap: () {
            setState(() {
              _activeKey = key;
              if (node.isExpandable) {
                if (isExpanded) {
                  _expandedKeys.remove(key);
                } else {
                  _expandedKeys.add(key);
                }
              }
            });
            widget.onNodeTap?.call(node);
          },
        ),
      );

      if (isExpanded && node.isExpandable) {
        widgets.addAll(_buildNodes(node.children, depth + 1, theme));
      }
    }
    return widgets;
  }
}

class _TreeNodeTile extends StatelessWidget {
  const _TreeNodeTile({
    required this.node,
    required this.depth,
    required this.indent,
    required this.isExpanded,
    required this.isActive,
    required this.theme,
    required this.onTap,
  });

  final UiTreeNode node;
  final int depth;
  final double indent;
  final bool isExpanded;
  final bool isActive;
  final UiThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final List<BoxShadow>? glow =
        isActive && theme.useGlow && colors.glow != null
            ? [
                BoxShadow(
                  color: colors.glow!.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.xs,
          ),
          margin: EdgeInsets.only(left: depth * indent),
          decoration: BoxDecoration(
            color: isActive
                ? colors.primary.withValues(alpha: 0.12)
                : const Color(0x00000000),
            borderRadius: spacing.radiusSm,
            boxShadow: glow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (node.isExpandable)
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0.0,
                  duration: theme.animationDuration,
                  child: Text(
                    '\u25B6',
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                )
              else
                const SizedBox(width: 10),
              SizedBox(width: spacing.xs),
              if (node.icon != null) ...[
                node.icon!,
                SizedBox(width: spacing.xs),
              ],
              Flexible(
                child: Text(
                  node.label,
                  style: typo.bodyMedium.copyWith(
                    color: isActive ? colors.primary : colors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
