import 'package:flutter/material.dart';

import '../../../constants.dart';

class OnSaleScreen extends StatelessWidget {
  const OnSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jewelry Sale'),
      ),
      // 1. Add padding around the card
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Center(
          // 2. Wrap content in a Container
          child: Container(
            padding: const EdgeInsets.all(defaultPadding * 1.5), // Inner padding
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // Or Colors.white
              // 3. Add rounded corners
              borderRadius: BorderRadius.circular(defaultBorderRadious),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Make column fit content
              children: [
                Icon(
                  Icons.local_offer,
                  size: 100,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Jewelry On Sale',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Amazing discounts on premium jewelry!',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}