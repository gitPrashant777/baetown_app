import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/models/product_model.dart';

class SavedKitModel {
  final String kitId;
  final String anonymousUserId;
  final String kitName;
  final String diagnosis;
  final String assessmentDate;
  final List<ProductModel> products;

  SavedKitModel({
    required this.kitId,
    required this.anonymousUserId,
    required this.kitName,
    required this.diagnosis,
    required this.assessmentDate,
    required this.products,
  });

  factory SavedKitModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<ProductModel> parsedProducts = [];
    if (data['products'] != null && data['products'] is List) {
      parsedProducts = (data['products'] as List).map((productData) {
        try {
          return ProductModel.fromJson(productData as Map<String, dynamic>);
        } catch (e) {
          print("Error parsing product in kit: $e");
          return null;
        }
      }).whereType<ProductModel>().toList();
    }

    return SavedKitModel(
      kitId: doc.id,
      anonymousUserId: data['anonymousUserId'] ?? '',
      kitName: data['kitName'] ?? 'Unnamed Kit',
      diagnosis: data['diagnosis'] ?? 'No diagnosis',
      assessmentDate: data['assessmentDate'] ?? '',
      products: parsedProducts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anonymousUserId': anonymousUserId,
      'kitName': kitName,
      'diagnosis': diagnosis,
      'assessmentDate': assessmentDate,
      // This calls the updated ProductModel.toJson() which includes the ID
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}