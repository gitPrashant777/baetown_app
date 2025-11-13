import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';

class UserSession {
  static bool _isAdmin = false;
  static String _userEmail = '';
  static String? _authToken;
  static Map<String, dynamic>? _userData;
  static User? _user;

  // Define admin credentials (fallback for legacy admin login)
  static const String adminEmail = 'admin4@example.com'; // Kept for backward compatibility
  static const String defaultAdminPassword = 'admin123@';

  static bool get isAdmin => _isAdmin;
  static String get userEmail => _userEmail;
  static String? get authToken => _authToken;
  static Map<String, dynamic>? get userData => _userData;
  static User? get user => _user;
  static bool get isLoggedIn => _userEmail.isNotEmpty && _authToken != null;

  static const String _emailKey = 'user_email';
  static const String _tokenKey = 'auth_token';
  static const String _adminKey = 'is_admin';
  static const String _userDataKey = 'user_data';

  // Check if user has admin role from API response (ROLE-BASED DETECTION)
  static bool _checkAdminRole(Map<String, dynamic>? userData) {
    if (userData == null) return false;
    
    // Primary check: role from backend response
    String? role = userData['role'];
    if (role != null && role.toLowerCase() == 'admin') {
      print('✅ Admin role detected from backend: $role');
      return true;
    }
    
    print('❌ No admin role detected. Role: $role');
    return false;
  }

  // Check if email is admin email (DEPRECATED - keeping for backward compatibility only)
  static bool isAdminEmail(String email) {
    return email.toLowerCase().trim() == adminEmail.toLowerCase();
  }

  // Get admin user ID for requests
  static String? get adminUserId {
    if (_isAdmin && _userData != null) {
      return _userData!['_id'] ?? _userData!['id'];
    }
    return null;
  }

  // Get admin role for headers
  static String? get userRole {
    if (_isAdmin && _userData != null) {
      return _userData!['role'];
    }
    return null;
  }

  // Load user session from persistent storage
  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString(_emailKey) ?? '';
    _authToken = prefs.getString(_tokenKey);
    _isAdmin = prefs.getBool(_adminKey) ?? false;
    
    // Load user data if available
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      try {
        _userData = Map<String, dynamic>.from(
          json.decode(userDataString)
        );
        
        // Create User object from stored data
        if (_userData != null) {
          _user = User.fromJson(_userData!);
          // Re-validate admin status from stored user data
          _isAdmin = _checkAdminRole(_userData);
        }
      } catch (e) {
        _userData = null;
        _user = null;
      }
    }
  }

  // Set user session and save to persistent storage
  static Future<void> setUserSession(
    String email, {
    String? token,
    Map<String, dynamic>? userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    _userEmail = email.trim();
    _userData = userData;
    
    // Check admin status based on role from API response
    _isAdmin = _checkAdminRole(userData);
    
    // Create User object if userData is available
    if (userData != null) {
      try {
        _user = User.fromJson(userData);
        // Double check admin status from User object
        if (_user!.isAdmin) {
          _isAdmin = true;
        }
      } catch (e) {
        _user = null;
      }
    }
    
    if (token != null) {
      _authToken = token;
      await prefs.setString(_tokenKey, token);
    }
    
    await prefs.setString(_emailKey, _userEmail);
    await prefs.setBool(_adminKey, _isAdmin);
    
    // Save user data if available
    if (userData != null) {
      await prefs.setString(_userDataKey, json.encode(userData));
    }
  }

  // Get current user session data
  static Future<Map<String, dynamic>?> getUserSession() async {
    await loadSession(); // Ensure we have the latest data from storage
    
    if (!isLoggedIn) return null;
    
    return {
      'email': _userEmail,
      'token': _authToken,
      'isAdmin': _isAdmin,
      'userData': _userData,
      'user': _user?.toJson(),
    };
  }

  // Set auth token specifically
  static Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = token;
    await prefs.setString(_tokenKey, token);
  }
// Clear session and remove from persistent storage
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear in-memory variables
    _isAdmin = false;
    _userEmail = '';
    _authToken = null;
    _userData = null;
    _user = null;

    // Remove from persistent storage
    await prefs.remove(_emailKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_adminKey);
    await prefs.remove(_userDataKey);
  }

}
