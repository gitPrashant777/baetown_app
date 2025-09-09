import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop/services/api_config.dart';
import 'package:shop/services/api_service.dart';

class SearchApiService {
  final ApiService _apiService = ApiService();

  // Search products with various filters
  Future<Map<String, dynamic>> searchProducts({
    required String query,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy, // price_asc, price_desc, rating, newest, popular
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null) queryParams['category'] = category;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (minRating != null) queryParams['minRating'] = minRating.toString();
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      // Convert to query string
      String queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConfig.searchEndpoint}/products?$queryString',
        requiresAuth: false,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to search products: ${response.error}');
      return {
        'products': [],
        'totalResults': 0,
        'totalPages': 0,
        'currentPage': 1,
        'filters': {},
      };
    } catch (e) {
      print('Error searching products: $e');
      return {
        'products': [],
        'totalResults': 0,
        'totalPages': 0,
        'currentPage': 1,
        'filters': {},
      };
    }
  }

  // Get search suggestions/autocomplete
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConfig.searchEndpoint}/suggestions?q=${Uri.encodeComponent(query)}',
        requiresAuth: false,
      );
      
      if (response.success && response.data != null) {
        return List<String>.from(response.data!['suggestions'] ?? []);
      }
      print('Failed to get search suggestions: ${response.error}');
      return [];
    } catch (e) {
      print('Error getting search suggestions: $e');
      return [];
    }
  }

  // Get popular search terms
  Future<List<String>> getPopularSearches() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConfig.searchEndpoint}/popular',
        requiresAuth: false,
      );
      
      if (response.success && response.data != null) {
        return List<String>.from(response.data!['popularSearches'] ?? []);
      }
      print('Failed to get popular searches: ${response.error}');
      return [];
    } catch (e) {
      print('Error getting popular searches: $e');
      return [];
    }
  }

  // Get user's search history
  Future<List<String>> getSearchHistory() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConfig.searchEndpoint}/history',
        requiresAuth: true,
      );
      
      if (response.success && response.data != null) {
        return List<String>.from(response.data!['searchHistory'] ?? []);
      }
      print('Failed to get search history: ${response.error}');
      return [];
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  // Clear user's search history
  Future<bool> clearSearchHistory() async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '${ApiConfig.searchEndpoint}/history',
        requiresAuth: true,
      );
      return response.success;
    } catch (e) {
      print('Error clearing search history: $e');
      return false;
    }
  }

  // Search by image (if supported)
  Future<Map<String, dynamic>> searchByImage(String imageBase64) async {
    try {
      final searchData = {
        'image': imageBase64,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        '${ApiConfig.searchEndpoint}/image',
        body: searchData,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to search by image: ${response.error}');
      return {
        'products': [],
        'confidence': 0.0,
      };
    } catch (e) {
      print('Error searching by image: $e');
      return {
        'products': [],
        'confidence': 0.0,
      };
    }
  }

  // Get search filters for a category
  Future<Map<String, dynamic>> getSearchFilters(String? category) async {
    try {
      String endpoint = '${ApiConfig.searchEndpoint}/filters';
      if (category != null) {
        endpoint += '?category=${Uri.encodeComponent(category)}';
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        requiresAuth: false,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      print('Failed to get search filters: ${response.error}');
      return {
        'priceRange': {'min': 0, 'max': 1000},
        'brands': [],
        'sizes': [],
        'colors': [],
        'ratings': [1, 2, 3, 4, 5],
      };
    } catch (e) {
      print('Error getting search filters: $e');
      return {
        'priceRange': {'min': 0, 'max': 1000},
        'brands': [],
        'sizes': [],
        'colors': [],
        'ratings': [1, 2, 3, 4, 5],
      };
    }
  }
}
