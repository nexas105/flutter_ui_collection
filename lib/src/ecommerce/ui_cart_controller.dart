import 'package:flutter/widgets.dart';

import 'ui_ecommerce_models.dart';

/// A reactive shopping cart controller that manages cart state.
///
/// Extends [ChangeNotifier] so widgets can rebuild when the cart changes.
///
/// ```dart
/// final cart = UiCartController();
/// cart.addItem(product);
/// print(cart.total); // subtotal + shipping + tax
/// ```
class UiCartController extends ChangeNotifier {
  final List<UiCartItem> _items = [];

  /// All items currently in the cart.
  List<UiCartItem> get items => List.unmodifiable(_items);

  /// Total number of individual items (sum of quantities).
  int get itemCount =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Whether the cart has no items.
  bool get isEmpty => _items.isEmpty;

  /// Sum of (effectivePrice * quantity) for every item.
  double get subtotal => _items.fold<double>(
        0,
        (sum, item) =>
            sum +
            (item.product.salePrice ?? item.product.price) * item.quantity,
      );

  /// Flat shipping cost. Set to update the total.
  double get shipping => _shipping;
  double _shipping = 0.0;
  set shipping(double value) {
    if (_shipping != value) {
      _shipping = value;
      notifyListeners();
    }
  }

  /// Tax rate as a decimal (e.g. 0.08 for 8 %).
  double taxRate = 0.0;

  /// Computed tax amount: subtotal * taxRate.
  double get tax => subtotal * taxRate;

  /// Grand total: subtotal + shipping + tax.
  double get total => subtotal + _shipping + tax;

  /// Currency symbol used for display purposes.
  String currency = '\$';

  /// Adds [product] to the cart. If it already exists, increments quantity.
  void addItem(UiProduct product, {int quantity = 1}) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      final existing = _items[index];
      _items[index] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      _items.add(UiCartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  /// Removes the item with the given [productId] entirely.
  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  /// Sets the quantity for [productId]. Removes the item when [qty] <= 0.
  void updateQuantity(String productId, int qty) {
    if (qty <= 0) {
      removeItem(productId);
      return;
    }
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: qty);
      notifyListeners();
    }
  }

  /// Removes every item from the cart.
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
