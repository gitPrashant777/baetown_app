import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop/services/api_config.dart';
import 'package:shop/services/api_service.dart';

class ReviewsApiService {
  final ApiService _apiService = ApiService();

  // Get all reviews for a product
  Future<List<Map<String, dynamic>>> getProductReviews(String productId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConfig.reviewsEndpoint}/product/$productId',
        requiresAuth: false,
      );
      
      if (response.success && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data!['reviews'] ?? []);
      }
      print('Failed to get product reviews: ${response.error}');
      return [];
    } catch (e) {
      print('Error getting product reviews: $e');
      return [];
    }
  }

  // Get user reviews
  Future<List<Map<String, dynamic>>> getUserReviews() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConfig.reviewsEndpoint}/user',
        requiresAuth: true,
      );
      
      if (response.success && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data!['reviews'] ?? []);
      }
      print('Failed to get user reviews: ${response.error}');
      return [];
    } catch (e) {
      print('Error getting user reviews: $e');
      return [];
    }
  }

  // Create a new review
  Future<Map<String, dynamic>?> createReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final reviewData = {
        'productId': productId,
        'rating': rating,
        'comment': comment,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.reviewsEndpoint,
        body: reviewData,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to create review: ${response.error}');
      return null;
    } catch (e) {
      print('Error creating review: $e');
      return null;
    }
  }

  // Update a review
  Future<Map<String, dynamic>?> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      final reviewData = {
        'rating': rating,
        'comment': comment,
      };

      final response = await _apiService.put<Map<String, dynamic>>(
        '${ApiConfig.reviewsEndpoint}/$reviewId',
        body: reviewData,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to update review: ${response.error}');
      return null;
    } catch (e) {
      print('Error updating review: $e');
      return null;
    }
  }

  // Delete a review
  Future<bool> deleteReview(String reviewId) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '${ApiConfig.reviewsEndpoint}/$reviewId',
        requiresAuth: true,
      );
      return response.success;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }

  // Get review statistics for a product
  Future<Map<String, dynamic>?> getReviewStats(String productId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConfig.reviewsEndpoint}/stats/$productId',
        requiresAuth: false,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to get review stats: ${response.error}');
      return null;
    } catch (e) {
      print('Error getting review stats: $e');
      return null;
    }
  }
}
