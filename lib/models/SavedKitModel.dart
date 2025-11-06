// models/kit_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/models/product_model.dart'; // <-- ADD THIS IMPORT
// (or use the correct relative path like 'product_model.dart')

class SavedKitModel {
  final String kitId;
  final String anonymousUserId;
  final String kitName;
  final String diagnosis;
  final String assessmentDate;
  final List<ProductModel> products; // <-- This will now use the imported ProductModel

  SavedKitModel({
    required this.kitId,
    required this.anonymousUserId,
    required this.kitName,
    required this.diagnosis,
    required this.assessmentDate,
    required this.products,
  });

// models/kit_models.dart (or SavedKitModel.dart)

  // ... (keep the rest of your SavedKitModel class the same) ...

  factory SavedKitModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    print("--- Parsing Kit ${doc.id} ---");

    // Parse the list of products
    List<ProductModel> parsedProducts = [];
    if (data['products'] is List) {
      List<dynamic> productList = data['products'];

      print("Found ${productList.length} products in kit.");

      parsedProducts = productList.map((productData) {

        print("Attempting to parse product: $productData");

        try {
          // This is the line that calls your product_model.dart
          return ProductModel.fromJson(productData as Map<String, dynamic>);
        } catch (e) {
          // If it fails, print the error and skip this product
          print("!!! FAILED to parse product: $e");
          return null; // Return null on failure
        }
      }).whereType<ProductModel>().toList(); // This filters out any nulls
    }

    return SavedKitModel(
      kitId: doc.id,
      anonymousUserId: data['anonymousUserId'] ?? '',
      kitName: data['kitName'] ?? 'Unnamed Kit',
      diagnosis: data['diagnosis'] ?? 'No diagnosis',
      assessmentDate: data['assessmentDate'] ?? '',
      products: parsedProducts, // Use the safely parsed list
    );
  }

  // ... (keep your toJson() method) ...
  // From Model to Map (for saving to Firestore)
  Map<String, dynamic> toJson() {
    return {
      'anonymousUserId': anonymousUserId,
      'kitName': kitName,
      'diagnosis': diagnosis,
      'assessmentDate': assessmentDate,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}

// --- DELETE THE ProductModel CLASS FROM THIS FILE ---
// (It now lives in product_model.dart)