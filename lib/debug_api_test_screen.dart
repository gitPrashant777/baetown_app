import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _result = 'Press button to test API';

  Future<void> _testGetProducts() async {
    try {
      final url = Uri.parse('https://mern-backend-t3h8.onrender.com/api/v1/products');
      print('🌐 Testing GET $url');
      
      final response = await http.get(url);
      print('📡 Response Status: ${response.statusCode}');
      print('📦 Response Body Length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final String resultText = '''
✅ Success! Status: ${response.statusCode}

📊 Response Structure:
- Type: ${data.runtimeType}
- Keys: ${data is Map ? data.keys.toList() : 'Not a Map'}

📦 Products Data:
- Products Key Exists: ${data['products'] != null}
- Products Type: ${data['products']?.runtimeType}
- Products Count: ${data['products'] is List ? data['products'].length : 'Not a List'}

📋 Raw Data (first 1000 chars):
${jsonEncode(data).substring(0, jsonEncode(data).length > 1000 ? 1000 : jsonEncode(data).length)}...

📈 Product Examples:
${_extractProductExamples(data)}
''';
        
        setState(() {
          _result = resultText;
        });
      } else {
        setState(() {
          _result = '❌ Error ${response.statusCode}: ${response.body}';
        });
      }
    } catch (e) {
      print('❌ Exception: $e');
      setState(() {
        _result = '💥 Exception: $e';
      });
    }
  }

  String _extractProductExamples(dynamic data) {
    try {
      if (data['products'] is List && (data['products'] as List).isNotEmpty) {
        final products = data['products'] as List;
        final examples = <String>[];
        
        for (int i = 0; i < products.length && i < 3; i++) {
          final product = products[i];
          examples.add('''
Product ${i + 1}:
  - ID: ${product['_id'] ?? product['id']}
  - Name: ${product['name'] ?? product['title']}
  - Price: ${product['price']}
  - Stock: ${product['stock'] ?? product['stockQuantity']}
  - Category: ${product['category']}
''');
        }
        return examples.join('\n');
      } else {
        return 'No products found or products is not a list';
      }
    } catch (e) {
      return 'Error extracting examples: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _testGetProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Test GET /products'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
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
