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
    print("🛒 Parsing cart item: ${json['_id']}");

    // FIXED: Handle the API response format where productId is a full product object
    Map<String, dynamic> productJson;

    if (json['productId'] is Map<String, dynamic>) {
      // Format: productId is an object with full product data
      // --- THIS PART IS ALREADY CORRECT ---
      productJson = Map<String, dynamic>.from(json['productId']);

      // FIXED: Ensure productId field is set correctly
      if (productJson.containsKey('_id')) {
        productJson['productId'] = productJson['_id'];
      }

      // FIXED: Handle empty images array - provide fallback
      if (productJson['images'] is List && (productJson['images'] as List).isEmpty) {
        productJson['images'] = ['https://via.placeholder.com/300?text=No+Image'];
      }
    } else {
      // --- THIS IS THE FIX ---
      // Fallback for other formats (e.g., 'productId' is just a string)
      // We must build a productJson from the fields available at the top level.
      productJson = {
        // CRITICAL FIX: Use the 'productId' field from the json.
        // Do NOT use json['_id'] (which is the cart item's ID).
        'productId': json['productId']?.toString(), // <-- THE FIX

        'title': json['name'] ?? json['title'] ?? 'Product',
        'description': json['description'] ?? '',
        'category': json['category'] ?? '',
        'price': (json['price'] ?? 0).toDouble(),
        'stockQuantity': json['stock'] ?? json['stockQuantity'] ?? 0,
        'maxOrderQuantity': json['maxOrderQuantity'] ?? 5,
        'isOutOfStock': json['isOutOfStock'] ?? false,
        'image': json['image'] ?? '',
        'images': json['images'] ?? ['https://via.placeholder.com/300?text=No+Image'],
      };
      // --- END OF FIX ---
    }

    // Ensure we have a valid product ID
    if (productJson['productId'] == null) {
      print("❌ WARNING: Cart item has no product ID: $json");
    }

    return CartItem(
      cartItemId: json['_id']?.toString(), // This is the CartItem's own ID
      product: ProductModel.fromJson(productJson), // This creates the product
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