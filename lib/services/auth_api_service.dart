// lib/services/auth_api_service.dart
import '../models/user_session.dart';
import 'api_service.dart';
import 'api_config.dart';

class AuthApiService {
  final ApiService _apiService = ApiService();

  // Login user
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Starting login process...');
      print('📧 Email: $email');
      // This will correctly call '.../api/v1/login'
      print('🌐 Calling: ${ApiConfig.currentBaseUrl}${ApiConfig.loginUserEndpoint}');

      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.loginUserEndpoint, // Uses '/login' from config
        body: {'email': email, 'password': password},
      );

      if (response.success && response.data != null) {
        print('✅ Login successful!');
        final data = response.data!;

        String? token = data['token'] ?? data['accessToken'] ?? data['access_token'];
        if (token != null) {
          await _apiService.setAuthToken(token);
          print('🔑 Token saved');
        }

        if (data['user'] != null) {
          await UserSession.setUserSession(
            email,
            token: token,
            userData: data['user'],
          );
          print('👤 User data stored in session. Role: ${data['user']['role']}');
        } else {
          await UserSession.setUserSession(email, token: token);
        }

        return ApiResponse.success(data);
      } else {
        // Check for specific user not found error
        String? errorMsg = response.error?.toLowerCase();
        if (errorMsg != null && (
            errorMsg.contains('user not found') ||
                errorMsg.contains('user does not exist') ||
                errorMsg.contains('email not found') ||
                errorMsg.contains('invalid credentials')
        )) {
          print('👤 User not found - returning specific error');
          return ApiResponse.error('User not found. Please register first.');
        }

        print('❌ Login failed: ${response.error}');
        return ApiResponse.error(response.error ?? 'Login failed');
      }
    } catch (e) {
      print('💥 Exception during login: $e');
      return ApiResponse.error('Login error: ${e.toString()}');
    }
  }

  // Register user
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    String? avatar,
  }) async {
    try {
      print('📝 Starting registration process...');
      print('👤 Name: $name, Email: $email');
      // This will correctly call '.../api/v1/register'
      print('🌐 Calling: ${ApiConfig.currentBaseUrl}${ApiConfig.registerUserEndpoint}');

      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.registerUserEndpoint, // Uses '/register' from config
        body: {
          'name': name,
          'email': email,
          'password': password,
          if (avatar != null) 'avatar': avatar,
        },
      );

      if (response.success && response.data != null) {
        print('✅ Registration successful!');
        final data = response.data!;

        String? token = data['token'] ?? data['accessToken'] ?? data['access_token'];
        if (token != null) {
          await _apiService.setAuthToken(token);
          print('🔑 Token saved');
        }

        if (data['user'] != null) {
          await UserSession.setUserSession(
            email,
            token: token,
            userData: data['user'],
          );
          print('👤 User data stored in session after registration. Role: ${data['user']['role']}');
        } else {
          await UserSession.setUserSession(email, token: token);
        }

        return ApiResponse.success(data);
      } else {
        print('❌ Registration failed: ${response.error}');
        return ApiResponse.error(response.error ?? 'Registration failed');
      }
    } catch (e) {
      print('💥 Exception during registration: $e');
      return ApiResponse.error('Registration error: ${e.toString()}');
    }
  }

  // Logout user
  Future<ApiResponse<bool>> logout() async {
    try {
      await _apiService.post<Map<String, dynamic>>(
        ApiConfig.logoutUserEndpoint, // This is '/api/v1/logout'
        requiresAuth: true,
      );
    } catch (e) {
      // Ignore errors, just clear token
    }

    // Clear local token regardless of server response
    await _apiService.clearAuthToken();
    await UserSession.clearSession(); // Also clear user session
    print('🚶 User logged out, token cleared');
    return ApiResponse.success(true);
  }

  // Get current user profile
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.profileEndpoint, // This is '/api/v1/profile'
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
        ApiConfig.updateProfileEndpoint, // This is '/api/v1/profile/update'
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

  // Admin login
  Future<ApiResponse<Map<String, dynamic>>> adminLogin({
    String? email,
    required String password,
  }) async {
    final adminEmail = email ?? UserSession.adminEmail;
    print('🔐 Admin login attempt with $adminEmail');

    // Use the standard login function
    final response = await login(email: adminEmail, password: password);

    if (response.success && response.data != null) {
      final user = response.data!['user'];
      if (user != null && user['role']?.toString().toLowerCase() == 'admin') {
        print('✅ Confirmed admin role');
        return response;
      } else {
        print('❌ Access denied: User is not an administrator');
        await logout(); // Log them out, they are not an admin
        return ApiResponse.error('Access denied: User is not an administrator');
      }
    }

    return ApiResponse.error(response.error ?? 'Admin login failed');
  }
}