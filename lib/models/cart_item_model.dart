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
    // The API response may have product info nested under 'productId' or 'product'.
    final productJson = json['productId'] is Map<String, dynamic>
        ? json['productId']
        : (json['product'] is Map<String, dynamic>
        ? json['product']
        : <String, dynamic>{});

    // Ensure the product has an ID - extract from the nested product or use the reference ID
    if (productJson is Map<String, dynamic>) {
      if (!productJson.containsKey('_id') && !productJson.containsKey('id')) {
        // If the nested product doesn't have an ID, use the productId reference
        if (json['productId'] is String) {
          productJson['_id'] = json['productId'];
        }
      }
      // Always set productId field for ProductModel
      if (json['productId'] is String) {
        productJson['productId'] = json['productId'];
      } else if (productJson['_id'] != null) {
        productJson['productId'] = productJson['_id'];
      }
    }

    return CartItem(
      cartItemId: json['_id'],
      product: ProductModel.fromJson(productJson),
      quantity: json['quantity'] ?? 1,
      selectedSize: json['selectedSize'],
      selectedColor: json['selectedColor'],
    );
  }

  // Get the product ID for API operations
  String? get productId {
  return product.productId ?? cartItemId;
  }

  double get totalPrice {
    final price = product.priceAfetDiscount ?? product.price;
    return price * quantity;
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