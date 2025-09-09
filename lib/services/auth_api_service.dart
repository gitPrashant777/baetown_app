import '../models/user_session.dart';
import 'api_service.dart';
import 'api_config.dart';

class AuthApiService {
  final ApiService _apiService = ApiService();

  // Login user (with comprehensive endpoint testing)
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Starting login process...');
      print('📧 Email: $email');
      print('🌐 Current base URL: ${ApiConfig.currentBaseUrl}');

      // First try the standard endpoint with current base URL
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.loginUserEndpoint,  // Using properly defined endpoint
        body: {'email': email, 'password': password},
      );

      if (response.success && response.data != null) {
        print('✅ Login successful with standard endpoint!');
        final data = response.data!;
        
        // Handle token
        String? token = data['token'] ?? data['accessToken'] ?? data['access_token'];
        if (token != null) {
          await _apiService.setAuthToken(token);
          print('🔑 Token saved');
        }
        
        // Store user data in UserSession if available
        if (data['user'] != null) {
          await UserSession.setUserSession(
            email,
            token: token,
            userData: data['user'],
          );
          print('👤 User data stored in session');
          print('🔐 User role: ${data['user']['role']}');
        } else {
          // Fallback: store just email and token
          await UserSession.setUserSession(
            email,
            token: token,
          );
        }
        
        return ApiResponse.success(data);
      } else {
        // Check if this is a "user not found" error
        String? errorMsg = response.error?.toLowerCase();
        if (errorMsg != null && (
            errorMsg.contains('user not found') ||
            errorMsg.contains('user does not exist') ||
            errorMsg.contains('account not found') ||
            errorMsg.contains('email not found') ||
            errorMsg.contains('no user found') ||
            errorMsg.contains('user doesn\'t exist') ||
            errorMsg.contains('invalid credentials') ||
            errorMsg.contains('incorrect email') ||
            errorMsg.contains('user doesn\'t exist')
        )) {
          print('👤 User not found - returning specific error');
          return ApiResponse.error('User not found. Please register first.');
        }
        
        print('❌ Standard endpoint failed, testing alternatives...');
        
        // If standard fails for other reasons, try comprehensive testing
        return await testAuthWithDifferentBases(
          email: email, 
          password: password, 
          isLogin: true
        );
      }
    } catch (e) {
      print('💥 Exception during login: $e');
      
      // If we get HTML response or format error, try different URLs
      if (e.toString().contains('DOCTYPE html') || 
          e.toString().contains('FormatException') ||
          e.toString().contains('Unexpected character')) {
        print('🔍 HTML/Format error detected - testing different URLs...');
        
        return await testAuthWithDifferentBases(
          email: email, 
          password: password, 
          isLogin: true
        );
      }
      
      return ApiResponse.error('Login error: ${e.toString()}');
    }
  }

  // Register user (with comprehensive endpoint testing)
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    String? avatar,
  }) async {
    try {
      print('📝 Starting registration process...');
      print('👤 Name: $name, Email: $email');
      print('🌐 Current base URL: ${ApiConfig.currentBaseUrl}');

      // First try the standard endpoint with current base URL
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.registerUserEndpoint,  // Using properly defined endpoint from config
        body: {
          'name': name,
          'email': email,
          'password': password,
          if (avatar != null) 'avatar': avatar,
        },
      );

      if (response.success && response.data != null) {
        print('✅ Registration successful with standard endpoint!');
        final data = response.data!;
        
        // Handle token
        String? token = data['token'] ?? data['accessToken'] ?? data['access_token'];
        if (token != null) {
          await _apiService.setAuthToken(token);
          print('🔑 Token saved');
        }
        
        // Store user data in UserSession if available
        if (data['user'] != null) {
          await UserSession.setUserSession(
            email,
            token: token,
            userData: data['user'],
          );
          print('👤 User data stored in session after registration');
          print('🔐 User role: ${data['user']['role']}');
        } else {
          // Fallback: store just email and token
          await UserSession.setUserSession(
            email,
            token: token,
          );
          print('👤 Basic session data stored (no user object in response)');
        }
        
        return ApiResponse.success(data);
      } else {
        print('❌ Standard endpoint failed, testing alternatives...');
        
        // If standard fails, try comprehensive testing
        return await testAuthWithDifferentBases(
          name: name,
          email: email, 
          password: password, 
          isLogin: false
        );
      }
    } catch (e) {
      print('💥 Exception during registration: $e');
      
      // If we get HTML response or format error, try different URLs
      if (e.toString().contains('DOCTYPE html') || 
          e.toString().contains('FormatException') ||
          e.toString().contains('Unexpected character')) {
        print('🔍 HTML/Format error detected - testing different URLs...');
        
        return await testAuthWithDifferentBases(
          name: name,
          email: email, 
          password: password, 
          isLogin: false
        );
      }
      
      return ApiResponse.error('Registration error: ${e.toString()}');
    }
  }

  // Test different base URLs and authentication endpoints
  Future<ApiResponse<Map<String, dynamic>>> testAuthWithDifferentBases({
    required String email,
    required String password,
    required bool isLogin,
    String? name,
  }) async {
    final authData = isLogin 
        ? {'email': email, 'password': password}
        : {'name': name!, 'email': email, 'password': password};

    // Different base URL patterns
    final baseUrls = [
      'https://mern-backend-t3h8.onrender.com',           // Without /api/v1
      'https://mern-backend-t3h8.onrender.com/api',       // With /api only
      'https://mern-backend-t3h8.onrender.com/api/v1',    // With /api/v1
    ];

    // Different endpoint patterns
    final endpoints = isLogin 
        ? [ApiConfig.loginUserEndpoint, '/user/login', '/users/login', '/signin']
        : [ApiConfig.registerUserEndpoint, '/auth/register', '/auth/signup', '/signup', '/user/register', '/users/register', '/users'];

    List<String> userNotFoundErrors = [];

    for (String baseUrl in baseUrls) {
      for (String endpoint in endpoints) {
        String fullUrl = '$baseUrl$endpoint'; // Declare fullUrl here
        try {
          print('🧪 Testing: $fullUrl');
          
          // Temporarily create a custom request
          final response = await _apiService.postToCustomUrl<Map<String, dynamic>>(
            fullUrl,
            body: authData,
          );

          if (response.success) {
            print('✅ WORKING URL FOUND: $fullUrl');
            print('📋 Response: ${response.data}');
            
            // Update the config to use this working base URL
            print('💡 Update your ApiConfig.currentBaseUrl to: $baseUrl');
            
            return response;
          } else {
            print('❌ Failed: $fullUrl - ${response.error}');
            
            // Check if this is a user not found error during login
            if (isLogin && response.error != null) {
              String errorMsg = response.error!.toLowerCase();
              if (errorMsg.contains('user not found') ||
                  errorMsg.contains('user does not exist') ||
                  errorMsg.contains('account not found') ||
                  errorMsg.contains('email not found') ||
                  errorMsg.contains('no user found') ||
                  errorMsg.contains('user doesn\'t exist') ||
                  errorMsg.contains('invalid credentials') ||
                  errorMsg.contains('incorrect email')) {
                userNotFoundErrors.add(response.error!);
              }
            }
          }
        } catch (e) {
          print('💥 Error: $fullUrl - $e');
          continue;
        }
      }
    }

    // If this is a login and we got user not found errors, return that instead of endpoint error
    if (isLogin && userNotFoundErrors.isNotEmpty) {
      return ApiResponse.error('User not found. Please register first.');
    }

    return ApiResponse.error('No working authentication endpoint found after testing all combinations');
  }

  // Check if user exists (helpful for login validation)
  Future<ApiResponse<bool>> checkUserExists(String email) async {
    try {
      print('🔍 Checking if user exists: $email');
      
      // Try different endpoints that might check user existence
      final endpoints = [
        '/auth/check-user',
        '/auth/user-exists', 
        '/users/exists',
        '/check-email',
        '/users/check',
      ];
      
      for (String endpoint in endpoints) {
        try {
          final response = await _apiService.post<Map<String, dynamic>>(
            endpoint,
            body: {'email': email},
          );
          
          if (response.success) {
            print('✅ User existence check successful via $endpoint');
            final exists = response.data?['exists'] ?? 
                          response.data?['userExists'] ?? 
                          response.data?['found'] ?? 
                          true; // Default to true if unclear
            return ApiResponse.success(exists);
          }
        } catch (e) {
          continue; // Try next endpoint
        }
      }
      
      // If no dedicated endpoint exists, try a login attempt with dummy password
      // This is a fallback method
      print('🔄 Fallback: Attempting login with dummy password to check user existence');
      
      final loginResponse = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.loginUserEndpoint,
        body: {'email': email, 'password': 'dummy_password_for_check'},
      );
      
      if (loginResponse.error != null) {
        final errorLower = loginResponse.error!.toLowerCase();
        if (errorLower.contains('user not found') ||
            errorLower.contains('user does not exist') ||
            errorLower.contains('account not found') ||
            errorLower.contains('email not found')) {
          return ApiResponse.success(false); // User doesn't exist
        } else if (errorLower.contains('invalid password') ||
                  errorLower.contains('incorrect password') ||
                  errorLower.contains('wrong password')) {
          return ApiResponse.success(true); // User exists but password wrong
        }
      }
      
      // Default to assuming user exists if we can't determine
      return ApiResponse.success(true);
      
    } catch (e) {
      print('💥 Error checking user existence: $e');
      // If we can't check, assume user exists to avoid false redirects
      return ApiResponse.success(true);
    }
  }

  // Logout user
  Future<ApiResponse<bool>> logout() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.logoutUserEndpoint,
        requiresAuth: true,
      );

      // Clear local token regardless of server response
      await _apiService.clearAuthToken();
      
      if (response.success) {
        return ApiResponse.success(true);
      } else {
        // Still return success since we cleared local token
        return ApiResponse.success(true);
      }
    } catch (e) {
      // Clear token even if logout request fails
      await _apiService.clearAuthToken();
      return ApiResponse.success(true);
    }
  }

  // Get current user profile
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.profileEndpoint,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        return ApiResponse.success(response.data!);
      } else {
        return ApiResponse.error(response.error ?? 'Failed to get user profile');
      }
    } catch (e) {
      return ApiResponse.error('Profile error: ${e.toString()}');
    }
  }

  // Update user profile
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;

      final response = await _apiService.put<Map<String, dynamic>>(
        ApiConfig.updateProfileEndpoint,
        body: updateData,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        return ApiResponse.success(response.data!);
      } else {
        return ApiResponse.error(response.error ?? 'Failed to update profile');
      }
    } catch (e) {
      return ApiResponse.error('Update profile error: ${e.toString()}');
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiService.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Refresh token
  Future<ApiResponse<String>> refreshToken() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/refresh', // Simple refresh endpoint
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        final newToken = response.data!['token'];
        if (newToken != null) {
          await _apiService.setAuthToken(newToken);
          return ApiResponse.success(newToken);
        }
      }
      
      return ApiResponse.error(response.error ?? 'Failed to refresh token');
    } catch (e) {
      return ApiResponse.error('Token refresh error: ${e.toString()}');
    }
  }

  // Admin login with any admin email and password
  Future<ApiResponse<Map<String, dynamic>>> adminLogin({
    String? email, // Now optional - can login any admin user
    required String password,
  }) async {
    // Use provided email or fallback to default admin email
    final adminEmail = email ?? UserSession.adminEmail;
    print('🔐 Admin login attempt with $adminEmail');
    
    // Use the defined login endpoint from ApiConfig
    try {
      print('🔧 Using ApiConfig.loginUserEndpoint for admin login...');
      
      var response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.loginUserEndpoint,  // Using properly defined endpoint
        body: {
          'email': adminEmail,
          'password': password,
        },
      );

      if (response.success && response.data != null) {
        print('✅ Admin login successful with /login endpoint!');
        final data = response.data!;
        
        // Verify this is actually an admin user by checking role
        final user = data['user'];
        if (user != null && user['role']?.toString().toLowerCase() == 'admin') {
          print('✅ Confirmed admin role from user data: ${user['role']}');
        } else {
          print('❌ User is not an admin. Role: ${user?['role']}');
          return ApiResponse.error('Access denied: User is not an administrator');
        }
        
        // Handle token
        String? token = data['token'] ?? data['accessToken'] ?? data['access_token'];
        if (token != null) {
          await _apiService.setAuthToken(token);
          print('🔑 Admin token saved from /login');
        }
        
        // Store admin user data in UserSession
        if (data['user'] != null) {
          // Use the actual user data from API response
          Map<String, dynamic> adminUserData = Map<String, dynamic>.from(data['user']);
          
          await UserSession.setUserSession(
            adminUserData['email'], // Use the actual admin's email
            token: token,
            userData: adminUserData,
          );
          print('👤 Admin user data stored in session: ${adminUserData['email']}');
        } else {
          // If no user data from API, create minimal admin user data
          await UserSession.setUserSession(
            adminEmail, // Use the email that was actually used for login
            token: token,
            userData: {
              'email': adminEmail,
              'role': 'admin',
              'name': 'Administrator',
            },
          );
          print('👤 Minimal admin user data created and stored for: $adminEmail');
        }
        
        return ApiResponse.success(data);
      }
      
      print('❌ /login failed: ${response.error}');
      return ApiResponse.error('Admin login failed: ${response.error}');
      
    } catch (e) {
      print('❌ Admin login exception: $e');
      return ApiResponse.error('Admin login failed: ${e.toString()}');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> testLoginEndpoints({
    required String email,
    required String password,
  }) async {
    final loginData = {
      'email': email,
      'password': password,
    };

    // Common authentication endpoint patterns
    final endpoints = [
      ApiConfig.loginUserEndpoint,  // /login  
      '/user/login',     // /api/v1/user/login
      '/users/login',    // /api/v1/users/login
      '/signin',         // /api/v1/signin
    ];

    for (String endpoint in endpoints) {
      try {
        print('🧪 Testing endpoint: ${ApiConfig.currentBaseUrl}$endpoint');
        
        final response = await _apiService.post<Map<String, dynamic>>(
          endpoint,
          body: loginData,
        );

        if (response.success) {
          print('✅ Working endpoint found: $endpoint');
          return response;
        } else {
          print('❌ Endpoint $endpoint failed: ${response.error}');
        }
      } catch (e) {
        print('💥 Endpoint $endpoint error: $e');
        continue;
      }
    }

    return ApiResponse.error('No working login endpoint found. Tested: ${endpoints.join(', ')}');
  }

  // Test different registration endpoints  
  Future<ApiResponse<Map<String, dynamic>>> testRegisterEndpoints({
    required String name,
    required String email,
    required String password,
  }) async {
    final registerData = {
      'name': name,
      'email': email,
      'password': password,
    };

    // Common registration endpoint patterns
    final endpoints = [
      '/auth/register',  // /api/v1/auth/register
      '/register',       // /api/v1/register
      '/auth/signup',    // /api/v1/auth/signup
      '/signup',         // /api/v1/signup
      '/user/register',  // /api/v1/user/register
      '/users/register', // /api/v1/users/register
      '/users',          // /api/v1/users (POST)
    ];

    for (String endpoint in endpoints) {
      try {
        print('🧪 Testing endpoint: ${ApiConfig.currentBaseUrl}$endpoint');
        
        final response = await _apiService.post<Map<String, dynamic>>(
          endpoint,
          body: registerData,
        );

        if (response.success) {
          print('✅ Working endpoint found: $endpoint');
          return response;
        } else {
          print('❌ Endpoint $endpoint failed: ${response.error}');
        }
      } catch (e) {
        print('💥 Endpoint $endpoint error: $e');
        continue;
      }
    }

    return ApiResponse.error('No working registration endpoint found. Tested: ${endpoints.join(', ')}');
  }
}
