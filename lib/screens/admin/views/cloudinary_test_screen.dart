import 'package:flutter/material.dart';
import '../services/cloudinary_service.dart';
import '../services/cloudinary_config.dart';

class CloudinaryTestScreen extends StatefulWidget {
  const CloudinaryTestScreen({Key? key}) : super(key: key);

  @override
  State<CloudinaryTestScreen> createState() => _CloudinaryTestScreenState();
}

class _CloudinaryTestScreenState extends State<CloudinaryTestScreen> {
  bool _isLoading = false;
  String _statusMessage = 'Ready to test Cloudinary connection';
  Color _statusColor = Colors.blue;

  Future<void> _testCloudinaryConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Cloudinary connection...';
      _statusColor = Colors.orange;
    });

    try {
      // First check if Cloudinary is configured
      if (!CloudinaryConfig.isConfigured) {
        setState(() {
          _statusMessage = '❌ Cloudinary not configured!\n\nPlease update CloudinaryConfig with your actual credentials:\n- Cloud Name\n- API Key\n- API Secret\n- Upload Preset';
          _statusColor = Colors.red;
          _isLoading = false;
        });
        return;
      }

      // Test connection
      print('🧪 Testing Cloudinary connection...');
      final isConnected = await CloudinaryService.testConnection();

      if (isConnected) {
        setState(() {
          _statusMessage = '✅ Cloudinary connection successful!\n\nConfiguration:\n- Cloud Name: ${CloudinaryConfig.cloudName}\n- API Key: ${CloudinaryConfig.apiKey.substring(0, 6)}...\n- Upload Preset: ${CloudinaryConfig.uploadPreset}';
          _statusColor = Colors.green;
        });
      } else {
        setState(() {
          _statusMessage = '❌ Cloudinary connection failed!\n\nPlease check:\n- Internet connection\n- Cloudinary credentials\n- Account status';
          _statusColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Connection test error:\n$e';
        _statusColor = Colors.red;
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
        title: const Text('Cloudinary Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cloudinary Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Cloud Name: ${CloudinaryConfig.cloudName}'),
                    Text('API Key: ${CloudinaryConfig.apiKey}'),
                    Text('Upload Preset: ${CloudinaryConfig.uploadPreset}'),
                    const SizedBox(height: 8),
                    Text(
                      CloudinaryConfig.isConfigured 
                          ? '✅ Configuration looks complete'
                          : '❌ Configuration incomplete - please update CloudinaryConfig',
                      style: TextStyle(
                        color: CloudinaryConfig.isConfigured ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testCloudinaryConnection,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud),
              label: Text(_isLoading ? 'Testing...' : 'Test Cloudinary Connection'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                              color: _statusColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!CloudinaryConfig.isConfigured) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🔧 Setup Instructions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Create a free account at cloudinary.com\n'
                        '2. Get your credentials from the dashboard\n'
                        '3. Update lib/services/cloudinary_config.dart\n'
                        '4. Replace placeholder values with your actual credentials',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
