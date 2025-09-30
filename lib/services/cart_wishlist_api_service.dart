import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop/services/api_config.dart';
import 'package:shop/services/api_service.dart';

class CartApiService {
  final ApiService _apiService = ApiService();

  // Get user's cart
  Future<Map<String, dynamic>?> getCart() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.cartEndpoint,
        requiresAuth: true,
      );
      
      if (response.success && response.data != null) {
        print('Cart data received: ${response.data}');
        return response.data!;
      }
      print('Failed to get cart: ${response.error}');
      return null;
    } catch (e) {
      print('Error getting cart: $e');
      return null;
    }
  }

  // Add item to cart
  Future<Map<String, dynamic>?> addToCart({
    required String productId,
    required int quantity,
    String? size,
    String? color,
  }) async {
    try {
      final cartData = {
        'productId': productId,
        'quantity': quantity,
        if (size != null) 'size': size,
        if (color != null) 'color': color,
      };

      print('Adding to cart: $cartData');
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.cartEndpoint,
        body: cartData,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        print('Item added to cart successfully');
        return response.data!;
      }
      print('Failed to add to cart: ${response.error}');
      return null;
    } catch (e) {
      print('Error adding to cart: $e');
      return null;
    }
  }

  // Update cart item quantity
  Future<Map<String, dynamic>?> updateCartItem({
    required String itemId, // This should be the cartItemId
    required int quantity,
  }) async {
    try {
      final updateData = {
        'quantity': quantity,
      };

      print('Updating cart item with cartItemId: $itemId, quantity: $quantity');
      // Use the correct endpoint format from ApiConfig - replace {cartItemId} with actual cartItemId
      final endpoint = ApiConfig.updateCartItemQuantityEndpoint.replaceFirst('{cartItemId}', itemId);
      print('Update endpoint: $endpoint');
      
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint,
        body: updateData,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        print('Cart item updated successfully');
        return response.data!;
      }
      print('Failed to update cart item: ${response.error}');
      return null;
    } catch (e) {
      print('Error updating cart item: $e');
      return null;
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(String productId) async {
    try {
      print('Removing cart item with product ID: $productId');
      // Use the correct endpoint format from ApiConfig - replace {cartItemId} with actual productId
      final endpoint = ApiConfig.deleteCartItemEndpoint.replaceFirst('{cartItemId}', productId);
      print('Delete endpoint: $endpoint');
      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint,
        requiresAuth: true,
      );
      if (response.success) {
        print('Cart item removed successfully');
        return true;
      } else {
        print('Failed to remove cart item: ${response.error}');
        return false;
      }
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  // Clear entire cart
  Future<bool> clearCart() async {
    try {
      print('Clearing entire cart');
      
      // Since there's no specific clear endpoint in ApiConfig, we'll use a generic approach
      // You might need to implement this endpoint in your backend
      final response = await _apiService.delete<Map<String, dynamic>>(
        '${ApiConfig.cartEndpoint}/clear',
        requiresAuth: true,
      );
      
      if (response.success) {
        print('Cart cleared successfully');
        return true;
      } else {
        print('Failed to clear cart: ${response.error}');
        return false;
      }
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // Apply coupon to cart
  Future<Map<String, dynamic>?> applyCoupon(String couponCode) async {
    try {
      final couponData = {
        'couponCode': couponCode,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        '${ApiConfig.cartEndpoint}/coupon',
        body: couponData,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to apply coupon: ${response.error}');
      return null;
    } catch (e) {
      print('Error applying coupon: $e');
      return null;
    }
  }

  // Remove coupon from cart
  Future<bool> removeCoupon() async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '${ApiConfig.cartEndpoint}/coupon',
        requiresAuth: true,
      );
      return response.success;
    } catch (e) {
      print('Error removing coupon: $e');
      return false;
    }
  }

  // Get cart summary (totals, taxes, discounts)
  Future<Map<String, dynamic>?> getCartSummary() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConfig.cartEndpoint}/summary',
        requiresAuth: true,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to get cart summary: ${response.error}');
      return null;
    } catch (e) {
      print('Error getting cart summary: $e');
      return null;
    }
  }
}

class WishlistApiService {
  final ApiService _apiService = ApiService();

  // Get user's wishlist
  Future<List<Map<String, dynamic>>> getWishlist() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.wishlistEndpoint,
        requiresAuth: true,
      );
      
      if (response.success && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data!['items'] ?? []);
      }
      print('Failed to get wishlist: ${response.error}');
      return [];
    } catch (e) {
      print('Error getting wishlist: $e');
      return [];
    }
  }

  // Add item to wishlist
  Future<Map<String, dynamic>?> addToWishlist(String productId) async {
    try {
      final wishlistData = {
        'productId': productId,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.wishlistEndpoint,
        body: wishlistData,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to add to wishlist: ${response.error}');
      return null;
    } catch (e) {
      print('Error adding to wishlist: $e');
      return null;
    }
  }

  // Remove item from wishlist
  Future<bool> removeFromWishlist(String productId) async {
    try {
      // Use the correct endpoint format from ApiConfig
      final endpoint = ApiConfig.deleteWishlistProductEndpoint.replaceFirst('{productId}', productId);
      
      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint,
        requiresAuth: true,
      );
      return response.success;
    } catch (e) {
      print('Error removing from wishlist: $e');
      return false;
    }
  }

  // Check if item is in wishlist
  Future<bool> isInWishlist(String productId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.wishlistEndpoint,
        requiresAuth: true,
      );
      // Check if productId is in the wishlist array
      if (response.success && response.data != null && response.data!['wishlist'] is List) {
        final wishlist = response.data!['wishlist'] as List;
        return wishlist.any((item) {
          if (item is Map<String, dynamic>) {
            return item['productId'] == productId || item['_id'] == productId;
          }
          return false;
        });
      }
      
      if (response.success && response.data != null) {
        return response.data!['isInWishlist'] == true;
      }
      return false;
    } catch (e) {
      print('Error checking wishlist: $e');
      return false;
    }
  }

  // Move item from wishlist to cart
  Future<Map<String, dynamic>?> moveToCart({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      final moveData = {
        'productId': productId,
        'quantity': quantity,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        '${ApiConfig.wishlistEndpoint}/move-to-cart',
        body: moveData,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to move to cart: ${response.error}');
      return null;
    } catch (e) {
      print('Error moving to cart: $e');
      return null;
    }
  }
} 