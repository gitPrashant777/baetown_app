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
      brandName: json['category'] ?? json['brand'] ?? json['brandName'] ?? 'BAETOWN',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      priceAfetDiscount: json['salePrice']?.toDouble() ?? json['discountPrice']?.toDouble(),
      dicountpercent: json['discount']?.toInt() ?? json['discountPercent']?.toInt(),
      stockQuantity: json['stock'] ?? json['stockQuantity'] ?? 0,
      maxOrderQuantity: json['maxOrderQuantity'] ?? 5,
      isOutOfStock: json['isOutOfStock'] ?? (json['stock'] ?? 0) <= 0,
      image: imagesList.isNotEmpty ? imagesList.first : '',
      images: imagesList,
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
    
    // Only include images if they exist
    if (images.isNotEmpty) {
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

  // Create from JSON (local storage)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['id'],
      title: json['title'] ?? '',
      brandName: json['brandName'] ?? 'BAETOWN',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      priceAfetDiscount: json['priceAfetDiscount']?.toDouble(),
      dicountpercent: json['dicountpercent']?.toInt(),
      stockQuantity: json['stockQuantity'] ?? 0,
      maxOrderQuantity: json['maxOrderQuantity'] ?? 5,
      isOutOfStock: json['isOutOfStock'] ?? false,
      image: json['image'] ?? '',
      images: json['images'] != null 
          ? List<String>.from(json['images'])
          : [json['image'] ?? ''],
      isOnSale: json['isOnSale'],
      isPopular: json['isPopular'],
      isBestSeller: json['isBestSeller'],
      isFlashSale: json['isFlashSale'],
      flashSaleEnd: json['flashSaleEnd'] != null 
          ? DateTime.tryParse(json['flashSaleEnd'].toString())
          : null,
    );
  }

  // Add missing methods
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