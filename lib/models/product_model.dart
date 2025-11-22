// // lib/models/product_model.dart
// class ProductModel {
//   final String? productId;
//   final String title;
//   final String? brandName;
//   final String description;
//   final String category;
//   final double price;
//   final double? priceAfetDiscount;
//   final int? dicountpercent;
//   final int stockQuantity;
//   final int maxOrderQuantity;
//   final bool isOutOfStock;
//   final String image;
//   final List<String> images;
//
//   // New product flags
//   final bool? isOnSale;
//   final bool? isPopular;
//   final bool? isBestSeller;
//   final bool? isFlashSale;
//   final DateTime? flashSaleEnd;
//
//   // --- NEW: Added a placeholder image URL ---
//   static const String _placeholderImage = 'https://via.placeholder.com/300.png?text=No+Image';
//
//   ProductModel({
//     this.productId,
//     required this.title,
//     this.brandName,
//     required this.description,
//     required this.category,
//     required this.price,
//     this.priceAfetDiscount,
//     this.dicountpercent,
//     required this.stockQuantity,
//     required this.maxOrderQuantity,
//     required this.isOutOfStock,
//     required this.image,
//     required this.images,
//     this.isOnSale,
//     this.isPopular,
//     this.isBestSeller,
//     this.isFlashSale,
//     this.flashSaleEnd,
//   });
//   factory ProductModel.fromJson(Map<String, dynamic> json) {
//     // --- FIX FOR IMAGES ---
//     // Robust parser that handles both Strings and Objects (Maps)
//     List<String> parsedImages = [];
//
//     if (json['images'] != null) {
//       if (json['images'] is List) {
//         for (var item in json['images']) {
//           if (item is String && item.isNotEmpty) {
//             // Handle old format: List of strings
//             parsedImages.add(item);
//           } else if (item is Map && item['url'] != null) {
//             // Handle new format: List of objects like {"url": "..."}
//             String url = item['url'].toString();
//             if (url.isNotEmpty) {
//               parsedImages.add(url);
//             }
//           }
//         }
//       }
//     }
//
//     // Ensure we always have at least one image (placeholder if empty)
//     if (parsedImages.isEmpty) {
//       parsedImages.add(_placeholderImage);
//     }
//     // ----------------------
//
//     return ProductModel(
//       productId: json['productId']?.toString() ??
//           json['_id']?.toString() ??
//           json['id']?.toString() ??
//           '',
//
//       title: json['title'] ?? json['name'] ?? 'No Title', // Added fallback for 'name'
//       brandName: json['brandName'] ?? json['brand'] ?? 'BAETOWN', // Added fallback for 'brand'
//       description: json['description'] ?? '',
//       category: json['category'] ?? '',
//       price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0, // Safe parsing
//       stockQuantity: int.tryParse(json['stockQuantity']?.toString() ?? json['stock']?.toString() ?? '0') ?? 0,
//       maxOrderQuantity: int.tryParse(json['maxOrderQuantity']?.toString() ?? '5') ?? 5,
//
//       isOutOfStock: json['isOutOfStock'] ?? false,
//
//       // Use the correctly parsed images list
//       image: parsedImages.first,
//       images: parsedImages,
//
//       // Nullable fields
//       priceAfetDiscount: double.tryParse(json['priceAfetDiscount']?.toString() ?? json['salePrice']?.toString() ?? ''),
//       dicountpercent: int.tryParse(json['dicountpercent']?.toString() ?? json['discount']?.toString() ?? ''),
//
//       isOnSale: json['isOnSale'],
//       isPopular: json['isPopular'],
//       isBestSeller: json['isBestSeller'],
//       isFlashSale: json['isFlashSale'],
//       flashSaleEnd: json['flashSaleEnd'] != null
//           ? DateTime.tryParse(json['flashSaleEnd'].toString())
//           : null,
//     );
//   }
//   // Create from API response (backend data)
//   factory ProductModel.fromApi(Map<String, dynamic> json) {
//     print('🔍 ProductModel.fromApi input: $json');
//
//     // Extract images from backend response
//     List<String> extractImages(dynamic imagesData) {
//       try {
//         if (imagesData is List) {
//           return imagesData
//               .map((img) => img is Map<String, dynamic>
//               ? (img['url'] ?? img['src'] ?? img.toString())
//               : img.toString())
//               .where((url) => url.isNotEmpty)
//               .cast<String>()
//               .toList();
//         }
//         return [];
//       } catch (e) {
//         print('⚠️ Error processing images: $e');
//         return [];
//       }
//     }
//
//     final imagesList = extractImages(json['images']);
//
//     final result = ProductModel(
//       productId: json['_id']?.toString() ?? json['id']?.toString() ?? '',
//       title: json['name'] ?? json['title'] ?? 'Unknown Product',
//       brandName: json['brand'] ?? json['brandName'] ?? 'BAETOWN',
//       description: json['description']?.toString() ?? '',
//       category: json['category']?.toString() ?? '',
//       price: (json['price'] ?? 0).toDouble(),
//       priceAfetDiscount: json['salePrice']?.toDouble() ?? json['discountPrice']?.toDouble(),
//       dicountpercent: json['discount']?.toInt() ?? json['discountPercent']?.toInt(),
//       stockQuantity: json['stock'] ?? json['stockQuantity'] ?? 0,
//       maxOrderQuantity: json['maxOrderQuantity'] ?? 5,
//       isOutOfStock: json['isOutOfStock'] ?? (json['stock'] ?? 0) <= 0,
//
//       // --- THIS IS THE FIX ---
//       // Use the first image if it exists, otherwise use the placeholder
//       image: imagesList.isNotEmpty ? imagesList.first : _placeholderImage,
//
//       images: imagesList.isNotEmpty ? imagesList : [_placeholderImage], // Show placeholder if no images
//
//       isOnSale: json['isOnSale'] ?? false,
//       isPopular: json['isPopular'] ?? false,
//       isBestSeller: json['isBestSeller'] ?? false,
//       isFlashSale: json['isFlashSale'] ?? false,
//       flashSaleEnd: json['flashSaleEnd'] != null
//           ? DateTime.tryParse(json['flashSaleEnd'].toString())
//           : null,
//     );
//
//     print('🔍 ProductModel.fromApi result - ID: ${result.productId}, Title: ${result.title}, Images: ${result.images.length}');
//     return result;
//   }
//
//   // Convert to API JSON for sending
//   Map<String, dynamic> toApiJson() {
//     final result = {
//       'name': title,
//       'description': description.isNotEmpty ? description : title,
//       'category': category.isNotEmpty ? category : 'Other',
//       'price': price,
//       'stock': stockQuantity,
//     };
//
//     // Only send images if they are not the placeholder
//     if (images.isNotEmpty && images.first != _placeholderImage) {
//       result['images'] = images;
//     }
//
//     return result;
//   }
//
//   // Convert to JSON for local storage
//   Map<String, dynamic> toJson() {
//     return {
//       'id': productId,
//       'title': title,
//       'brandName': brandName,
//       'description': description,
//       'category': category,
//       'price': price,
//       'priceAfetDiscount': priceAfetDiscount,
//       'dicountpercent': dicountpercent,
//       'stockQuantity': stockQuantity,
//       'maxOrderQuantity': maxOrderQuantity,
//       'isOutOfStock': isOutOfStock,
//       'image': image,
//       'images': images,
//       'isOnSale': isOnSale,
//       'isPopular': isPopular,
//       'isBestSeller': isBestSeller,
//       'isFlashSale': isFlashSale,
//       'flashSaleEnd': flashSaleEnd?.toIso8601String(),
//     };
//   }
//
//   // factory ProductModel.fromJson(Map<String, dynamic> json) {
//   //   // Helper to safely parse image lists
//   //   List<String> _parseImages(dynamic imageData) {
//   //     if (imageData == null) return [];
//   //     if (imageData is List) {
//   //       return imageData
//   //           .map((img) => img.toString())
//   //           .whereType<String>()
//   //           .toList();
//   //     }
//   //     if (imageData is String) return [imageData];
//   //     return [];
//   //   }
//   //
//   //   final imagesList = _parseImages(json['images']);
//   //
//   //   return ProductModel(
//   //     productId: json['productId']?.toString() ??
//   //         json['_id']?.toString() ??
//   //         json['id']?.toString() ??
//   //         '',
//   //
//   //     title: json['title'] ?? '',
//   //     brandName: json['brandName'] ?? 'BAETOWN',
//   //     description: json['description'] ?? '',
//   //     category: json['category'] ?? '',
//   //     price: (json['price'] as num? ?? 0).toDouble(),
//   //     stockQuantity: (json['stockQuantity'] as num? ?? 0).toInt(),
//   //     maxOrderQuantity: (json['maxOrderQuantity'] as num? ?? 5).toInt(),
//   //     isOutOfStock: json['isOutOfStock'] ?? false,
//   //
//   //     // --- THIS IS THE FIX ---
//   //     image: json['image'] != null && json['image'].toString().isNotEmpty
//   //         ? json['image']
//   //         : _placeholderImage,
//   //     images: imagesList.isNotEmpty ? imagesList : [_placeholderImage],
//   //
//   //     // Nullable fields
//   //     priceAfetDiscount: (json['priceAfetDiscount'] as num?)?.toDouble(),
//   //     dicountpercent: (json['dicountpercent'] as num?)?.toInt(),
//   //     isOnSale: json['isOnSale'],
//   //     isPopular: json['isPopular'],
//   //     isBestSeller: json['isBestSeller'],
//   //     isFlashSale: json['isFlashSale'],
//   //     flashSaleEnd: json['flashSaleEnd'] != null
//   //         ? DateTime.tryParse(json['flashSaleEnd'].toString())
//   //         : null,
//   //   );
//   // }
//
//   int getMaxAllowedQuantity() {
//     return maxOrderQuantity;
//   }
//
//   ProductModel copyWith({
//     String? productId,
//     String? title,
//     String? brandName,
//     String? description,
//     String? category,
//     double? price,
//     double? priceAfetDiscount,
//     int? dicountpercent,
//     int? stockQuantity,
//     int? maxOrderQuantity,
//     bool? isOutOfStock,
//     String? image,
//     List<String>? images,
//     bool? isOnSale,
//     bool? isPopular,
//     bool? isBestSeller,
//     bool? isFlashSale,
//     DateTime? flashSaleEnd,
//   }) {
//     return ProductModel(
//       productId: productId ?? this.productId,
//       title: title ?? this.title,
//       brandName: brandName ?? this.brandName,
//       description: description ?? this.description,
//       category: category ?? this.category,
//       price: price ?? this.price,
//       priceAfetDiscount: priceAfetDiscount ?? this.priceAfetDiscount,
//       dicountpercent: dicountpercent ?? this.dicountpercent,
//       stockQuantity: stockQuantity ?? this.stockQuantity,
//       maxOrderQuantity: maxOrderQuantity ?? this.maxOrderQuantity,
//       isOutOfStock: isOutOfStock ?? this.isOutOfStock,
//       image: image ?? this.image,
//       images: images ?? this.images,
//       isOnSale: isOnSale ?? this.isOnSale,
//       isPopular: isPopular ?? this.isPopular,
//       isBestSeller: isBestSeller ?? this.isBestSeller,
//       isFlashSale: isFlashSale ?? this.isFlashSale,
//       flashSaleEnd: flashSaleEnd ?? this.flashSaleEnd,
//     );
//   }
// }

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
  final int maxOrderQuantity; // ✅ Field definition
  final bool isOutOfStock;
  final String image;
  final List<String> images;

  // New product flags
  final bool? isOnSale;
  final bool? isPopular;
  final bool? isBestSeller;
  final bool? isFlashSale;
  final DateTime? flashSaleEnd;

  static const String _placeholderImage = 'https://placehold.co/300x300/png?text=No+Image';
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
    required this.maxOrderQuantity, // ✅ Required in constructor
    required this.isOutOfStock,
    required this.image,
    required this.images,
    this.isOnSale,
    this.isPopular,
    this.isBestSeller,
    this.isFlashSale,
    this.flashSaleEnd,
  });

  // Helper to safely extract images from any format (String, Map, etc.)
  static List<String> _parseImages(dynamic imagesData) {
    List<String> parsed = [];
    if (imagesData != null && imagesData is List) {
      for (var item in imagesData) {
        if (item is String && item.isNotEmpty) {
          parsed.add(item);
        } else if (item is Map) {
          // Check typical keys for image URL
          final url = item['url'] ?? item['secure_url'] ?? item['link'] ?? item['src'];
          if (url != null && url.toString().isNotEmpty) {
            parsed.add(url.toString());
          }
        }
      }
    }
    // Ensure at least one image exists
    if (parsed.isEmpty) {
      parsed.add(_placeholderImage);
    }
    return parsed;
  }

  // Create from API response (backend data)
  factory ProductModel.fromApi(Map<String, dynamic> json) {
    final imagesList = _parseImages(json['images']);

    return ProductModel(
      productId: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['name'] ?? json['title'] ?? 'Unknown Product',
      brandName: json['brand'] ?? json['brandName'] ?? 'BAETOWN',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      priceAfetDiscount: double.tryParse(json['salePrice']?.toString() ?? '') ?? double.tryParse(json['discountPrice']?.toString() ?? ''),
      dicountpercent: int.tryParse(json['discount']?.toString() ?? '') ?? int.tryParse(json['discountPercent']?.toString() ?? ''),

      // Handle stock mapping (backend often uses 'stock')
      stockQuantity: int.tryParse(json['stock']?.toString() ?? '') ?? int.tryParse(json['stockQuantity']?.toString() ?? '0') ?? 0,

      // ✅ FIX: Safely parse Max Order Quantity from API (default 5)
      maxOrderQuantity: int.tryParse(json['maxOrderQuantity']?.toString() ?? '5') ?? 5,

      isOutOfStock: json['isOutOfStock'] ?? false,

      image: imagesList.first,
      images: imagesList,

      isOnSale: json['isOnSale'] ?? false,
      isPopular: json['isPopular'] ?? false,
      isBestSeller: json['isBestSeller'] ?? false,
      isFlashSale: json['isFlashSale'] ?? false,
      flashSaleEnd: json['flashSaleEnd'] != null
          ? DateTime.tryParse(json['flashSaleEnd'].toString())
          : null,
    );
  }

  // Convert to API JSON for sending (Create/Update)
  Map<String, dynamic> toApiJson() {
    return {
      'name': title,
      'description': description,
      'category': category,
      'price': price,
      'stock': stockQuantity,

      // ✅ FIX: Ensure Max Order Quantity is sent to backend
      'maxOrderQuantity': maxOrderQuantity,

      'isOutOfStock': isOutOfStock,
      'images': images,
      'isOnSale': isOnSale,
      'isPopular': isPopular,
      'isBestSeller': isBestSeller,
      'isFlashSale': isFlashSale,
      if (flashSaleEnd != null) 'flashSaleEnd': flashSaleEnd!.toIso8601String(),
    };
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
      'maxOrderQuantity': maxOrderQuantity, // ✅ Included in local storage
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

  // Create from local storage JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imagesList = _parseImages(json['images']);

    return ProductModel(
      productId: json['productId']?.toString() ?? json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? '',
      brandName: json['brandName'] ?? 'BAETOWN',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      stockQuantity: int.tryParse(json['stockQuantity']?.toString() ?? '0') ?? 0,

      // ✅ FIX: Parse Max Order Quantity from local JSON
      maxOrderQuantity: int.tryParse(json['maxOrderQuantity']?.toString() ?? '5') ?? 5,

      isOutOfStock: json['isOutOfStock'] ?? false,

      image: imagesList.first,
      images: imagesList,

      priceAfetDiscount: double.tryParse(json['priceAfetDiscount']?.toString() ?? ''),
      dicountpercent: int.tryParse(json['dicountpercent']?.toString() ?? ''),
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
      maxOrderQuantity: maxOrderQuantity ?? this.maxOrderQuantity, // ✅ Updated via copyWith
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