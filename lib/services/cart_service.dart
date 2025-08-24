import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addToCart(ProductModel product, {String? size, String? color, int quantity = 1}) {
    // Check if product already exists in cart
    final existingIndex = _items.indexWhere((item) => 
        item.product.productId == product.productId &&
        item.selectedSize == size &&
        item.selectedColor == color);

    if (existingIndex >= 0) {
      // Update quantity if product already exists
      final newQuantity = _items[existingIndex].quantity + quantity;
      final maxAllowed = product.getMaxAllowedQuantity();
      
      if (newQuantity <= maxAllowed) {
        _items[existingIndex].quantity = newQuantity;
      } else {
        _items[existingIndex].quantity = maxAllowed;
      }
    } else {
      // Add new item to cart
      final maxAllowed = product.getMaxAllowedQuantity();
      final finalQuantity = quantity > maxAllowed ? maxAllowed : quantity;
      
      if (finalQuantity > 0) {
        _items.add(CartItem(
          product: product,
          quantity: finalQuantity,
          selectedSize: size,
          selectedColor: color,
        ));
      }
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _items.length) {
      final maxAllowed = _items[index].product.getMaxAllowedQuantity();
      if (newQuantity <= 0) {
        removeFromCart(index);
      } else if (newQuantity <= maxAllowed) {
        _items[index].quantity = newQuantity;
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String? productId) {
    return _items.any((item) => item.product.productId == productId);
  }

  int getProductQuantityInCart(String? productId) {
    final item = _items.firstWhere(
      (item) => item.product.productId == productId,
      orElse: () => CartItem(product: ProductModel(image: '', brandName: '', title: '', price: 0)),
    );
    return item.product.productId == productId ? item.quantity : 0;
  }
}
