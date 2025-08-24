import 'package:flutter/material.dart';

class SizeGuideScreen extends StatefulWidget {
  const SizeGuideScreen({super.key});

  @override
  State<SizeGuideScreen> createState() => _SizeGuideScreenState();
}

class _SizeGuideScreenState extends State<SizeGuideScreen> {
  bool _isShowCentimetersSize = false;

  void updateSizes() {
    setState(() {
      _isShowCentimetersSize = !_isShowCentimetersSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Size Guide'),
        actions: [
          TextButton(
            onPressed: updateSizes,
            child: Text(
              _isShowCentimetersSize ? 'Inches' : 'CM',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jewelry Size Guide',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Size table
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                children: [
                  // Header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Chest', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Waist', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Size rows
                  ..._getSizeData().map((sizeData) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(sizeData['size']!),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(_isShowCentimetersSize ? sizeData['chest_cm']! : sizeData['chest_in']!),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(_isShowCentimetersSize ? sizeData['waist_cm']! : sizeData['waist_in']!),
                      ),
                    ],
                  )).toList(),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'How to Measure',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            const Text(
              '• Chest: Measure around the fullest part of your chest\n'
              '• Waist: Measure around the narrowest part of your waist\n'
              '• For best results, have someone help you measure',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Map<String, String>> _getSizeData() {
    return [
      {'size': 'XS', 'chest_in': '32-34"', 'chest_cm': '81-86cm', 'waist_in': '24-26"', 'waist_cm': '61-66cm'},
      {'size': 'S', 'chest_in': '34-36"', 'chest_cm': '86-91cm', 'waist_in': '26-28"', 'waist_cm': '66-71cm'},
      {'size': 'M', 'chest_in': '36-38"', 'chest_cm': '91-97cm', 'waist_in': '28-30"', 'waist_cm': '71-76cm'},
      {'size': 'L', 'chest_in': '38-40"', 'chest_cm': '97-102cm', 'waist_in': '30-32"', 'waist_cm': '76-81cm'},
      {'size': 'XL', 'chest_in': '40-42"', 'chest_cm': '102-107cm', 'waist_in': '32-34"', 'waist_cm': '81-86cm'},
      {'size': 'XXL', 'chest_in': '42-44"', 'chest_cm': '107-112cm', 'waist_in': '34-36"', 'waist_cm': '86-91cm'},
    ];
  }
}
