import 'package:flutter/material.dart';

// import '../../../../constants.dart'; // No longer needed
// import 'categories.dart'; // No longer needed
import 'offers_carousel.dart';

class OffersCarouselAndCategories extends StatelessWidget {
  const OffersCarouselAndCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // While loading use 👇
        // const OffersSkelton(),
        OffersCarousel(),
        // SizedBox(height: defaultPadding / 2), // Removed
        // Padding( // Removed
        //   padding: const EdgeInsets.all(defaultPadding),
        //   child: Text(
        //     "Categories",
        //     style: Theme.of(context).textTheme.titleSmall,
        //   ),
        // ),
        // const Categories(), // Removed
      ],
    );
  }
}