// lib/models/product_model.dart
class ProductModel {
  final String? productId;
  final String title;
  final String? brandName;
  final String description;
  final String category;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;
  final int stockQuantity;
  final int maxOrderQuantity;
  final bool isOutOfStock;
  final String image;
  final List<String> images;

  // New product flags
  final bool? isOnSale;
  final bool? isPopular;
  final bool? isBestSeller;
  final bool? isFlashSale;
  final DateTime? flashSaleEnd;

  // --- NEW: Added a placeholder image URL ---
  static const String _placeholderImage = 'https://via.placeholder.com/300.png?text=No+Image';

  ProductModel({
    this.productId,
    required this.title,
    this.brandName,
    required this.description,
    required this.category,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
    required this.stockQuantity,
    required this.maxOrderQuantity,
    required this.isOutOfStock,
    required this.image,
    required this.images,
    this.isOnSale,
    this.isPopular,
    this.isBestSeller,
    this.isFlashSale,
    this.flashSaleEnd,
  });

  // Create from API response (backend data)
  factory ProductModel.fromApi(Map<String, dynamic> json) {
    print('🔍 ProductModel.fromApi input: $json');

    // Extract images from backend response
    List<String> extractImages(dynamic imagesData) {
      try {
        if (imagesData is List) {
          return imagesData
              .map((img) => img is Map<String, dynamic>
              ? (img['url'] ?? img['src'] ?? img.toString())
              : img.toString())
              .where((url) => url.isNotEmpty)
              .cast<String>()
              .toList();
        }
        return [];
      } catch (e) {
        print('⚠️ Error processing images: $e');
        return [];
      }
    }

    final imagesList = extractImages(json['images']);

    final result = ProductModel(
      productId: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['name'] ?? json['title'] ?? 'Unknown Product',
      brandName: json['brand'] ?? json['brandName'] ?? 'BAETOWN',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      priceAfetDiscount: json['salePrice']?.toDouble() ?? json['discountPrice']?.toDouble(),
      dicountpercent: json['discount']?.toInt() ?? json['discountPercent']?.toInt(),
      stockQuantity: json['stock'] ?? json['stockQuantity'] ?? 0,
      maxOrderQuantity: json['maxOrderQuantity'] ?? 5,
      isOutOfStock: json['isOutOfStock'] ?? (json['stock'] ?? 0) <= 0,

      // --- THIS IS THE FIX ---
      // Use the first image if it exists, otherwise use the placeholder
      image: imagesList.isNotEmpty ? imagesList.first : _placeholderImage,

      images: imagesList.isNotEmpty ? imagesList : [_placeholderImage], // Show placeholder if no images

      isOnSale: json['isOnSale'] ?? false,
      isPopular: json['isPopular'] ?? false,
      isBestSeller: json['isBestSeller'] ?? false,
      isFlashSale: json['isFlashSale'] ?? false,
      flashSaleEnd: json['flashSaleEnd'] != null
          ? DateTime.tryParse(json['flashSaleEnd'].toString())
          : null,
    );

    print('🔍 ProductModel.fromApi result - ID: ${result.productId}, Title: ${result.title}, Images: ${result.images.length}');
    return result;
  }

  // Convert to API JSON for sending
  Map<String, dynamic> toApiJson() {
    final result = {
      'name': title,
      'description': description.isNotEmpty ? description : title,
      'category': category.isNotEmpty ? category : 'Other',
      'price': price,
      'stock': stockQuantity,
    };

    // Only send images if they are not the placeholder
    if (images.isNotEmpty && images.first != _placeholderImage) {
      result['images'] = images;
    }

    return result;
  }

  // Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': productId,
      'title': title,
      'brandName': brandName,
      'description': description,
      'category': category,
      'price': price,
      'priceAfetDiscount': priceAfetDiscount,
      'dicountpercent': dicountpercent,
      'stockQuantity': stockQuantity,
      'maxOrderQuantity': maxOrderQuantity,
      'isOutOfStock': isOutOfStock,
      'image': image,
      'images': images,
      'isOnSale': isOnSale,
      'isPopular': isPopular,
      'isBestSeller': isBestSeller,
      'isFlashSale': isFlashSale,
      'flashSaleEnd': flashSaleEnd?.toIso8601String(),
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse image lists
    List<String> _parseImages(dynamic imageData) {
      if (imageData == null) return [];
      if (imageData is List) {
        return imageData
            .map((img) => img.toString())
            .whereType<String>()
            .toList();
      }
      if (imageData is String) return [imageData];
      return [];
    }

    final imagesList = _parseImages(json['images']);

    return ProductModel(
      productId: json['productId']?.toString() ??
          json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      title: json['title'] ?? '',
      brandName: json['brandName'] ?? 'BAETOWN',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      stockQuantity: (json['stockQuantity'] as num? ?? 0).toInt(),
      maxOrderQuantity: (json['maxOrderQuantity'] as num? ?? 5).toInt(),
      isOutOfStock: json['isOutOfStock'] ?? false,

      // --- THIS IS THE FIX ---
      image: json['image'] != null && json['image'].toString().isNotEmpty
          ? json['image']
          : _placeholderImage,
      images: imagesList.isNotEmpty ? imagesList : [_placeholderImage],

      // Nullable fields
      priceAfetDiscount: (json['priceAfetDiscount'] as num?)?.toDouble(),
      dicountpercent: (json['dicountpercent'] as num?)?.toInt(),
      isOnSale: json['isOnSale'],
      isPopular: json['isPopular'],
      isBestSeller: json['isBestSeller'],
      isFlashSale: json['isFlashSale'],
      flashSaleEnd: json['flashSaleEnd'] != null
          ? DateTime.tryParse(json['flashSaleEnd'].toString())
          : null,
    );
  }

  int getMaxAllowedQuantity() {
    return maxOrderQuantity;
  }

  ProductModel copyWith({
    String? productId,
    String? title,
    String? brandName,
    String? description,
    String? category,
    double? price,
    double? priceAfetDiscount,
    int? dicountpercent,
    int? stockQuantity,
    int? maxOrderQuantity,
    bool? isOutOfStock,
    String? image,
    List<String>? images,
    bool? isOnSale,
    bool? isPopular,
    bool? isBestSeller,
    bool? isFlashSale,
    DateTime? flashSaleEnd,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      brandName: brandName ?? this.brandName,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      priceAfetDiscount: priceAfetDiscount ?? this.priceAfetDiscount,
      dicountpercent: dicountpercent ?? this.dicountpercent,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      maxOrderQuantity: maxOrderQuantity ?? this.maxOrderQuantity,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      image: image ?? this.image,
      images: images ?? this.images,
      isOnSale: isOnSale ?? this.isOnSale,
      isPopular: isPopular ?? this.isPopular,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isFlashSale: isFlashSale ?? this.isFlashSale,
      flashSaleEnd: flashSaleEnd ?? this.flashSaleEnd,
    );
  }
}