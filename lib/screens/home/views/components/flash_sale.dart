import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/products_api_service.dart';

import '/components/Banner/M/banner_m_with_counter.dart';
import '../../../../components/product/product_card.dart';
import '../../../../constants.dart';
import '../../../../models/product_model.dart';

class FlashSale extends StatefulWidget {
  const FlashSale({
    super.key,
  });

  @override
  State<FlashSale> createState() => _FlashSaleState();
}

class _FlashSaleState extends State<FlashSale> {
  final ProductsApiService _apiService = ProductsApiService();
  List<ProductModel> _flashSaleProducts = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchFlashSaleProducts();
  }

  Future<void> _fetchFlashSaleProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final allProducts = await _apiService.getAllProducts();
      
      // Filter products that are marked as flash sale
      final flashSaleProducts = allProducts.where((product) => 
        product.isFlashSale == true
      ).toList();

      // If no products are marked as flash sale, show products with discounts
      if (flashSaleProducts.isEmpty && allProducts.isNotEmpty) {
        final discountedProducts = allProducts.where((product) => 
          product.priceAfetDiscount != null && product.priceAfetDiscount! < product.price
        ).toList();
        _flashSaleProducts = discountedProducts.take(6).toList();
      } else {
        _flashSaleProducts = flashSaleProducts.take(6).toList();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching flash sale products: $e');
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
        // While loading show 👇
        // const BannerMWithCounterSkelton(),
        BannerMWithCounter(
          duration: const Duration(hours: 8),
          text: "Jewelry Flash Sale \n40% Off",
          press: () {},
        ),
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Flash sale",
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
                    onPressed: _fetchFlashSaleProducts,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          )
        else if (_flashSaleProducts.isEmpty)
          SizedBox(
            height: listHeight,
            child: Center(
              child: Text(
                "No flash sale products available",
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
              itemCount: _flashSaleProducts.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  left: defaultPadding,
                  right: index == _flashSaleProducts.length - 1
                      ? defaultPadding
                      : 0,
                ),
                child: SizedBox(
                  width: screenWidth < 600 ? 130 : 140,
                  child: ProductCard(
                    image: _flashSaleProducts[index].image,
                    brandName: _flashSaleProducts[index].brandName ?? "BAETOWN",
                    title: _flashSaleProducts[index].title,
                    price: _flashSaleProducts[index].price,
                    priceAfetDiscount: _flashSaleProducts[index].priceAfetDiscount,
                    dicountpercent: _flashSaleProducts[index].dicountpercent,
                    product: _flashSaleProducts[index],
                    press: () {
                      Navigator.pushNamed(context, productDetailsScreenRoute,
                          arguments: _flashSaleProducts[index]);
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
