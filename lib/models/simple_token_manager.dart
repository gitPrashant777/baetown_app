// Simple token manager to store the EXACT token from login
class SimpleTokenManager {
  static String? _directToken;
  static Map<String, dynamic>? _directUserData;
  
  // Store token directly from login response
  static void storeLoginToken(String token, Map<String, dynamic> userData) {
    _directToken = token;
    _directUserData = userData;
    print('🔐 DIRECT TOKEN STORED: ${token.substring(0, 30)}...${token.substring(token.length-10)}');
    print('👤 USER ROLE: ${userData['role']}');
  }
  
  // Get the exact token for API calls
  static String? getDirectToken() {
    if (_directToken != null) {
      print('🔐 RETURNING DIRECT TOKEN: ${_directToken!.substring(0, 30)}...${_directToken!.substring(_directToken!.length-10)}');
    } else {
      print('❌ NO DIRECT TOKEN AVAILABLE');
    }
    return _directToken;
  }
  
  // Check if user is admin
  static bool isDirectAdmin() {
    return _directUserData?['role']?.toString().toLowerCase() == 'admin';
  }
  
  // Clear on logout
  static void clear() {
    _directToken = null;
    _directUserData = null;
    print('🔐 DIRECT TOKEN CLEARED');
  }
}
