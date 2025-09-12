import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/products_api_service.dart';

import '../../../../constants.dart';
import '../../../../route/route_constants.dart';

class BestSellers extends StatefulWidget {
  const BestSellers({
    super.key,
  });

  @override
  State<BestSellers> createState() => _BestSellersState();
}

class _BestSellersState extends State<BestSellers> {
  final ProductsApiService _apiService = ProductsApiService();
  List<ProductModel> _bestSellerProducts = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchBestSellerProducts();
  }

  Future<void> _fetchBestSellerProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final allProducts = await _apiService.getAllProducts();
      
      // Filter products that are marked as best sellers
      final bestSellerProducts = allProducts.where((product) => 
        product.isBestSeller == true
      ).toList();

      // If no products are marked as best sellers, show last 6 products
      if (bestSellerProducts.isEmpty && allProducts.isNotEmpty) {
        _bestSellerProducts = allProducts.skip(allProducts.length > 6 ? allProducts.length - 6 : 0).toList();
      } else {
        _bestSellerProducts = bestSellerProducts.take(6).toList();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching best seller products: $e');
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
            "Best sellers",
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
                    onPressed: _fetchBestSellerProducts,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          )
        else if (_bestSellerProducts.isEmpty)
          SizedBox(
            height: listHeight,
            child: Center(
              child: Text(
                "No best seller products available",
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
              itemCount: _bestSellerProducts.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  left: defaultPadding,
                  right: index == _bestSellerProducts.length - 1
                      ? defaultPadding
                      : 0,
                ),
                child: SizedBox(
                  width: screenWidth < 600 ? 130 : 140,
                  child: ProductCard(
                    image: _bestSellerProducts[index].image,
                    brandName: _bestSellerProducts[index].brandName ?? "BAETOWN",
                    title: _bestSellerProducts[index].title,
                    price: _bestSellerProducts[index].price,
                    priceAfetDiscount: _bestSellerProducts[index].priceAfetDiscount,
                    dicountpercent: _bestSellerProducts[index].dicountpercent,
                    product: _bestSellerProducts[index],
                    press: () {
                      Navigator.pushNamed(context, productDetailsScreenRoute,
                          arguments: _bestSellerProducts[index]);
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
