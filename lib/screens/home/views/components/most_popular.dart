import 'package:flutter/material.dart';
import 'package:shop/components/product/secondary_product_card.dart';
import 'package:shop/models/product_model.dart';

import '../../../../constants.dart';
import '../../../../route/route_constants.dart';

class MostPopular extends StatelessWidget {
  const MostPopular({
    super.key,
  });

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
        // While loading use 👇
        // SeconderyProductsSkelton(),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Find demoPopularProducts on models/ProductModel.dart
            itemCount: demoPopularProducts.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: defaultPadding,
                right: index == demoPopularProducts.length - 1
                    ? defaultPadding
                    : 0,
              ),
              child: SizedBox(
                width: screenWidth < 600 ? 230 : 256,
                child: SecondaryProductCard(
                  image: demoPopularProducts[index].image,
                  brandName: demoPopularProducts[index].brandName,
                  title: demoPopularProducts[index].title,
                  price: demoPopularProducts[index].price,
                  priceAfetDiscount: demoPopularProducts[index].priceAfetDiscount,
                  dicountpercent: demoPopularProducts[index].dicountpercent,
                  product: demoPopularProducts[index], // Pass the product model
                  press: () {
                    Navigator.pushNamed(context, productDetailsScreenRoute,
                        arguments: index.isEven);
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
