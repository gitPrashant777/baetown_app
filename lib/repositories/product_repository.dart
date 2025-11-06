// ignore_for_file: avoid_print

import '../constants.dart';
import '../models/product_model.dart';
import '../services/products_api_service.dart';

class ProductRepository {
  final ProductsApiService _apiService = ProductsApiService();

  // Local cache of products
  List<ProductModel> _cachedProducts = [];
  DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // 🔹 Get all products (API first, fallback to cache/demo)
  Future<List<ProductModel>> getAllProducts({
    String? keyword,
    int page = 1,
    bool forceRefresh = false,
  }) async {
    // Use cache if valid
    if (!forceRefresh && _isCacheValid() && keyword == null) {
      return _cachedProducts;
    }

    try {
      // Updated: no keyword/page parameters in API
      final products = await _apiService.getAllProducts();

      if (products.isNotEmpty) {
        if (keyword == null) {
          _cachedProducts = products;
          _lastCacheUpdate = DateTime.now();
        }

        // Filter locally if keyword provided
        if (keyword != null && keyword.isNotEmpty) {
          return products.where((p) {
            return p.title.toLowerCase().contains(keyword.toLowerCase()) ||
                (p.brandName?.toLowerCase().contains(keyword.toLowerCase()) ?? false);
          }).toList();
        }

        return products;
      } else {
        return _cachedProducts.isNotEmpty
            ? _cachedProducts
            : _getLocalDemoProducts(keyword: keyword);
      }
    } catch (e) {
      print('Error fetching products from API: $e');
      return _cachedProducts.isNotEmpty
          ? _cachedProducts
          : _getLocalDemoProducts(keyword: keyword);
    }
  }

  // 🔹 Get single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final product = await _apiService.getProductById(productId);
      return product ?? _findProductInCache(productId);
    } catch (e) {
      print('Error fetching product by ID: $e');
      return _findProductInCache(productId);
    }
  }

  // 🔹 Create new product (Admin only)
  Future<bool> createProduct(ProductModel product) async {
    try {
      final response = await _apiService.createProduct(product);

      if (response['success'] == true) {
        // Try to extract the created product from response
        if (response['data'] != null && response['data']['product'] != null) {
          final createdProduct = ProductModel.fromApi(response['data']['product']);
          _cachedProducts.add(createdProduct);
          demoPopularProducts.add(createdProduct);
        } else {
          // If no product data in response, add the original product
          _cachedProducts.add(product);
          demoPopularProducts.add(product);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating product: $e');
      demoPopularProducts.add(product);
      return true;
    }
  }

  // 🔹 Update product (Admin only)
  Future<bool> updateProduct(String productId, ProductModel product) async {
    try {
      final response = await _apiService.updateProduct(productId, product);

      if (response['success'] == true) {
        // Try to extract the updated product from response
        ProductModel updatedProduct;
        if (response['data'] != null && response['data']['product'] != null) {
          updatedProduct = ProductModel.fromApi(response['data']['product']);
        } else {
          updatedProduct = product;
        }

        final index = _cachedProducts.indexWhere((p) => p.productId == productId);
        if (index != -1) _cachedProducts[index] = updatedProduct;

        final demoIndex =
        demoPopularProducts.indexWhere((p) => p.productId == productId);
        if (demoIndex != -1) demoPopularProducts[demoIndex] = updatedProduct;

        return true;
      }
      return false;
    } catch (e) {
      print('Error updating product: $e');
      final demoIndex =
      demoPopularProducts.indexWhere((p) => p.productId == productId);
      if (demoIndex != -1) demoPopularProducts[demoIndex] = product;
      return true;
    }
  }

  // 🔹 Delete product (Admin only)
  Future<bool> deleteProduct(String productId) async {
    try {
      final response = await _apiService.deleteProduct(productId);

      if (response['success'] == true) {
        _cachedProducts.removeWhere((p) => p.productId == productId);
        demoPopularProducts.removeWhere((p) => p.productId == productId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting product: $e');
      demoPopularProducts.removeWhere((p) => p.productId == productId);
      return true;
    }
  }

  // 🔍 Search products
  Future<List<ProductModel>> searchProducts(String keyword) async {
    return getAllProducts(keyword: keyword);
  }

  // 🏷️ Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final products = await _apiService.getProductsByCategory(category);

      if (products.isNotEmpty) {
        return products;
      } else {
        return _getLocalDemoProducts().where((product) {
          return (product.brandName?.toLowerCase().contains(category.toLowerCase()) ?? false) ||
              product.title.toLowerCase().contains(category.toLowerCase()) ||
              product.category.toLowerCase().contains(category.toLowerCase());
        }).toList();
      }
    } catch (e) {
      print('Error fetching products by category: $e');
      return _getLocalDemoProducts().where((product) {
        return (product.brandName?.toLowerCase().contains(category.toLowerCase()) ?? false) ||
            product.title.toLowerCase().contains(category.toLowerCase()) ||
            product.category.toLowerCase().contains(category.toLowerCase());
      }).toList();
    }
  }

  // ✅ Cache check
  bool _isCacheValid() {
    final lastUpdate = _lastCacheUpdate;
    if (lastUpdate == null) return false;
    return DateTime.now().difference(lastUpdate) < _cacheExpiry;
  }

  // 🧩 Find product in cache/demo
  ProductModel? _findProductInCache(String productId) {
    try {
      return _cachedProducts.firstWhere((p) => p.productId == productId);
    } catch (_) {
      try {
        return demoPopularProducts.firstWhere((p) => p.productId == productId);
      } catch (_) {
        return null;
      }
    }
  }

  // 💾 Demo fallback
  List<ProductModel> _getLocalDemoProducts({String? keyword}) {
    List<ProductModel> products = List.from(demoPopularProducts);

    if (keyword != null && keyword.isNotEmpty) {
      products = products.where((product) {
        return product.title.toLowerCase().contains(keyword.toLowerCase()) ||
            (product.brandName?.toLowerCase().contains(keyword.toLowerCase()) ?? false);
      }).toList();
    }
    return products;
  }

  // ♻️ Clear cache
  void clearCache() {
    _cachedProducts.clear();
    _lastCacheUpdate = null;
  }

  // 🔄 Force refresh
  Future<List<ProductModel>> refreshProducts() async {
    return getAllProducts(forceRefresh: true);
  }
}
