import 'package:flutter/material.dart';
import 'package:shop/models/product_model.dart';

import '../../constants.dart';
import '../network_image_with_loader.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
    required this.press,
    this.product, // Optional product model for cart functionality
  });
  final String image, brandName, title;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;
  final VoidCallback press;
  final ProductModel? product;

  @override
  Widget build(BuildContext context) {
    // Make card responsive based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 600 ? 130.0 : 140.0;
    final cardHeight = screenWidth < 600 ? 200.0 : 220.0;
    
    return OutlinedButton(
      onPressed: press,
      style: OutlinedButton.styleFrom(
          minimumSize: Size(cardWidth, cardHeight),
          maximumSize: Size(cardWidth, cardHeight),
          padding: const EdgeInsets.all(8)),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: Stack(
              children: [
                NetworkImageWithLoader(image, radius: defaultBorderRadious),
                if (dicountpercent != null)
                  Positioned(
                    right: defaultPadding / 2,
                    top: defaultPadding / 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding / 2),
                      height: 16,
                      decoration: const BoxDecoration(
                        color: errorColor,
                        borderRadius: BorderRadius.all(
                            Radius.circular(defaultBorderRadious)),
                      ),
                      child: Text(
                        "$dicountpercent% off",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding / 2, vertical: defaultPadding / 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brandName.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: screenWidth < 600 ? 8 : 9),
                  ),
                  const SizedBox(height: defaultPadding / 4),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontSize: screenWidth < 600 ? 10 : 11),
                  ),
                  const Spacer(),
                  priceAfetDiscount != null
                      ? Row(
                          children: [
                            Text(
                              "₹${priceAfetDiscount!.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: const Color(0xFF31B0D8),
                                fontWeight: FontWeight.w500,
                                fontSize: screenWidth < 600 ? 10 : 11,
                              ),
                            ),
                            const SizedBox(width: defaultPadding / 4),
                            Text(
                              "₹${price.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                                fontSize: screenWidth < 600 ? 8 : 9,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "₹${price.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: const Color(0xFF31B0D8),
                            fontWeight: FontWeight.w500,
                            fontSize: screenWidth < 600 ? 10 : 11,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
