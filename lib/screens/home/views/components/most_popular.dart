import 'package:flutter/material.dart';
import 'package:shop/components/product/secondary_product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/products_api_service.dart';

import '../../../../constants.dart';
import '../../../../route/route_constants.dart';

class MostPopular extends StatefulWidget {
  const MostPopular({
    super.key,
  });

  @override
  State<MostPopular> createState() => _MostPopularState();
}

class _MostPopularState extends State<MostPopular> {
  final ProductsApiService _apiService = ProductsApiService();
  List<ProductModel> _mostPopularProducts = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchMostPopularProducts();
  }

  Future<void> _fetchMostPopularProducts() async {
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

      // If no products are marked as popular, show middle 6 products
      if (popularProducts.isEmpty && allProducts.isNotEmpty) {
        final startIndex = allProducts.length > 6 ? (allProducts.length ~/ 2) - 3 : 0;
        final endIndex = startIndex + 6;
        _mostPopularProducts = allProducts.skip(startIndex).take(endIndex - startIndex).toList();
      } else {
        _mostPopularProducts = popularProducts.take(6).toList();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching most popular products: $e');
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
    final listHeight = screenWidth < 600 ? 95.0 : 114.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Most popular",
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
                    onPressed: _fetchMostPopularProducts,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          )
        else if (_mostPopularProducts.isEmpty)
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
              itemCount: _mostPopularProducts.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  left: defaultPadding,
                  right: index == _mostPopularProducts.length - 1
                      ? defaultPadding
                      : 0,
                ),
                child: SizedBox(
                  width: screenWidth < 600 ? 230 : 256,
                  child: SecondaryProductCard(
                    image: _mostPopularProducts[index].image,
                    brandName: _mostPopularProducts[index].brandName ?? "BAETOWN",
                    title: _mostPopularProducts[index].title,
                    price: _mostPopularProducts[index].price,
                    priceAfetDiscount: _mostPopularProducts[index].priceAfetDiscount,
                    dicountpercent: _mostPopularProducts[index].dicountpercent,
                    product: _mostPopularProducts[index],
                    press: () {
                      Navigator.pushNamed(context, productDetailsScreenRoute,
                          arguments: _mostPopularProducts[index]);
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
