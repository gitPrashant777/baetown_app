import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/free_delivery_banner.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/services/products_api_service.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/screen_export.dart';

import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import '../../../components/review_card.dart';
import 'product_buy_now_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductsApiService _productsApi = ProductsApiService();

  @override
  void initState() {
    super.initState();
    print('🔍 ProductDetailsScreen initialized with product: ${widget.product.productId}');
    print('🔍 Product title: ${widget.product.title}');
    print('🔍 Product images: ${widget.product.images}');
    print('🔍 Product description: ${widget.product.description}');
    print('🔍 Product stock: ${widget.product.stockQuantity}');
  }

  bool get isProductAvailable => !widget.product.isOutOfStock && widget.product.stockQuantity > 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CartButton(
        price: widget.product.priceAfetDiscount ?? widget.product.price,
        press: () {
          customModalBottomSheet(
            context,
            height: MediaQuery.of(context).size.height * 0.92,
            child: ProductBuyNowScreen(product: widget.product),
          );
        },
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).textTheme.bodyLarge!.color!,
                          BlendMode.srcIn)),
                ),
              ],
            ),
            ProductImages(
              images: widget.product.images.isNotEmpty 
                  ? widget.product.images // Use actual product images array
                  : [productDemoImg1, productDemoImg2, productDemoImg3], // Fallback
            ),
            ProductInfo(
              brand: widget.product.brandName ?? "Unknown Brand",
              title: widget.product.title ?? "Product Title",
              isAvailable: isProductAvailable,
              description: widget.product.description ?? "No description available",
              rating: 4.3,
              numOfReviews: 125,
              stockQuantity: widget.product.stockQuantity,
            ),
            ProductListTile(
              svgSrc: "assets/icons/Delivery.svg",
              title: "Free Delivery",
              subtitle: "On orders over \$35.00",
            ),
            if (isProductAvailable)
              ProductListTile(
                svgSrc: "assets/icons/Return.svg",
                title: "Return policy",
                subtitle: "99 days return period",
                isShowBottomBorder: true,
                press: () {
                  // Navigate to returns screen when available
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: defaultPadding)),
            if (!isProductAvailable)
              SliverToBoxAdapter(child: NotifyMeCard(onChanged: (value) {})),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              sliver: SliverToBoxAdapter(
                child: FreeDeliveryBanner(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: defaultPadding * 2)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "You may also like",
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: defaultPadding)),
            SliverToBoxAdapter(
              child: FutureBuilder<List<ProductModel>>(
                future: _productsApi.getAllProducts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // Show related products (excluding current product)
                    final relatedProducts = snapshot.data!
                        .where((p) => p.productId != widget.product.productId)
                        .take(4)
                        .toList();
                    
                    return SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedProducts.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(
                            left: defaultPadding,
                            right: index == relatedProducts.length - 1 ? defaultPadding : 0,
                          ),
                          child: ProductCard(
                            image: relatedProducts[index].image,
                            brandName: relatedProducts[index].brandName ?? "BAETOWN",
                            title: relatedProducts[index].title,
                            price: relatedProducts[index].price,
                            priceAfetDiscount: relatedProducts[index].priceAfetDiscount,
                            dicountpercent: relatedProducts[index].dicountpercent,
                            press: () {
                              Navigator.pushNamed(
                                context,
                                productDetailsScreenRoute,
                                arguments: relatedProducts[index],
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: defaultPadding)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reviews",
                      style: Theme.of(context).textTheme.titleSmall!,
                    ),
                    const SizedBox(height: defaultPadding),
                    ...List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: defaultPadding),
                        child: Container(
                          padding: const EdgeInsets.all(defaultPadding),
                          decoration: BoxDecoration(
                            color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.035),
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "⭐⭐⭐⭐⭐",
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const Spacer(),
                                  Text(
                                    "4 days ago",
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Esther Howard",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Love it! Super fast shipping and exactly as described. Will definitely order from this seller again!",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}