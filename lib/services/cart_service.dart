// lib/services/cart_service.dart
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import 'cart_wishlist_api_service.dart';

class CartService extends ChangeNotifier {
  final CartApiService _cartApi;
  CartService(this._cartApi);

  List<CartItem> _items = [];
  bool _isLoading = true;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);
// In lib/services/cart_service.dart

  // Helper to update the list
  void _updateLocalCart(Map<String, dynamic>? cartData) {
    if (cartData == null) {
      print("🛒 CartService: Received null cart data.");
      _items = [];
      return;
    }

    // --- THIS IS THE FIX ---
    // Check for common keys. Your API might be using 'cartItems' or 'items'.
    List<dynamic>? rawCart;
    if (cartData['cart'] is List) {
      rawCart = cartData['cart'] as List;
    } else if (cartData['cartItems'] is List) {
      rawCart = cartData['cartItems'] as List;
    } else if (cartData['items'] is List) {
      rawCart = cartData['items'] as List;
    }
    // --- END OF FIX ---

    if (rawCart != null) {
      _items = rawCart.map((item) => CartItem.fromJson(item)).toList();
      print("🛒 CartService: Loaded ${_items.length} items from API");
    } else {
      print("🛒 CartService: Cart is empty or API response was invalid (checked 'cart', 'cartItems', 'items').");
      _items = [];
    }
  }

  // Load: Called from main.dart and after all updates
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cartData = await _cartApi.getCart();
      _updateLocalCart(cartData);
    } catch (e) {
      print("❌ Error fetching cart: $e");
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add: Adds an item
  Future<bool> addToCart(ProductModel product, {String? size, String? color, int quantity = 1}) async {
    if (product.productId == null) {
      print("❌ CartService Error: Product ID is null");
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final newCartData = await _cartApi.addToCart(
        productId: product.productId!,
        quantity: quantity,
        size: size,
        color: color,
      );

      if (newCartData != null) {
        _updateLocalCart(newCartData);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error adding to cart: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> removeFromCart({required String cartItemId, required String productId}) async {
    if (cartItemId.isEmpty || productId.isEmpty) {
      print("❌ CartService Error: cartItemId or productId is empty");
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 2. Call the API with the PRODUCT ID
      final success = await _cartApi.removeFromCart(productId);

      if (success) {
        // 3. If success, fetch the fresh cart list from the server
        await fetchCart();
      } else {
        _isLoading = false;
        notifyListeners();
      }
      return success;
    } catch (e) {
      print("❌ Error removing from cart: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQuantity({required String cartItemId, required String productId, required int newQuantity}) async {
    if (cartItemId.isEmpty || productId.isEmpty) {
      print("❌ CartService Error: cartItemId or productId is empty");
      return false;
    }

    if (newQuantity <= 0) {
      return await removeFromCart(cartItemId: cartItemId, productId: productId);
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 2. Call the API with the PRODUCT ID
      final success = await _cartApi.updateCartItem(
        productId: productId, // <-- Send productId
        quantity: newQuantity,
      );

      if (success) {
        // 3. If success, fetch the fresh cart list
        await fetchCart();
      } else {
        _isLoading = false;
        notifyListeners();
      }
      return success;
    } catch (e) {
      print("❌ Error updating quantity: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- 5. CLEAR: (NEW "DELETE ALL" METHOD) ---
  Future<bool> clearCart() async {
    print("🛒 CartService: Clearing entire cart (one-by-one)...");

    _isLoading = true;
    notifyListeners();

    final itemsToRemove = List<CartItem>.from(_items);

    if (itemsToRemove.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return true;
    }

    print("🛒 Found ${itemsToRemove.length} items to clear.");

    try {
      for (final item in itemsToRemove) {
        if (item.product.productId != null) {
          print("... removing ${item.product.title}");
          await _cartApi.removeFromCart(item.product.productId!);
        }
      }

      print("✅ All clear requests sent. Fetching new cart state...");
      await fetchCart();
      return true;

    } catch (e) {
      print("❌ Error during batch clear cart: $e");
      await fetchCart();
      return false;
    }
  }

  // ... (local helper methods are fine) ...
  bool isInCart(String? productId) {
    if (productId == null) return false;
    return _items.any((item) => item.product.productId == productId);
  }

  int getProductQuantityInCart(String? productId) {
    if (productId == null) return 0;
    try {
      final item = _items.firstWhere((item) => item.product.productId == productId);
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }
}