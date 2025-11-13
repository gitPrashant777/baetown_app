import 'package:flutter/material.dart';
import 'package:shop/services/products_api_service.dart';

import 'ProductListScreen.dart';

class FlashSaleScreen extends StatelessWidget {
  const FlashSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ProductsApiService();

    return ProductListScreen(
      title: "Flash Sale",
      productFetcher: apiService.getFlashSaleProducts,
    );
  }
}