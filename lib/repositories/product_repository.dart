import '../models/product_model.dart';
import '../services/products_api_service.dart';
import '../services/api_service.dart';

class ProductRepository {
  final ProductsApiService _apiService = ProductsApiService();
  
  // Local cache of products
  List<ProductModel> _cachedProducts = [];
  DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // Get all products (API first, fallback to cache/demo)
  Future<List<ProductModel>> getAllProducts({
    String? keyword,
    int page = 1,
    bool forceRefresh = false,
  }) async {
    // Check if we should use cache
    if (!forceRefresh && _isCacheValid() && keyword == null) {
      return _cachedProducts;
    }

    try {
      final response = await _apiService.getAllProducts(
        keyword: keyword,
        page: page,
      );

      if (response.success && response.data != null) {
        if (keyword == null) {
          _cachedProducts = response.data!;
          _lastCacheUpdate = DateTime.now();
        }
        return response.data!;
      } else {
        // API failed, return cached data or demo data
        if (_cachedProducts.isNotEmpty) {
          return _cachedProducts;
        } else {
          // Fallback to demo data
          return _getLocalDemoProducts(keyword: keyword);
        }
      }
    } catch (e) {
      print('Error fetching products from API: $e');
      
      // Return cached data or demo data on error
      if (_cachedProducts.isNotEmpty) {
        return _cachedProducts;
      } else {
        return _getLocalDemoProducts(keyword: keyword);
      }
    }
  }

  // Get single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final response = await _apiService.getProductById(productId);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        // Fallback to cache or demo data
        return _findProductInCache(productId);
      }
    } catch (e) {
      print('Error fetching product by ID: $e');
      return _findProductInCache(productId);
    }
  }

  // Create new product (Admin only)
  Future<bool> createProduct(ProductModel product) async {
    try {
      final response = await _apiService.createProduct(product);
      
      if (response.success) {
        // Add to cache
        _cachedProducts.add(response.data!);
        // Also add to local demo list for immediate availability
        demoPopularProducts.add(response.data!);
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating product: $e');
      // Add to local demo list as fallback
      demoPopularProducts.add(product);
      return true; // Return true to indicate local success
    }
  }

  // Update product (Admin only)
  Future<bool> updateProduct(String productId, ProductModel product) async {
    try {
      final response = await _apiService.updateProduct(productId, product);
      
      if (response.success) {
        // Update cache
        final index = _cachedProducts.indexWhere((p) => p.productId == productId);
        if (index != -1) {
          _cachedProducts[index] = response.data!;
        }
        // Update demo list
        final demoIndex = demoPopularProducts.indexWhere((p) => p.productId == productId);
        if (demoIndex != -1) {
          demoPopularProducts[demoIndex] = response.data!;
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating product: $e');
      // Update local demo list as fallback
      final demoIndex = demoPopularProducts.indexWhere((p) => p.productId == productId);
      if (demoIndex != -1) {
        demoPopularProducts[demoIndex] = product;
      }
      return true; // Return true to indicate local success
    }
  }

  // Delete product (Admin only)
  Future<bool> deleteProduct(String productId) async {
    try {
      final response = await _apiService.deleteProduct(productId);
      
      if (response.success) {
        // Remove from cache
        _cachedProducts.removeWhere((p) => p.productId == productId);
        // Remove from demo list
        demoPopularProducts.removeWhere((p) => p.productId == productId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting product: $e');
      // Remove from local demo list as fallback
      demoPopularProducts.removeWhere((p) => p.productId == productId);
      return true; // Return true to indicate local success
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String keyword) async {
    return getAllProducts(keyword: keyword);
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final response = await _apiService.getProductsByCategory(category);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        // Fallback to filtering demo data
        return _getLocalDemoProducts().where((product) {
          return product.brandName.toLowerCase().contains(category.toLowerCase()) ||
                 product.title.toLowerCase().contains(category.toLowerCase());
        }).toList();
      }
    } catch (e) {
      print('Error fetching products by category: $e');
      return _getLocalDemoProducts().where((product) {
        return product.brandName.toLowerCase().contains(category.toLowerCase()) ||
               product.title.toLowerCase().contains(category.toLowerCase());
      }).toList();
    }
  }

  // Check if cache is valid
  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiry;
  }

  // Find product in cache or demo data
  ProductModel? _findProductInCache(String productId) {
    // Try cache first
    try {
      return _cachedProducts.firstWhere((p) => p.productId == productId);
    } catch (e) {
      // Try demo data
      try {
        return demoPopularProducts.firstWhere((p) => p.productId == productId);
      } catch (e) {
        return null;
      }
    }
  }

  // Get local demo products with optional filtering
  List<ProductModel> _getLocalDemoProducts({String? keyword}) {
    List<ProductModel> products = List.from(demoPopularProducts);
    
    if (keyword != null && keyword.isNotEmpty) {
      products = products.where((product) {
        return product.title.toLowerCase().contains(keyword.toLowerCase()) ||
               product.brandName.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    }
    
    return products;
  }

  // Clear cache
  void clearCache() {
    _cachedProducts.clear();
    _lastCacheUpdate = null;
  }

  // Force refresh from API
  Future<List<ProductModel>> refreshProducts() async {
    return getAllProducts(forceRefresh: true);
  }
}
