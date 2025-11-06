// lib/models/user_session.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? authToken;

  static Future<Map<String, dynamic>?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    authToken = token;

    // You can expand this to return other saved user data
    if (token != null) {
      return {'token': token};
    }
    return null;
  }
}