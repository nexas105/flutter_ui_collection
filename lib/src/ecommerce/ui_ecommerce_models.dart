// Data models for the e-commerce module.

/// Status stages for an order.
enum UiOrderStatus { pending, confirmed, shipped, delivered, cancelled }

/// Represents a product in the catalog.
class UiProduct {
  const UiProduct({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    this.salePrice,
    this.images = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    this.badges = const [],
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final double? salePrice;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final List<String> badges;

  UiProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? salePrice,
    List<String>? images,
    double? rating,
    int? reviewCount,
    bool? inStock,
    List<String>? badges,
  }) {
    return UiProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      inStock: inStock ?? this.inStock,
      badges: badges ?? this.badges,
    );
  }
}

/// Represents a product with a quantity in the shopping cart.
class UiCartItem {
  const UiCartItem({
    required this.product,
    this.quantity = 1,
  });

  final UiProduct product;
  final int quantity;

  UiCartItem copyWith({
    UiProduct? product,
    int? quantity,
  }) {
    return UiCartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
