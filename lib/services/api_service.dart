import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  // Get auth token from storage
  Future<String?> getAuthToken() async {
    if (_authToken != null) return _authToken;
    
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    return _authToken;
  }

  // Set auth token
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear auth token
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = await _getHeaders(requiresAuth);

      print('🌐 GET ${uri.toString()}');
      print('📋 Headers: ${headers.keys.map((k) => k == 'Authorization' ? '$k: Bearer ***' : '$k: ${headers[k]}').join(', ')}');

      final response = await http.get(uri, headers: headers);
      
      // Log response details for debugging
      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      
      return _handleResponse<T>(response);
    } catch (e) {
      print('❌ Network error in GET: ${e.toString()}');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final finalHeaders = await _getHeaders(requiresAuth);
      
      // Add additional headers if provided
      if (headers != null) {
        finalHeaders.addAll(headers);
      }

      print('🌐 POST ${uri.toString()}');
      print('📋 Headers: ${finalHeaders.entries.map((e) => '${e.key}: ${e.value}').join(', ')}');
      print('📦 Body: ${body != null ? jsonEncode(body) : 'null'}');

      final response = await http.post(
        uri,
        headers: finalHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final finalHeaders = await _getHeaders(requiresAuth);
      
      // Add additional headers if provided
      if (headers != null) {
        finalHeaders.addAll(headers);
      }

      final response = await http.put(
        uri,
        headers: finalHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final finalHeaders = await _getHeaders(requiresAuth);
      
      // Add additional headers if provided
      if (headers != null) {
        finalHeaders.addAll(headers);
      }

      final response = await http.delete(uri, headers: finalHeaders);
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Custom URL POST method for testing different base URLs
  Future<ApiResponse<T>> postToCustomUrl<T>(
    String fullUrl, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse(fullUrl);
      final headers = await _getHeaders(requiresAuth);

      final response = await http.post(
        uri, 
        headers: headers, 
        body: jsonEncode(body)
      );
      
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Custom URL GET method for testing different base URLs
  Future<ApiResponse<T>> getFromCustomUrl<T>(
    String fullUrl, {
    Map<String, String>? queryParams,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse(fullUrl).replace(queryParameters: queryParams);
      final headers = await _getHeaders(requiresAuth);

      print('🌐 GET ${uri.toString()}');
      print('📋 Headers: ${headers.keys.map((k) => k == 'Authorization' ? '$k: Bearer ***' : '$k: ${headers[k]}').join(', ')}');

      final response = await http.get(uri, headers: headers);
      
      // Log response details for debugging
      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      
      return _handleResponse<T>(response);
    } catch (e) {
      print('❌ Network error in custom GET: ${e.toString()}');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Build URI with query parameters
  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final url = '${ApiConfig.currentBaseUrl}$endpoint';
    return Uri.parse(url).replace(queryParameters: queryParams);
  }

  // Get headers based on auth requirement
  Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    if (requiresAuth) {
      final token = await getAuthToken();
      if (token != null) {
        print('🔑 Using auth token for request: ${token.substring(0, 30)}...');
        
        // Try to decode JWT token to see what's inside
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            // Decode the payload (middle part)
            String payload = parts[1];
            
            // Add padding if necessary for base64 decoding
            switch (payload.length % 4) {
              case 1:
                payload += '===';
                break;
              case 2:
                payload += '==';
                break;
              case 3:
                payload += '=';
                break;
            }
            
            final decoded = utf8.decode(base64.decode(payload));
            print('🔍 JWT Payload: $decoded');
            
            // Parse and show specific claims
            final payloadJson = jsonDecode(decoded);
            print('🆔 User ID: ${payloadJson['id'] ?? 'N/A'}');
            print('👤 Role: ${payloadJson['role'] ?? 'N/A'}');
            print('� Email: ${payloadJson['email'] ?? 'N/A'}');
            print('⏰ Issued At: ${payloadJson['iat'] ?? 'N/A'}');
            print('⏰ Expires At: ${payloadJson['exp'] ?? 'N/A'}');
            
            // Check if token is expired
            if (payloadJson['exp'] != null) {
              final exp = payloadJson['exp'];
              final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
              if (exp < now) {
                print('⚠️ JWT Token is EXPIRED!');
              } else {
                print('✅ JWT Token is valid (expires in ${exp - now} seconds)');
              }
            }
          }
        } catch (e) {
          print('⚠️ Could not decode JWT: $e');
        }
        
        return ApiConfig.getAuthHeaders(token);
      } else {
        print('❌ No auth token found for authenticated request!');
      }
    }
    return ApiConfig.headers;
  }

  // Handle HTTP response
  ApiResponse<T> _handleResponse<T>(http.Response response) {
    try {
      print('📡 API Response: ${response.statusCode} - ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}');
      
      final dynamic data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(data);
      } else {
        final message = data['message'] ?? 'API Error: ${response.statusCode}';
        print('❌ API Error: $message');
        return ApiResponse.error(message, statusCode: response.statusCode);
      }
    } catch (e) {
      print('❌ JSON Parse Error: ${e.toString()}');
      return ApiResponse.error('Failed to parse response: ${e.toString()}');
    }
  }
}

// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse._({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data) => ApiResponse._(
    success: true,
    data: data,
  );

  factory ApiResponse.error(String error, {int? statusCode}) => ApiResponse._(
    success: false,
    error: error,
    statusCode: statusCode,
  );
}
