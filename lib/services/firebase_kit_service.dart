// services/firebase_kit_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../models/SavedKitModel.dart';
import '../models/product_model.dart';

class FirebaseKitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _kitCollection = 'savedKits';
  final String _anonymousUserIdKey = 'anonymous_user_id';
  final Uuid _uuid = Uuid();

  // Get or create an anonymous user ID
  Future<String> _getAnonymousUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_anonymousUserIdKey);
    if (userId == null) {
      userId = _uuid.v4();
      await prefs.setString(_anonymousUserIdKey, userId);
    }
    return userId;
  }

  // Save a kit to Firestore
  Future<void> saveKit({
    required List<ProductModel> kitProducts,
    required String kitName,
    required String diagnosis,
  }) async {
    try {
      final userId = await _getAnonymousUserId();
      final kitId = _uuid.v4(); // Generate a unique ID for the kit
      final assessmentDate = DateFormat('dd MMM, yyyy').format(DateTime.now());

      final kit = SavedKitModel(
        kitId: kitId,
        anonymousUserId: userId,
        kitName: kitName,
        diagnosis: diagnosis,
        assessmentDate: assessmentDate,
        products: kitProducts,
      );

      await _firestore
          .collection(_kitCollection)
          .doc(kitId)
          .set(kit.toJson());
    } catch (e) {
      print("Error saving kit: $e");
      throw Exception("Could not save kit.");
    }
  }

// services/firebase_kit_service.dart

  Future<List<SavedKitModel>> getSavedKits() async {
    try {
      final userId = await _getAnonymousUserId();
      print('Firebase: Attempting to fetch kits for anonymousUserId: $userId');

      final querySnapshot = await _firestore
          .collection(_kitCollection)
          .where('anonymousUserId', isEqualTo: userId)
      // .orderBy('assessmentDate', descending: true) // <-- COMMENT OUT THIS LINE
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('Firebase: No kits found for this user.');
        return [];
      }

      print('Firebase: Found ${querySnapshot.docs.length} kit(s). Parsing...');

      return querySnapshot.docs
          .map((doc) => SavedKitModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Firebase: Error fetching kits: $e");
      throw Exception("Could not fetch kits.");
    }
  }
}