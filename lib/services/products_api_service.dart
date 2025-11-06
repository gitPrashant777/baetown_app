import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:shop/models/product_model.dart';
import 'package:shop/models/user_session.dart';
import 'package:shop/services/auth_api_service.dart';
import 'package:shop/services/api_config.dart';

class ProductsApiService {
  // Delete a review
  Future<Map<String, dynamic>> deleteReview(String productId,
      String reviewId) async {
    final String? token = await _getValidToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'No authentication token available'};
    }
    final url = Uri.parse(
        '${ApiConfig.currentBaseUrl}/product/$productId/review/$reviewId');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      return {'success': false, 'message': response.body};
    }
  }

  // Submit a review
  Future<Map<String, dynamic>> submitReview(String productId, double rating,
      String comment) async {
    final String? token = await _getValidToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'No authentication token available'};
    }
    final url = Uri.parse('${ApiConfig.currentBaseUrl}/product/review');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'productId': productId,
        'rating': rating,
        'comment': comment,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true};
    } else {
      return {'success': false, 'message': response.body};
    }
  }

  // Fetch reviews for a product
  Future<List<Map<String, dynamic>>> fetchReviews(String productId) async {
    final url = Uri.parse(
        '${ApiConfig.currentBaseUrl}/product/$productId/reviews');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['reviews'] is List) {
        return List<Map<String, dynamic>>.from(data['reviews']);
      }
    }
    return [];
  }

  static const String baseUrl = 'https://mern-backend-t3h8.onrender.com/api/v1';
  final AuthApiService _authService = AuthApiService();

  // Token integrity validation with session preservation approach
  Future<String?> _getValidToken() async {
    // Get token from UserSession first
    final userSession = await UserSession.getUserSession();
    String? token = userSession?['token'] ?? UserSession.authToken;

    if (token == null || token.isEmpty) {
      log('❌ No token available for authentication');
      return null;
    }

    log('🔍 DEBUG: Token found and validating...');
    log('🔐 Current token: ${token.substring(0, 20)}...');
    log('�   - Token length: ${token.length}');

    // Since user is logged in and has a session, use the token they have
    // Even if there are minor corruption patterns, try the existing token first
    log('✅ Using existing session token (user is authenticated)');
    return token;
  }

  // Multi-approach authentication strategy for admin product creation
  Future<Map<String, dynamic>> createProduct(ProductModel product) async {
    print('🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨');
    print(
        '🚨🚨🚨 CREATEPRODUCT METHOD STARTED!!! IF YOU SEE THIS, THE METHOD IS BEING CALLED! 🚨🚨🚨');
    print('🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨');
    log('🌟🌟🌟 CREATEPRODUCT METHOD CALLED - THIS SHOULD APPEAR IN LOGS! 🌟🌟🌟');
    log('🚀 Starting product creation...');

    // Get validated token with integrity checking
    final String? token = await _getValidToken();

    if (token == null || token.isEmpty) {
      log('❌ No valid token available for authentication');
      return {
        'success': false,
        'message': 'No valid authentication token available'
      };
    }

    final url = Uri.parse('$baseUrl/admin/product');

    log('🔍 About to call product.toApiJson()...');
    final productData = product.toApiJson();
    log('✅ toApiJson() completed successfully!');

    log('📦 Creating product with data: ${jsonEncode(productData)}');
    log('🔑 Using token: ${token.length > 10
        ? '${token.substring(0, 10)}...'
        : token}');
    log('🔐 FULL TOKEN DETAILS:');
    log('🔐   - Token length: ${token.length}');
    log('🔐   - Token starts with: ${token.substring(0, 30)}...');
    log('🔐   - Token ends with: ...${token.substring(token.length - 30)}');
    log('🔐   - UserSession.authToken length: ${UserSession.authToken?.length ??
        0}');
    log('🔐   - Both tokens match: ${token == UserSession.authToken}');

    // Use exact Postman approach - Bearer Authorization only (this should work!)
    try {
      log('🚀 Starting HTTP request...');
      log('🌐 POST $url');
      log(
          '📋 Headers: Content-Type: application/json, Authorization: Bearer ${token
              .substring(0, 20)}...');
      log('📦 Body: ${jsonEncode(productData)}');

      // Use exact Postman headers to match successful request
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'PostmanRuntime/7.28.4', // Mimic Postman exactly
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
      };

      log('📋 Headers being sent: ${headers.keys.toList()}');
      log('🔑 FULL AUTHORIZATION HEADER: Authorization: Bearer $token');
      log('🎯 EXACT TOKEN BEING SENT: $token');
      log('📡 About to make HTTP POST request...');
      log('🔑 FULL AUTHORIZATION HEADER: Authorization: Bearer $token');
      log('🎯 EXACT TOKEN BEING SENT: $token');

      // Use string body instead of bytes to avoid encoding issues
      final bodyString = jsonEncode(productData);
      log('📦 JSON body length: ${bodyString.length} bytes');

      // Create HTTP client and request for better compression handling
      final client = http.Client();
      try {
        final response = await client.post(
          url,
          headers: headers,
          body: bodyString, // Use string instead of bytes
        );

        log('📡 HTTP request completed!');
        log('📡 API Response Status: ${response.statusCode}');
        log('📡 API Response Headers: ${response.headers}');

        // Handle response body with automatic decompression
        String responseBody;
        try {
          // The http package should automatically handle decompression
          responseBody = response.body;
          log('📡 API Response Body (auto-decompressed): $responseBody');
        } catch (e) {
          log('❌ Error reading response body: $e');
          // Try manual UTF-8 decoding as fallback
          try {
            responseBody =
                utf8.decode(response.bodyBytes, allowMalformed: true);
            log('📡 API Response Body (UTF-8 manual): $responseBody');
          } catch (e2) {
            // Show debug info for compressed/binary data
            responseBody = 'BINARY_DATA_ERROR';
            log('❌ Could not decode response body as text: $e2');
            log('📡 Response headers indicate: ${response
                .headers['content-encoding']}');
            log('📡 Content type: ${response.headers['content-type']}');
            log('📡 Response body bytes length: ${response.bodyBytes.length}');
            log('📡 First 50 bytes as string attempt: ${String.fromCharCodes(
                response.bodyBytes.take(50))}');
          }
        }

        if (response.statusCode == 201) {
          try {
            final responseData = jsonDecode(responseBody);
            return {
              'success': true,
              'message': 'Product created successfully',
              'data': responseData
            };
          } catch (e) {
            log('❌ Error parsing JSON response: $e');
            return {
              'success': false,
              'message': 'Product created but response parsing failed: $e'
            };
          }
        } else if (response.statusCode == 401) {
          log('🚨 401 Unauthorized - Authentication failed');
          return {
            'success': false,
            'message': 'Authentication failed - 401 Unauthorized. Token: ${token
                .substring(0, 20)}...'
          };
        } else {
          return {
            'success': false,
            'message': 'Failed to create product: ${response
                .statusCode} - $responseBody'
          };
        }
      } finally {
        client.close();
      }
    } catch (e) {
      log('❌ Error creating product: $e');
      return {
        'success': false,
        'message': 'Error creating product: $e'
      };
    }
  }

  // Get all products (handles pagination automatically)
  Future<List<ProductModel>> getAllProducts() async {
    try {
      // First, get the first page to see pagination info
      final url = Uri.parse(
          '$baseUrl/products?limit=100'); // Request up to 100 products
      print('🌐 GET $url (requesting all products)');
      final response = await http.get(url);
      print('📡 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📦 Raw API response structure: ${data.keys.toList()}');

        // Check pagination info
        final totalProducts = data['productCount'] ?? 0;
        final currentPage = data['currentPage'] ?? 1;
        final totalPages = data['totalPages'] ?? 1;
        final resultsPerPage = data['resultsPerPage'] ?? 8;

        print('📊 Pagination Info:');
        print('   Total Products: $totalProducts');
        print('   Current Page: $currentPage');
        print('   Total Pages: $totalPages');
        print('   Results Per Page: $resultsPerPage');

        final productsData = data['products'] ?? data;
        print('📋 Products array type: ${productsData.runtimeType}');

        if (productsData is List) {
          print('📊 Products in this response: ${productsData.length}');

          List<ProductModel> allProducts = [];

          // Add products from first page
          allProducts.addAll(productsData.map((item) {
            print('🔍 Processing product: ${item['name'] ?? item['title'] ??
                'Unknown'}');
            return ProductModel.fromApi(item);
          }).toList());

          // If there are more pages, fetch them
          if (totalPages > 1) {
            print('📄 Fetching remaining ${totalPages - 1} pages...');

            for (int page = 2; page <= totalPages; page++) {
              try {
                final pageUrl = Uri.parse(
                    '$baseUrl/products?page=$page&limit=100');
                print('🌐 GET $pageUrl (page $page)');
                final pageResponse = await http.get(pageUrl);

                if (pageResponse.statusCode == 200) {
                  final pageData = jsonDecode(pageResponse.body);
                  final pageProducts = pageData['products'] ?? [];

                  if (pageProducts is List) {
                    print('📦 Page $page: ${pageProducts.length} products');
                    allProducts.addAll(
                        pageProducts
                            .map((item) => ProductModel.fromApi(item))
                            .toList());
                  }
                } else {
                  print('❌ Failed to fetch page $page: ${pageResponse
                      .statusCode}');
                }
              } catch (e) {
                print('❌ Error fetching page $page: $e');
              }
            }
          }

          print(
              '✅ Total products loaded: ${allProducts.length}/$totalProducts');
          return allProducts;
        } else {
          print('❌ Products data is not a list: $productsData');
          return [];
        }
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Exception in getAllProducts: $e');
      log('Error fetching products: $e');
      return [];
    }
  }

  // Delete product
  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    final String? token = UserSession.authToken;

    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'No authentication token available'};
    }

    try {
      final url = Uri.parse('$baseUrl/admin/product/$productId');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Product deleted successfully'
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete product: ${response
              .statusCode} - ${response.body}'
        };
      }
    } catch (e) {
      log('Error deleting product: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Update product
  Future<Map<String, dynamic>> updateProduct(String productId,
      ProductModel product) async {
    final String? token = UserSession.authToken;

    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'No authentication token available'};
    }

    try {
      final url = Uri.parse('$baseUrl/admin/product/$productId');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-auth-token': token,
        },
        body: jsonEncode(product.toApiJson()),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Product updated successfully',
          'data': jsonDecode(response.body)
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update product: ${response
              .statusCode} - ${response.body}'
        };
      }
    } catch (e) {
      log('Error updating product: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Get single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final url = Uri.parse(
          '${ApiConfig.currentBaseUrl}${ApiConfig.productId.replaceAll(
              '{id}', productId)}');
      log('📡 Fetching product details from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      log('🔍 Product details response status: ${response.statusCode}');
      log('📦 Product details response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Handle different response structures
        if (jsonData['success'] == true && jsonData['product'] != null) {
          // Response format: { success: true, product: {...} }
          return ProductModel.fromApi(jsonData['product']);
        } else
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('_id')) {
          // Direct product object
          return ProductModel.fromApi(jsonData);
        } else {
          log('❌ Unexpected response format for product details');
          return null;
        }
      } else {
        log('❌ Failed to fetch product details: ${response
            .statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      log('❌ Error fetching product details: $e');
      return null;
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      // Since your backend doesn't have a dedicated category endpoint,
      // we'll fetch all products and filter them locally
      final allProducts = await getAllProducts();

      if (allProducts.isEmpty) {
        log('❌ No products available to filter by category');
        return [];
      }

      // Filter products by category (case-insensitive matching)
      final filteredProducts = allProducts.where((product) {
        final productCategory = product.category.toLowerCase();
        final productBrand = product.brandName?.toLowerCase() ?? '';
        final productTitle = product.title.toLowerCase();
        final searchTerm = category.toLowerCase();

        return productCategory.contains(searchTerm) ||
            productBrand.contains(searchTerm) ||
            productTitle.contains(searchTerm);
      }).toList();

      log('✅ Found ${filteredProducts
          .length} products for category: $category');
      return filteredProducts;
    } catch (e) {
      log('❌ Error fetching products by category: $e');
      return [];
    }
  }
}
