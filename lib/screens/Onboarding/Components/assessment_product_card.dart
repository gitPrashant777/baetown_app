import 'package:flutter/material.dart';
// Adjust this path if your assessment_report.dart file is elsewhere
import '../../../models/assessment_report.dart';

// Note the new class name: AssessmentProductCard
class AssessmentProductCard extends StatelessWidget {
  final RecommendedProduct product;
  const AssessmentProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    bool isFree = product.discountedPrice.toUpperCase() == "FREE";

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Product Image Placeholder
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            // Add your asset images here
            child: Image.asset(product.imageUrl, fit: BoxFit.contain),
          ),
          const SizedBox(width: 16),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (product.tag.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildTag(product.tag),
                ],
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                // Price
                Row(
                  children: [
                    Text(
                      isFree ? "" : "₹${product.discountedPrice}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "₹${product.price}",
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    if (isFree) ...[
                      const SizedBox(width: 8),
                      Text(
                        "FREE",
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  // Helper for the small orange/yellow tag
  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: Colors.orange[800],
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}