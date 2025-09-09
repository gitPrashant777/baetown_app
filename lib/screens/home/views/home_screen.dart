import 'package:flutter/material.dart';
import 'package:shop/components/Banner/S/banner_s_style_1.dart';
import 'package:shop/components/Banner/S/banner_s_style_5.dart';
import 'package:shop/components/free_delivery_banner.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';

import 'components/best_sellers.dart';
import 'components/flash_sale.dart';
import 'components/most_popular.dart';
import 'components/offer_carousel_and_categories.dart';
import 'components/popular_products.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: FreeDeliveryBanner()),
            const SliverToBoxAdapter(child: OffersCarouselAndCategories()),
            const SliverToBoxAdapter(child: PopularProducts()),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width < 600 
                  ? defaultPadding 
                  : defaultPadding * 1.5
              ),
              sliver: const SliverToBoxAdapter(child: FlashSale()),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // While loading use 👇
                  // const BannerMSkelton(),‚
                  BannerSStyle1(
                    title: "Bridal \nCollection",
                    subtitle: "SPECIAL OFFER",
                    discountParcent: 50,
                    press: () {
                      Navigator.pushNamed(context, onSaleScreenRoute);
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                  // We have 4 banner styles, all in the pro version
                ],
              ),
            ),
            const SliverToBoxAdapter(child: BestSellers()),
            const SliverToBoxAdapter(child: MostPopular()),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 600 
                    ? defaultPadding / 2 
                    : 0
                ),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.width < 600 
                      ? defaultPadding 
                      : defaultPadding * 1.5),
                    const SizedBox(height: defaultPadding / 4),
                    // While loading use 👇
                    // const BannerSSkelton(),
                    BannerSStyle5(
                      title: "GOLD \nSALE",
                      subtitle: "50% Off",
                      bottomText: "Collection".toUpperCase(),
                      press: () {
                        Navigator.pushNamed(context, onSaleScreenRoute);
                      },
                    ),
                    const SizedBox(height: defaultPadding / 4),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: BestSellers()),
            // Add some bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding * 2),
            ),
          ],
        ),
      ),
    );
  }
}
