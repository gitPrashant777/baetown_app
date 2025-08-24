import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';

import '/components/Banner/M/banner_m_with_counter.dart';
import '../../../../components/product/product_card.dart';
import '../../../../constants.dart';
import '../../../../models/product_model.dart';

class FlashSale extends StatelessWidget {
  const FlashSale({
    super.key,
  });

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
        // While loading show 👇
        // const ProductsSkelton(),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Find demoFlashSaleProducts on models/ProductModel.dart
            itemCount: demoFlashSaleProducts.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: defaultPadding,
                right: index == demoFlashSaleProducts.length - 1
                    ? defaultPadding
                    : 0,
              ),
              child: SizedBox(
                width: screenWidth < 600 ? 130 : 140,
                child: ProductCard(
                  image: demoFlashSaleProducts[index].image,
                  brandName: demoFlashSaleProducts[index].brandName,
                  title: demoFlashSaleProducts[index].title,
                  price: demoFlashSaleProducts[index].price,
                  priceAfetDiscount:
                      demoFlashSaleProducts[index].priceAfetDiscount,
                  dicountpercent: demoFlashSaleProducts[index].dicountpercent,
                  product: demoFlashSaleProducts[index], // Pass the product model
                  press: () {
                    Navigator.pushNamed(context, productDetailsScreenRoute,
                        arguments: index.isEven);
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
