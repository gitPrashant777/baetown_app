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
  final Uuid _uuid = const Uuid();

  Future<String> _getAnonymousUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_anonymousUserIdKey);
    if (userId == null) {
      userId = _uuid.v4();
      await prefs.setString(_anonymousUserIdKey, userId);
    }
    return userId;
  }

  Future<void> saveKit({
    required List<ProductModel> kitProducts,
    required String kitName,
    required String diagnosis,
  }) async {
    try {
      final userId = await _getAnonymousUserId();
      final kitId = _uuid.v4();
      final assessmentDate = DateFormat('dd MMM, yyyy').format(DateTime.now());

      final kit = SavedKitModel(
        kitId: kitId,
        anonymousUserId: userId,
        kitName: kitName,
        diagnosis: diagnosis,
        assessmentDate: assessmentDate,
        products: kitProducts,
      );

      // Saves the full structure (including product IDs) to Firestore
      await _firestore
          .collection(_kitCollection)
          .doc(kitId)
          .set(kit.toJson());

      print("✅ Kit saved successfully to Firebase.");
    } catch (e) {
      print("❌ Error saving kit: $e");
      throw Exception("Could not save kit.");
    }
  }

  Future<List<SavedKitModel>> getSavedKits() async {
    try {
      final userId = await _getAnonymousUserId();
      final querySnapshot = await _firestore
          .collection(_kitCollection)
          .where('anonymousUserId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => SavedKitModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("❌ Error fetching kits: $e");
      return [];
    }
  }
}