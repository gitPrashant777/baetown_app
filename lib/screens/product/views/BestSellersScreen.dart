import 'package:flutter/material.dart';
import 'package:shop/services/products_api_service.dart';

import 'ProductListScreen.dart';

class BestSellersScreen extends StatelessWidget {
  const BestSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ProductsApiService();

    return ProductListScreen(
      title: "Best Sellers",
      productFetcher: apiService.getBestSellers,
    );
  }
}