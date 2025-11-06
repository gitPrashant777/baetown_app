// lib/services/cart_service.dart
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import 'cart_wishlist_api_service.dart';

class CartService extends ChangeNotifier {
  final CartApiService _cartApi;
  CartService(this._cartApi);

  List<CartItem> _items = [];
  bool _isLoading = true; // Start as true until first fetch is done

  // --- PUBLIC GETTERS ---
  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  // --- HELPER to update the list ---
  void _updateLocalCart(Map<String, dynamic>? cartData) {
    if (cartData != null && cartData['cart'] is List) {
      final rawCart = cartData['cart'] as List;
      _items = rawCart.map((item) => CartItem.fromJson(item)).toList();
      print("🛒 CartService: Loaded ${_items.length} items from API");
    } else {
      print("🛒 CartService: Cart is empty or API response was invalid.");
      _items = [];
    }
  }

  // --- 1. LOAD: Called from main.dart and after all updates ---
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners(); // Tell UI "we are loading"

    try {
      final cartData = await _cartApi.getCart();
      _updateLocalCart(cartData);
    } catch (e) {
      print("❌ Error fetching cart: $e");
      _items = []; // Clear list on error
    } finally {
      _isLoading = false;
      notifyListeners(); // Tell UI "we are done loading" with new data
    }
  }

  // --- 2. ADD: Adds an item ---
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

      // API returns the entire new cart. We just parse it.
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
      notifyListeners(); // Tell UI we are done
    }
  }

  // --- 3. REMOVE: Removes an item (Reliable Method) ---
  Future<bool> removeFromCart({required String cartItemId, required String productId}) async {
    if (cartItemId.isEmpty || productId.isEmpty) {
      print("❌ CartService Error: cartItemId or productId is empty");
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Call the API with the PRODUCT ID
      final success = await _cartApi.removeFromCart(productId);

      if (success) {
        // If success, fetch the fresh cart list from the server
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

  // --- 4. UPDATE: Updates quantity (Reliable Method) ---
  Future<bool> updateQuantity({required String cartItemId, required String productId, required int newQuantity}) async {
    if (cartItemId.isEmpty || productId.isEmpty) {
      print("❌ CartService Error: cartItemId or productId is empty");
      return false;
    }

    if (newQuantity <= 0) {
      // Quantity 0 means remove.
      return await removeFromCart(cartItemId: cartItemId, productId: productId);
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Call the API with the PRODUCT ID
      final success = await _cartApi.updateCartItem(
        productId: productId,
        quantity: newQuantity,
      );

      if (success) {
        // If success, fetch the fresh cart list
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

    // 1. Show global loading spinner
    _isLoading = true;
    notifyListeners();

    // 2. Get a copy of the list of items to remove
    final itemsToRemove = List<CartItem>.from(_items);

    // 3. If there's nothing to remove, stop here.
    if (itemsToRemove.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return true;
    }

    print("🛒 Found ${itemsToRemove.length} items to clear.");

    try {
      // 4. Loop through the copied list and remove each item
      //    using the (now working) removeFromCart method.
      for (final item in itemsToRemove) {
        if (item.product.productId != null) {
          print("... removing ${item.product.title}");
          // We call the API directly. We don't need to await
          // or handle success for each one, just send all requests.
          await _cartApi.removeFromCart(item.product.productId!);
        }
      }

      // 5. After all delete requests are sent, fetch the cart *once*.
      //    The server should now return an empty cart.
      print("✅ All clear requests sent. Fetching new cart state...");
      await fetchCart(); // This will set isLoading = false and update UI
      return true;

    } catch (e) {
      print("❌ Error during batch clear cart: $e");
      // If something fails, still fetch the cart to be safe.
      await fetchCart();
      return false;
    }
  }

  // --- LOCAL-ONLY METHODS (These are fine) ---
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