import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_session.dart';
import 'api_service.dart';
import 'api_config.dart';

class ProductApiService {
  final ApiService _apiService = ApiService();

  // Add a new product
  Future<ApiResponse<Map<String, dynamic>>> addProduct({
    required Map<String, dynamic> productData,
    File? imageFile,
  }) async {
    try {
      print('🛍️ Adding new product...');
      print('📊 Product data: $productData');
      print('🖼️ Image file: ${imageFile?.path}');

      // Ensure we have admin privileges
      if (!UserSession.isAdmin) {
        return ApiResponse.error('Admin privileges required');
      }

      // If we have an image file, upload it first or include in multipart request
      if (imageFile != null) {
        return await _addProductWithImage(productData, imageFile);
      } else {
        // Add product without image
        return await _addProductWithoutImage(productData);
      }
    } catch (e) {
      print('❌ Error adding product: $e');
      return ApiResponse.error('Failed to add product: ${e.toString()}');
    }
  }

  // Add product with image (multipart request)
  Future<ApiResponse<Map<String, dynamic>>> _addProductWithImage(
    Map<String, dynamic> productData,
    File imageFile,
  ) async {
    try {
      // Use the correct endpoint from ApiConfig
      final uri = Uri.parse('${ApiConfig.currentBaseUrl}${ApiConfig.createNewProduct}');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header using the same method as ApiService
      final authToken = await _apiService.getAuthToken();
      if (authToken != null) {
        print('🔑 Adding auth token to multipart request: ${authToken.substring(0, 30)}...');
        request.headers['Authorization'] = 'Bearer $authToken';
        request.headers['Accept'] = 'application/json';
      } else {
        print('❌ No auth token found for multipart request!');
        return ApiResponse.error('Authentication required for product creation');
      }

      // Add product data as fields
      productData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add image file
      final imageStream = http.ByteStream(imageFile.openRead());
      final imageLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'image', // Field name expected by API
        imageStream,
        imageLength,
        filename: 'product_image.jpg',
      );
      request.files.add(multipartFile);

      print('🚀 Sending multipart request to: $uri');
      print('🔑 Multipart headers: ${request.headers}');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Try to parse JSON response
        try {
          final data = json.decode(response.body);
          return ApiResponse.success(data);
        } catch (e) {
          print('⚠️ JSON parse error, but status was success');
          return ApiResponse.success({'message': 'Product added successfully'});
        }
      } else {
        return ApiResponse.error('Failed to add product: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Multipart upload error: $e');
      return ApiResponse.error('Upload failed: ${e.toString()}');
    }
  }

  // Add product without image (regular POST request)
  Future<ApiResponse<Map<String, dynamic>>> _addProductWithoutImage(
    Map<String, dynamic> productData,
  ) async {
    try {
      // Add a placeholder image URL if none provided
      productData['image'] = productData['image'] ?? 
          'https://via.placeholder.com/400x400.png?text=No+Image';

      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.createNewProduct, // Use correct endpoint
        body: productData,
        requiresAuth: true,
      );

      if (response.success) {
        print('✅ Product added successfully without image');
        return response;
      } else {
        print('❌ Failed to add product: ${response.error}');
        return response;
      }
    } catch (e) {
      print('❌ Error in regular POST: $e');
      return ApiResponse.error('Failed to add product: ${e.toString()}');
    }
  }

  // Get all products (for admin management)
  Future<ApiResponse<List<Map<String, dynamic>>>> getAllProducts() async {
    try {
      print('📦 Fetching all products for admin...');

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.getAllProducts, // Use correct admin endpoint
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        // Handle different response structures
        List<dynamic> productsList;
        if (response.data!['products'] != null) {
          productsList = response.data!['products'];
        } else if (response.data!['data'] != null) {
          productsList = response.data!['data'];
        } else {
          productsList = [response.data!];
        }
        
        final products = productsList
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        
        print('✅ Fetched ${products.length} products');
        return ApiResponse.success(products);
      } else {
        print('❌ Failed to fetch products: ${response.error}');
        return ApiResponse.error(response.error ?? 'Failed to fetch products');
      }
    } catch (e) {
      print('❌ Error fetching products: $e');
      return ApiResponse.error('Failed to fetch products: ${e.toString()}');
    }
  }

  // Update product
  Future<ApiResponse<Map<String, dynamic>>> updateProduct({
    required String productId,
    required Map<String, dynamic> productData,
    File? imageFile,
  }) async {
    try {
      print('✏️ Updating product: $productId');

      if (!UserSession.isAdmin) {
        return ApiResponse.error('Admin privileges required');
      }

      // Use correct endpoint with product ID
      final endpoint = ApiConfig.updateProduct.replaceAll('{id}', productId);
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint,
        body: productData,
        requiresAuth: true,
      );

      if (response.success) {
        print('✅ Product updated successfully');
        return response;
      } else {
        print('❌ Failed to update product: ${response.error}');
        return response;
      }
    } catch (e) {
      print('❌ Error updating product: $e');
      return ApiResponse.error('Failed to update product: ${e.toString()}');
    }
  }

  // Delete product
  Future<ApiResponse<Map<String, dynamic>>> deleteProduct(String productId) async {
    try {
      print('🗑️ Deleting product: $productId');

      if (!UserSession.isAdmin) {
        return ApiResponse.error('Admin privileges required');
      }

      // Use correct endpoint with product ID
      final endpoint = ApiConfig.deleteProduct.replaceAll('{id}', productId);
      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint,
        requiresAuth: true,
      );

      if (response.success) {
        print('✅ Product deleted successfully');
        return response;
      } else {
        print('❌ Failed to delete product: ${response.error}');
        return response;
      }
    } catch (e) {
      print('❌ Error deleting product: $e');
      return ApiResponse.error('Failed to delete product: ${e.toString()}');
    }
  }
}
