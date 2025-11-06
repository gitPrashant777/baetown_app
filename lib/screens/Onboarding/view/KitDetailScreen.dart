// lib/screens/Onboarding/view/kit_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:shop/models/SavedKitModel.dart';
import 'package:shop/models/product_model.dart'; // Import your ProductModel

class KitDetailScreen extends StatelessWidget {
  final SavedKitModel kit;

  // Base URL for images, same as in your assessment screen
  final String _imageBaseUrl = "https://mern-backend-t3h8.onrender.com";

  const KitDetailScreen({super.key, required this.kit});

  // Helper to build correct image URLs
  String _buildProductImageUrl(ProductModel product) {
    String imageUrl = product.image;
    if (imageUrl.isEmpty && product.images.isNotEmpty) {
      imageUrl = product.images.first;
    } else if (imageUrl.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    if (imageUrl.startsWith('http')) return imageUrl;
    if (imageUrl.startsWith('/')) return '$_imageBaseUrl$imageUrl';
    return '$_imageBaseUrl/$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(kit.kitName, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Diagnosis Card
              _buildDiagnosisCard(context),
              const SizedBox(height: 24),

              // 2. Products List
              Text(
                "Products in this Kit",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Build a list of product cards
              ...kit.products.map(
                    (product) => _buildProductCard(context, product),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the Diagnosis Card
  Widget _buildDiagnosisCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Diagnosis",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            kit.diagnosis,
            style: TextStyle(
              fontSize: 15,
              color: Colors.blue[800],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Assessed on ${kit.assessmentDate}",
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for a single Product Card
  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final imageUrl = _buildProductImageUrl(product);
    final finalPrice = (product.priceAfetDiscount ?? product.price);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: Icon(Icons.shopping_bag_outlined, color: Colors.grey[600]),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  "₹${finalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}