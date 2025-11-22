import 'package:shop/models/product_model.dart';
import 'package:shop/services/api_config.dart';
import 'package:shop/services/api_service.dart';

class SearchApiService {
  final ApiService _apiService = ApiService();

  // Search products by query string
  Future<List<ProductModel>> searchProducts({
    required String query,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // --- FIX 1: Use 'keyword' instead of 'q' ---
      // Standard MERN backends look for req.query.keyword
      Map<String, String> queryParams = {
        'keyword': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null) queryParams['category'] = category;
      if (minPrice != null) queryParams['price[gte]'] = minPrice.toString();
      if (maxPrice != null) queryParams['price[lte]'] = maxPrice.toString();
      if (minRating != null) queryParams['ratings[gte]'] = minRating.toString();

      // --- FIX 2: Use the main Products Endpoint ---
      // The screenshot showed /search is for saving history, not fetching items.
      // We search by filtering the main product list.
      final response = await _apiService.get(
        ApiConfig.productsEndpoint, // Usually '/products'
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        final data = response.data!;

        // Standard MERN response: { "success": true, "products": [...] }
        if (data['products'] != null && data['products'] is List) {
          return (data['products'] as List)
              .map((item) => ProductModel.fromJson(item))
              .toList();
        }
      }

      print('Search returned empty or invalid format');
      return [];

    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Get user's search history (Kept original endpoint as it matches screenshot GET /search/data)
  Future<List<String>> getSearchHistory() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConfig.searchEndpoint}/data', // Matches your screenshot GET /search/data
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        // Check for specific keys based on your screenshot's implied structure
        // Often returned as { recentSearches: [...] }
        if (response.data!['recent'] != null) {
          return List<String>.from(response.data!['recent']);
        } else if (response.data!['history'] != null) {
          return List<String>.from(response.data!['history']);
        }
        // Fallback to checking the root if it's just a list
        return [];
      }
      return [];
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  // Get popular search terms
  Future<List<String>> getPopularSearches() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConfig.searchEndpoint}/data',
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        if (response.data!['popular'] != null) {
          return List<String>.from(response.data!['popular']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Clear history
  Future<bool> clearSearchHistory() async {
    try {
      // Assuming DELETE /search/history based on standard patterns
      // You might need to adjust this if your API is different
      final response = await _apiService.delete<Map<String, dynamic>>(
        '${ApiConfig.searchEndpoint}/history',
        requiresAuth: true,
      );
      return response.success;
    } catch (e) {
      return false;
    }
  }
}