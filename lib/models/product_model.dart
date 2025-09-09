// For demo only
import 'package:shop/constants.dart';

class ProductModel {
  final String image; // Keep for backward compatibility
  final List<String> images; // New field for multiple images
  final String brandName, title;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;
  final int stockQuantity;
  final int maxOrderQuantity;
  final bool isOutOfStock;
  final String? productId;

  ProductModel({
    required this.image,
    List<String>? images, // Optional for backward compatibility
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
    this.stockQuantity = 20,
    this.maxOrderQuantity = 5,
    this.isOutOfStock = false,
    this.productId,
  }) : images = images ?? [image]; // Use provided images or create list with single image

  ProductModel copyWith({
    String? image,
    List<String>? images,
    String? brandName,
    String? title,
    double? price,
    double? priceAfetDiscount,
    int? dicountpercent,
    int? stockQuantity,
    int? maxOrderQuantity,
    bool? isOutOfStock,
    String? productId,
  }) {
    return ProductModel(
      image: image ?? this.image,
      images: images ?? this.images,
      brandName: brandName ?? this.brandName,
      title: title ?? this.title,
      price: price ?? this.price,
      priceAfetDiscount: priceAfetDiscount ?? this.priceAfetDiscount,
      dicountpercent: dicountpercent ?? this.dicountpercent,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      maxOrderQuantity: maxOrderQuantity ?? this.maxOrderQuantity,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      productId: productId ?? this.productId,
    );
  }

  int getMaxAllowedQuantity() {
    if (isOutOfStock || stockQuantity <= 0) return 0;
    return stockQuantity < maxOrderQuantity ? stockQuantity : maxOrderQuantity;
  }

  // Convert from API JSON response
  factory ProductModel.fromApi(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['id']?.toString() ?? json['_id']?.toString(),
      title: json['title'] ?? json['name'] ?? '',
      brandName: json['brand'] ?? json['brandName'] ?? 'BAETOWN',
      price: (json['price'] ?? 0).toDouble(),
      priceAfetDiscount: json['discountPrice']?.toDouble() ?? json['priceAfterDiscount']?.toDouble(),
      dicountpercent: json['discountPercent']?.toInt() ?? json['discountpercent']?.toInt(),
      stockQuantity: json['stock'] ?? json['stockQuantity'] ?? 0,
      maxOrderQuantity: json['maxOrderQuantity'] ?? 5,
      isOutOfStock: json['isOutOfStock'] ?? (json['stock'] ?? 0) <= 0,
      image: (json['images'] is List && (json['images'] as List).isNotEmpty) 
          ? json['images'][0] 
          : json['image'] ?? '',
      images: json['images'] != null 
          ? List<String>.from(json['images'])
          : [json['image'] ?? ''],
    );
  }

  // Convert to API JSON for sending
  Map<String, dynamic> toApiJson() {
    // Sanitize strings to prevent encoding issues
    String sanitizeString(String input) {
      return input.trim().replaceAll(RegExp(r'[^\w\s.-]'), '');
    }
    
    final result = {
      'name': sanitizeString(title), // Backend expects 'name', not 'title'
      'description': sanitizeString(title), // Use title as description for now
      'category': 'Electronics', // Use default category instead of brandName
      'price': price,
      'stock': stockQuantity, // Backend expects 'stock'
      'images': [], // Include empty images array to match Postman exactly
    };
    print('🔍 toApiJson() returning: $result');
    return result;
  }

  // Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': productId,
      'title': title,
      'brandName': brandName,
      'price': price,
      'priceAfetDiscount': priceAfetDiscount,
      'dicountpercent': dicountpercent,
      'stockQuantity': stockQuantity,
      'maxOrderQuantity': maxOrderQuantity,
      'isOutOfStock': isOutOfStock,
      'image': image,
      'images': images,
    };
  }

  // Create from JSON (local storage)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['id'],
      title: json['title'] ?? '',
      brandName: json['brandName'] ?? 'BAETOWN',
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
    );
  }
}

