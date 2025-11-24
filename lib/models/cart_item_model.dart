// lib/models/cart_item_model.dart
import 'product_model.dart';

class CartItem {
  final String? cartItemId;
  final ProductModel product;
  int quantity;
  final String? selectedSize;
  final String? selectedColor;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedSize,
    this.selectedColor,
    this.cartItemId,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // print("🛒 Parsing cart item: ${json['_id']}");

    Map<String, dynamic> productJson;

    if (json['productId'] is Map<String, dynamic>) {
      // 1. Product is a full Object
      productJson = Map<String, dynamic>.from(json['productId']);
      if (productJson.containsKey('_id')) {
        productJson['productId'] = productJson['_id'];
      }
      if (productJson['images'] is List && (productJson['images'] as List).isEmpty) {
        productJson['images'] = ['https://via.placeholder.com/300?text=No+Image'];
      }
    } else {
      // 2. Product is just an ID or flat structure (Fallback)
      // --- FIX STARTS HERE ---
      double price = double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;
      double? salePrice = json['salePrice'] != null
          ? double.tryParse(json['salePrice'].toString())
          : null;

      productJson = {
        'productId': json['productId']?.toString(),
        'title': json['name'] ?? json['title'] ?? 'Product',
        'description': json['description'] ?? '',
        'category': json['category'] ?? '',
        'price': price,
        // IMPORTANT: Map salePrice/discountPrice so totalPrice calculation works
        'priceAfetDiscount': salePrice ?? json['priceAfetDiscount'],
        'stockQuantity': json['stock'] ?? json['stockQuantity'] ?? 0,
        'maxOrderQuantity': json['maxOrderQuantity'] ?? 5,
        'isOutOfStock': json['isOutOfStock'] ?? false,
        'image': json['image'] ?? '',
        'images': json['images'] ?? ['https://via.placeholder.com/300?text=No+Image'],
      };
      // --- FIX ENDS HERE ---
    }

    return CartItem(
      cartItemId: json['_id']?.toString(),
      product: ProductModel.fromJson(productJson),
      quantity: json['quantity'] ?? 1,
      selectedSize: json['selectedSize'],
      selectedColor: json['selectedColor'],
    );
  }

  String? get productId {
    return product.productId ?? cartItemId;
  }

  // Ensure this calculation uses the correct price
  double get totalPrice {
    // If priceAfetDiscount is 0 or null, use the regular price
    final double effectivePrice = (product.priceAfetDiscount != null && product.priceAfetDiscount! > 0)
        ? product.priceAfetDiscount!
        : product.price;

    return effectivePrice * quantity;
  }

  CartItem copyWith({
    ProductModel? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
  }) {
    return CartItem(
      cartItemId: cartItemId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }
}