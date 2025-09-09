import 'dart:io';
import 'api_service.dart';
import 'api_config.dart';
import '../models/user_session.dart';

class UserApiService {
  final ApiService _apiService = ApiService();

  // Get user profile details
  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    try {
      print('👤 Fetching user profile...');
      print('🔑 Current token: ${await _apiService.getAuthToken()}');
      
      // Check if we have a valid token first
      final token = await _apiService.getAuthToken();
      if (token == null || token.isEmpty) {
        print('❌ No authentication token found');
        return ApiResponse.error('Authentication required. Please login again.');
      }
      
      // Since Postman is working with /api/v1/profile, let's try that first with proper auth
      try {
        print('🎯 Trying direct API call to working endpoint...');
        final response = await _apiService.get<Map<String, dynamic>>(
          ApiConfig.profileEndpoint,
          requiresAuth: true,
        );

        print('📡 Direct API call response status: ${response.success}');
        if (response.success && response.data != null) {
          print('✅ Profile fetched successfully from main endpoint');
          return response;
        } else {
          print('❌ Main endpoint failed: ${response.error}');
          // Fall back to local data if main endpoint fails
          return await _fallbackToLocalProfile();
        }
      } catch (e) {
        print('❌ Error with main endpoint: $e');
        
        // If it's a FormatException, it means we got HTML instead of JSON
        if (e.toString().contains('FormatException') || e.toString().contains('DOCTYPE html')) {
          print('🚨 HTML response detected - server returned error page instead of JSON');
        }
        
        // Fall back to local data
        return await _fallbackToLocalProfile();
      }
    } catch (e) {
      print('❌ Error fetching profile: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('NetworkException')) {
        return ApiResponse.error('Network error. Please check your internet connection.');
      } else {
        return await _fallbackToLocalProfile();
      }
    }
  }

  // Fallback method to use local profile data
  Future<ApiResponse<Map<String, dynamic>>> _fallbackToLocalProfile() async {
    try {
      print('� Falling back to local profile data...');
      
      // Try to get user data from local session
      final userSession = await UserSession.getUserSession();
      if (userSession != null && userSession.isNotEmpty) {
        print('✅ Using local profile data');
        
        // Check if we have userData nested or directly in session
        final userData = userSession['userData'] ?? userSession;
        
        return ApiResponse.success({
          'user': {
            'name': userData['name'] ?? userSession['name'] ?? 'User',
            'email': userData['email'] ?? userSession['email'] ?? 'user@example.com',
            'role': userData['role'] ?? userSession['role'] ?? 'user',
            'walletBalance': userData['walletBalance'] ?? userSession['walletBalance'] ?? 0,
            'preferences': userData['preferences'] ?? userSession['preferences'] ?? {},
            'language': userData['language'] ?? userSession['language'] ?? 'en',
            'notificationsEnabled': userData['notificationsEnabled'] ?? userSession['notificationsEnabled'] ?? true,
            'bookmarks': userData['bookmarks'] ?? userSession['bookmarks'] ?? [],
            'cart': userData['cart'] ?? userSession['cart'] ?? [],
          }
        });
      } else {
        print('❌ No local profile data available');
        return ApiResponse.error('Profile data unavailable. Please login again.');
      }
    } catch (e) {
      print('❌ Error accessing local profile: $e');
      return ApiResponse.error('Unable to load profile. Please try restarting the app.');
    }
  }

  // Update user profile
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
    Map<String, dynamic>? preferences,
    String? language,
  }) async {
    try {
      print('📝 Updating user profile...');
      
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (avatar != null) updateData['avatar'] = avatar;
      if (preferences != null) updateData['preferences'] = preferences;
      if (language != null) updateData['language'] = language;

      // Try different common update endpoints
      final endpoints = [
        ApiConfig.updateProfileEndpoint, // '/profile/update'
        '/me',                          // PUT to /me
        '/profile',                     // PUT to /profile
        '/user/profile',                // PUT to /user/profile
        '/users/me',                   // PUT to /users/me
      ];
      
      ApiResponse<Map<String, dynamic>>? lastResponse;
      
      for (final endpoint in endpoints) {
        try {
          print('🧪 Trying update endpoint: $endpoint');
          
          final response = await _apiService.put<Map<String, dynamic>>(
            endpoint,
            body: updateData,
            requiresAuth: true,
          );

          if (response.success) {
            print('✅ Profile updated successfully with: $endpoint');
            return response;
          } else {
            print('❌ Failed with $endpoint: ${response.error}');
            lastResponse = response;
          }
        } catch (e) {
          print('⚠️ Error with $endpoint: $e');
        }
      }
      
      // If all endpoints failed, return the last response
      if (lastResponse != null) {
        print('❌ All update endpoints failed. Last error: ${lastResponse.error}');
        return lastResponse;
      } else {
        return ApiResponse.error('All update endpoints failed');
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      return ApiResponse.error('Failed to update profile: ${e.toString()}');
    }
  }

  // Update user password
  Future<ApiResponse<Map<String, dynamic>>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      print('🔐 Updating user password...');
      
      final response = await _apiService.put<Map<String, dynamic>>(
        ApiConfig.updateUserPasswordEndpoint,
        body: {
          'oldPassword': currentPassword,
          'newPassword': newPassword,
        },
        requiresAuth: true,
      );

      if (response.success) {
        print('✅ Password updated successfully');
        return response;
      } else {
        print('❌ Failed to update password: ${response.error}');
        return response;
      }
    } catch (e) {
      print('❌ Error updating password: $e');
      return ApiResponse.error('Failed to update password: ${e.toString()}');
    }
  }

  // Logout user
  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    try {
      print('🚪 Logging out user...');
      
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.logoutUserEndpoint,
        requiresAuth: true,
      );

      if (response.success) {
        // Clear local auth token
        await _apiService.clearAuthToken();
        print('✅ Logout successful');
        return response;
      } else {
        print('❌ Failed to logout: ${response.error}');
        return response;
      }
    } catch (e) {
      print('❌ Error during logout: $e');
      return ApiResponse.error('Failed to logout: ${e.toString()}');
    }
  }

  // Get user orders
  Future<ApiResponse<Map<String, dynamic>>> getUserOrders() async {
    try {
      print('📦 Fetching user orders...');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.getAllOrdersOfUserEndpoint,
        requiresAuth: true,
      );

      if (response.success) {
        print('✅ Orders fetched successfully');
        return response;
      } else {
        print('❌ Failed to fetch orders: ${response.error}');
        return response;
      }
    } catch (e) {
      print('❌ Error fetching orders: $e');
      return ApiResponse.error('Failed to fetch orders: ${e.toString()}');
    }
  }
}
