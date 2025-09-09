import 'package:flutter/material.dart';
import 'package:shop/services/auth_api_service.dart';

class BackendTestScreen extends StatefulWidget {
  const BackendTestScreen({super.key});

  @override
  State<BackendTestScreen> createState() => _BackendTestScreenState();
}

class _BackendTestScreenState extends State<BackendTestScreen> {
  final AuthApiService _authApi = AuthApiService();
  String _testResults = 'Press buttons to test backend connection...';
  bool _isLoading = false;

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Testing login endpoint...';
    });

    try {
      final response = await _authApi.login(
        email: 'test@example.com',
        password: 'testpassword',
      );

      setState(() {
        if (response.success) {
          _testResults = '✅ Login endpoint working!\n'
                        'Response: ${response.data}\n'
                        'Status: Success';
        } else {
          _testResults = '❌ Login failed:\n'
                        'Error: ${response.error}\n'
                        'This is expected for invalid credentials, but confirms endpoint is reachable.';
        }
      });
    } catch (e) {
      setState(() {
        _testResults = '💥 Login test error:\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testRegister() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Testing register endpoint...';
    });

    try {
      final response = await _authApi.register(
        name: 'Test User',
        email: 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'testpassword123',
      );

      setState(() {
        if (response.success) {
          _testResults = '✅ Register endpoint working!\n'
                        'Response: ${response.data}\n'
                        'Status: Success';
        } else {
          _testResults = '❌ Register failed:\n'
                        'Error: ${response.error}\n'
                        'This might be expected if the endpoint requires different fields.';
        }
      });
    } catch (e) {
      setState(() {
        _testResults = '💥 Register test error:\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Connection Test'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Backend URL: https://mern-backend-t3h8.onrender.com',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              child: const Text('Test Login Endpoint'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testRegister,
              child: const Text('Test Register Endpoint'),
            ),
            const SizedBox(height: 20),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults,
                    style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
