class UserSession {
  static bool _isAdmin = false;
  static String _userEmail = '';

  static bool get isAdmin => _isAdmin;
  static String get userEmail => _userEmail;

  static void setUserSession(String email) {
    _userEmail = email.trim();
    _isAdmin = email.toLowerCase() == 'admin@gmail.com';
  }

  static void clearSession() {
    _isAdmin = false;
    _userEmail = '';
  }
}