List<ProductModel> demoPopularProducts = [
  ProductModel(
    image: productDemoImg1,
    title: "Diamond Solitaire Ring",
    brandName: "BAETOWN",
    price: 210820, // 2540 * 83
    priceAfetDiscount: 182600, // 2200 * 83
    dicountpercent: 13,
    stockQuantity: 15,
    maxOrderQuantity: 3,
    productId: "ring_001",
  ),
  ProductModel(
    image: productDemoImg4,
    title: "Gold Tennis Bracelet",
    brandName: "BAETOWN",
    price: 149400, // 1800 * 83
    stockQuantity: 8,
    maxOrderQuantity: 2,
    productId: "bracelet_001",
  ),
  ProductModel(
    image: productDemoImg5,
    title: "Pearl Drop Earrings",
    brandName: "BAETOWN",
    price: 54001, // 650.62 * 83
    priceAfetDiscount: 43202, // 520.50 * 83
    dicountpercent: 20,
    stockQuantity: 3,
    maxOrderQuantity: 5,
    productId: "earring_001",
  ),
  ProductModel(
    image: productDemoImg6,
    title: "Emerald Pendant Necklace",
    brandName: "BAETOWN",
    price: 104912, // 1264 * 83
    priceAfetDiscount: 91366, // 1100.8 * 83
    dicountpercent: 13,
    stockQuantity: 0,
    maxOrderQuantity: 4,
    isOutOfStock: true,
    productId: "necklace_001",
  ),
  ProductModel(
    image: productDemoImg3,
    title: "Ruby Stud Earrings",
    brandName: "BAETOWN",
    price: 54001, // 650.62 * 83
    priceAfetDiscount: 43202, // 520.50 * 83
    dicountpercent: 20,
  ),
  ProductModel(
    image: productDemoImg2,
    title: "Silver Chain Bracelet",
    brandName: "BAETOWN",
    price: 104912, // 1264 * 83
    priceAfetDiscount: 91366, // 1100.8 * 83
    dicountpercent: 13,
  ),
];
List<ProductModel> demoFlashSaleProducts = [
  ProductModel(
    image: productDemoImg5,
    title: "Diamond Stud Earrings",
    brandName: "BAETOWN",
    price: 54001, // 650.62 * 83
    priceAfetDiscount: 43202, // 520.50 * 83
    dicountpercent: 20,
  ),
  ProductModel(
    image: productDemoImg6,
    title: "Gold Charm Bracelet",
    brandName: "BAETOWN",
    price: 104912, // 1264 * 83
    priceAfetDiscount: 91366, // 1100.8 * 83
    dicountpercent: 13,
  ),
  ProductModel(
    image: productDemoImg4,
    title: "Sapphire Cocktail Ring",
    brandName: "BAETOWN",
    price: 66400, // 800 * 83
    priceAfetDiscount: 56440, // 680 * 83
    dicountpercent: 15,
  ),
];
List<ProductModel> demoBestSellersProducts = [
  ProductModel(
    image: productDemoImg1,
    title: "Vintage Pearl Necklace",
    brandName: "BAETOWN",
    price: 54001, // 650.62 * 83
    priceAfetDiscount: 43202, // 520.50 * 83
    dicountpercent: 20,
  ),
  ProductModel(
    image: productDemoImg2,
    title: "Rose Gold Hoop Earrings",
    brandName: "BAETOWN",
    price: 104912, // 1264 * 83
    priceAfetDiscount: 91366, // 1100.8 * 83
    dicountpercent: 13,
  ),
  ProductModel(
    image: productDemoImg4,
    title: "Crystal Tennis Bracelet",
    brandName: "BAETOWN",
    price: 66400, // 800 * 83
    priceAfetDiscount: 56440, // 680 * 83
    dicountpercent: 15,
  ),
];
List<ProductModel> kidsProducts = [
  ProductModel(
    image: productDemoImg5,
    title: "Butterfly Pendant Necklace",
    brandName: "BAETOWN Kids",
    price: 12501, // 150.62 * 83
    priceAfetDiscount: 10002, // 120.50 * 83
    dicountpercent: 20,
  ),
  ProductModel(
    image: productDemoImg6,
    title: "Colorful Bead Bracelet",
    brandName: "BAETOWN Kids",
    price: 7470, // 89.99 * 83
  ),
  ProductModel(
    image: productDemoImg3,
    title: "Heart Stud Earrings",
    brandName: "BAETOWN Kids",
    price: 6225, // 75.00 * 83
  ),
  ProductModel(
    image: productDemoImg4,
    title: "Rainbow Hair Clips Set",
    brandName: "BAETOWN Kids",
    price: 3735, // 45.00 * 83
    priceAfetDiscount: 2988, // 36.00 * 83
    dicountpercent: 20,
  ),
  ProductModel(
    image: productDemoImg5,
    title: "Unicorn Charm Bracelet",
    brandName: "BAETOWN Kids",
    price: 5395, // 65.00 * 83
  ),
  ProductModel(
    image: productDemoImg1,
    title: "Princess Tiara",
    brandName: "BAETOWN Kids",
    price: 10375, // 125.00 * 83
  ),
];
