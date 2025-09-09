import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop/services/api_config.dart';
import 'package:shop/services/api_service.dart';

class OrdersApiService {
  final ApiService _apiService = ApiService();

  // Get all user orders
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.ordersEndpoint,
        requiresAuth: true,
      );
      
      if (response.success && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data!['orders'] ?? []);
      }
      print('Failed to get user orders: ${response.error}');
      return [];
    } catch (e) {
      print('Error getting user orders: $e');
      return [];
    }
  }

  // Get order by ID
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConfig.ordersEndpoint}/$orderId',
        requiresAuth: true,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to get order: ${response.error}');
      return null;
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  // Create a new order
  Future<Map<String, dynamic>?> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> billingAddress,
    required String paymentMethod,
    String? couponCode,
  }) async {
    try {
      final orderData = {
        'items': items,
        'shippingAddress': shippingAddress,
        'billingAddress': billingAddress,
        'paymentMethod': paymentMethod,
        if (couponCode != null) 'couponCode': couponCode,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.ordersEndpoint,
        body: orderData,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to create order: ${response.error}');
      return null;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Update order status (admin function)
  Future<Map<String, dynamic>?> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final updateData = {
        'status': status,
      };

      final response = await _apiService.put<Map<String, dynamic>>(
        '${ApiConfig.ordersEndpoint}/$orderId/status',
        body: updateData,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to update order status: ${response.error}');
      return null;
    } catch (e) {
      print('Error updating order status: $e');
      return null;
    }
  }

  // Cancel an order
  Future<bool> cancelOrder(String orderId) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '${ApiConfig.ordersEndpoint}/$orderId/cancel',
        body: {},
        requiresAuth: true,
      );
      return response.success;
    } catch (e) {
      print('Error canceling order: $e');
      return false;
    }
  }

  // Get order tracking information
  Future<Map<String, dynamic>?> getOrderTracking(String orderId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConfig.ordersEndpoint}/$orderId/tracking',
        requiresAuth: true,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to get order tracking: ${response.error}');
      return null;
    } catch (e) {
      print('Error getting order tracking: $e');
      return null;
    }
  }

  // Get order history with pagination
  Future<Map<String, dynamic>> getOrderHistory({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      String endpoint = '${ApiConfig.ordersEndpoint}/history?page=$page&limit=$limit';
      if (status != null) {
        endpoint += '&status=$status';
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        requiresAuth: true,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to get order history: ${response.error}');
      return {'orders': [], 'totalPages': 0, 'currentPage': 1};
    } catch (e) {
      print('Error getting order history: $e');
      return {'orders': [], 'totalPages': 0, 'currentPage': 1};
    }
  }

  // Process order return/refund
  Future<Map<String, dynamic>?> processReturn({
    required String orderId,
    required String reason,
    List<String>? itemIds,
  }) async {
    try {
      final returnData = {
        'reason': reason,
        if (itemIds != null) 'itemIds': itemIds,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        '${ApiConfig.ordersEndpoint}/$orderId/return',
        body: returnData,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to process return: ${response.error}');
      return null;
    } catch (e) {
      print('Error processing return: $e');
      return null;
    }
  }
}
