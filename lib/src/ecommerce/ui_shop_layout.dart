import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_cart_badge.dart';
import 'ui_ecommerce_models.dart';
import 'ui_product_grid.dart';

/// A complete shop page layout with search, category chips, product grid,
/// and a cart badge.
///
/// ```dart
/// UiShopLayout(
///   products: allProducts,
///   categories: ['All', 'Shoes', 'Shirts'],
///   selectedCategory: 'All',
///   onCategoryChanged: (cat) => filter(cat),
///   onProductTap: (p) => goToDetail(p),
/// )
/// ```
class UiShopLayout extends StatelessWidget {
  const UiShopLayout({
    super.key,
    required this.products,
    this.categories = const [],
    this.selectedCategory,
    this.onCategoryChanged,
    this.onProductTap,
    this.onAddToCart,
    this.cartItemCount = 0,
    this.onCartTap,
    this.onSearch,
  });

  /// Products to display in the grid.
  final List<UiProduct> products;

  /// Category filter labels.
  final List<String> categories;

  /// Currently selected category.
  final String? selectedCategory;

  /// Called when a category chip is tapped.
  final ValueChanged<String>? onCategoryChanged;

  /// Called when a product card is tapped.
  final void Function(UiProduct product)? onProductTap;

  /// Called when the add-to-cart button on a card is tapped.
  final void Function(UiProduct product)? onAddToCart;

  /// Number shown on the cart badge.
  final int cartItemCount;

  /// Called when the cart icon is tapped.
  final VoidCallback? onCartTap;

  /// Called when a search query is submitted.
  final ValueChanged<String>? onSearch;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final spacing = theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top bar: search + cart badge
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: _SearchBar(onSearch: onSearch, theme: theme),
              ),
              SizedBox(width: spacing.md),
              UiCartBadge(
                count: cartItemCount,
                onTap: onCartTap,
              ),
            ],
          ),
        ),

        // Category chips
        if (categories.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: spacing.md),
              children: [
                for (final cat in categories)
                  Padding(
                    padding: EdgeInsets.only(right: spacing.sm),
                    child: _CategoryChip(
                      label: cat,
                      selected: cat == selectedCategory,
                      onTap: onCategoryChanged != null
                          ? () => onCategoryChanged!(cat)
                          : null,
                      theme: theme,
                    ),
                  ),
              ],
            ),
          ),
        SizedBox(height: spacing.sm),

        // Product grid
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: spacing.md),
            child: UiProductGrid(
              products: products,
              onProductTap: onProductTap,
              onAddToCart: onAddToCart,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({
    required this.onSearch,
    required this.theme,
  });

  final ValueChanged<String>? onSearch;
  final dynamic theme;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: spacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: spacing.radiusMd,
        border: Border.all(color: colors.border, width: theme.borderWidth),
      ),
      child: Row(
        children: [
          Icon(
            const IconData(0xe567, fontFamily: 'MaterialIcons'), // search
            size: 18,
            color: (colors.onSurface as Color).withValues(alpha: 0.5),
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                if (_text.isEmpty)
                  Text(
                    'Search products...',
                    style: (typo.bodyMedium as TextStyle).copyWith(
                      color: (colors.onSurface as Color)
                          .withValues(alpha: 0.4),
                    ),
                  ),
                EditableText(
                  controller: _textController,
                  focusNode: _focusNode,
                  style: (typo.bodyMedium as TextStyle).copyWith(
                    color: colors.onSurface,
                  ),
                  cursorColor: colors.primary,
                  backgroundCursorColor: colors.border,
                  onChanged: (value) {
                    setState(() => _text = value);
                  },
                  onSubmitted: widget.onSearch,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    this.onTap,
    required this.theme,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final dynamic theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor:
            onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.surface,
            borderRadius: spacing.radiusFull,
            border: Border.all(
              color: selected ? colors.primary : colors.border,
              width: theme.borderWidth,
            ),
          ),
          child: Text(
            label,
            style: (typo.labelMedium as TextStyle).copyWith(
              color: selected ? colors.onPrimary : colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
