import 'package:flutter/material.dart';
import 'package:shop/components/Banner/S/banner_s_style_1.dart';
import 'package:shop/components/Banner/S/banner_s_style_5.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Hero Banner - MIDNIGHT LOTION style
            const SliverToBoxAdapter(child: OffersCarouselAndCategories()),

            // NOUVEAUTÉS - 2-row horizontal grid
            const SliverToBoxAdapter(child: MostPopular()),

            // ROUTINES VISAGE - Flash Sale section
            SliverPadding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width < 600
                    ? defaultPadding
                    : defaultPadding * 1.1,
              ),
              sliver: const SliverToBoxAdapter(child: FlashSale()),
            ),

            // Feature Banner with subtle styling
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BannerSStyle5(
                    title: ' ',
                    subtitle: "",
                    bottomText: " 50% Off SALE".toUpperCase(),
                    press: () {
                      Navigator.pushNamed(context, onSaleScreenRoute);
                    },
                  ),
                ),

              ),
            ),


            // LE TEINT - Best Sellers
            const SliverToBoxAdapter(child: BestSellers()),

            // Second Feature Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 600
                      ? defaultPadding / 2
                      : defaultPadding,
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BannerSStyle1(
                      title: "",
                      subtitle: "SPECIAL OFFER",
                      discountParcent: 25,
                      press: () {
                        Navigator.pushNamed(context, onSaleScreenRoute);
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Additional Best Sellers
            const SliverToBoxAdapter(child: PopularProducts()),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding * 3),
            ),
          ],
        ),
      ),
    );
  }
}
