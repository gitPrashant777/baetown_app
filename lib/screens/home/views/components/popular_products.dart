import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/services/products_api_service.dart';

import '../../../../constants.dart';

class PopularProducts extends StatefulWidget {
  const PopularProducts({
    super.key,
  });

  @override
  State<PopularProducts> createState() => _PopularProductsState();
}

class _PopularProductsState extends State<PopularProducts> {
  final ProductsApiService _apiService = ProductsApiService();
  List<ProductModel> _popularProducts = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPopularProducts();
  }

  Future<void> _fetchPopularProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final allProducts = await _apiService.getAllProducts();
      
      // Filter products that are marked as popular
      final popularProducts = allProducts.where((product) => 
        product.isPopular == true
      ).toList();

      // If no products are marked as popular, show first 6 products
      if (popularProducts.isEmpty && allProducts.isNotEmpty) {
        _popularProducts = allProducts.take(6).toList();
      } else {
        _popularProducts = popularProducts.take(6).toList();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching popular products: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Make height responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final listHeight = screenWidth < 600 ? 200.0 : 220.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Popular products",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        if (_isLoading)
          SizedBox(
            height: listHeight,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_hasError)
          SizedBox(
            height: listHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    "Failed to load products",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _fetchPopularProducts,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          )
        else if (_popularProducts.isEmpty)
          SizedBox(
            height: listHeight,
            child: Center(
              child: Text(
                "No popular products available",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: listHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _popularProducts.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  left: defaultPadding,
                  right: index == _popularProducts.length - 1
                      ? defaultPadding
                      : 0,
                ),
                child: SizedBox(
                  width: screenWidth < 600 ? 130 : 140,
                  child: ProductCard(
                    image: _popularProducts[index].image,
                    brandName: _popularProducts[index].brandName ?? "BAETOWN",
                    title: _popularProducts[index].title,
                    price: _popularProducts[index].price,
                    priceAfetDiscount: _popularProducts[index].priceAfetDiscount,
                    dicountpercent: _popularProducts[index].dicountpercent,
                    product: _popularProducts[index],
                    press: () {
                      Navigator.pushNamed(context, productDetailsScreenRoute,
                          arguments: _popularProducts[index]);
                    },
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
