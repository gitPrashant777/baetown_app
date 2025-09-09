// Test authentication endpoint
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthTest {
  static Future<void> testAuth() async {
    const String token = 'YOUR_JWT_TOKEN_HERE'; // Replace with actual token from logs
    const String baseUrl = 'https://mern-backend-t3h8.onrender.com/api/v1';
    
    // Test different profile endpoints
    final endpoints = [
      '/profile',
      '/me',
      '/user/profile',
      '/user/me',
    ];
    
    for (final endpoint in endpoints) {
      try {
        print('🧪 Testing endpoint: $endpoint');
        
        final response = await http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        
        print('📊 Status: ${response.statusCode}');
        print('📄 Response: ${response.body}');
        print('---');
        
      } catch (e) {
        print('❌ Error testing $endpoint: $e');
      }
    }
  }
}
