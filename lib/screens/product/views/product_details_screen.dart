import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart'; // <-- 1. IMPORT PROVIDER
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/free_delivery_banner.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/services/products_api_service.dart';
import 'package:shop/services/cart_wishlist_api_service.dart';
// import 'package:shop/services/api_config.dart'; // Unused
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
  // --- 2. REMOVE local API instances ---
  // final CartApiService _cartApi = CartApiService(); // <-- DELETED
  // final WishlistApiService _wishlistApi = WishlistApiService(); // <-- DELETED

  // --- 3. ADD service variables (will be initialized in initState) ---
  late CartApiService _cartApi;
  late WishlistApiService _wishlistApi;
  late CartService _cartService;

  // This one can stay as it doesn't need auth
  final ProductsApiService _productsApi = ProductsApiService();

  bool _isInWishlist = false;
  // bool _isAddingToCart = false; // No longer needed, CartService handles this
  double _reviewRating = 5.0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmittingReview = false;

  // TODO: Replace with actual user ID from auth logic
  final String currentUserId = "CURRENT_USER_ID";

  @override
  void initState() {
    super.initState();

    // --- 4. INITIALIZE services from Provider ---
    // Use listen: false because we are in initState
    _cartApi = Provider.of<CartApiService>(context, listen: false);
    _wishlistApi = Provider.of<WishlistApiService>(context, listen: false);
    _cartService = Provider.of<CartService>(context, listen: false);

    _checkWishlist();
    print('🔍 ProductDetailsScreen initialized with product: ${widget.product.productId}');
    print('🔍 Product title: ${widget.product.title}');
    print('🔍 Product images: ${widget.product.images}');
    print('🔍 Product description: ${widget.product.description}');
    print('🔍 Product stock: ${widget.product.stockQuantity}');
  }

  Future<void> deleteReview(String reviewId) async {
    final productId = widget.product.productId ?? '';
    final result = await _productsApi.deleteReview(productId, reviewId);
    if (result['success'] == true) {
      setState(() {}); // Refresh reviews
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review deleted successfully'), backgroundColor: pinkColor),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete review'), backgroundColor: errorColor),
      );
    }
  }

  Future<void> submitReview() async {
    setState(() => _isSubmittingReview = true);
    final productId = widget.product.productId ?? '';
    final result = await _productsApi.submitReview(
      productId,
      _reviewRating,
      _reviewController.text.trim(),
    );
    setState(() => _isSubmittingReview = false);
    if (result['success'] == true) {
      _reviewController.clear();
      setState(() {}); // Refresh reviews
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted!'), backgroundColor: pinkColor),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review'), backgroundColor: errorColor),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchReviews() async {
    final productId = widget.product.productId ?? '';
    return await _productsApi.fetchReviews(productId);
  }

  Future<void> _checkWishlist() async {
    final productId = widget.product.productId ?? '';
    final isWish = await _wishlistApi.isInWishlist(productId);
    setState(() {
      _isInWishlist = isWish;
    });
  }

  Future<void> _toggleWishlist() async {
    final productId = widget.product.productId ?? '';
    if (_isInWishlist) {
      await _wishlistApi.removeFromWishlist(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from wishlist'), backgroundColor: errorColor),
      );
    } else {
      await _wishlistApi.addToWishlist(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to wishlist'), backgroundColor: pinkColor),
      );
    }
    _checkWishlist();
  }

  // --- 5. MODIFY _addToCart to use CartService ---
  Future<void> _addToCart() async {
    // We already have _cartService from initState
    await _cartService.addToCart(widget.product, quantity: 1);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added to cart!'), backgroundColor: pinkColor),
    );
  }

  // --- 6. NEW "Buy Now" method ---
  Future<void> _buyNow() async {
    // 1. Add item to cart
    await _cartService.addToCart(widget.product, quantity: 1);

    // 2. Navigate to cart screen
    if (mounted) {
      Navigator.pushNamed(context, cartScreenRoute);
    }
  }

  bool get isProductAvailable => !widget.product.isOutOfStock && widget.product.stockQuantity > 0;

  @override
  Widget build(BuildContext context) {
    // --- 7. LISTEN to CartService for loading state ---
    final bool isCartLoading = context.watch<CartService>().isLoading;

    return Scaffold(
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: pinkColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              // --- 8. Use isCartLoading ---
              onPressed: isCartLoading ? null : _addToCart,
              child: isCartLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Add to Cart', style: TextStyle(color: Colors.white)),
            ),
          ),
          Expanded(
            child: CartButton(
              price: widget.product.priceAfetDiscount ?? widget.product.price,
              press: () {
                // --- 9. "Buy Now" can use the modal OR navigate ---
                // Option A: Use the Modal (your original code)
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: ProductBuyNowScreen(product: widget.product),
                );

                // Option B: Use the Buy Now logic I created
                // if (!isCartLoading) {
                //   _buyNow();
                // }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                IconButton(
                  onPressed: _toggleWishlist,
                  icon: SvgPicture.asset(
                    "assets/icons/Heart.svg",
                    colorFilter: ColorFilter.mode(
                      _isInWishlist ? Colors.red : Theme.of(context).textTheme.bodyLarge!.color!,
                      BlendMode.srcIn,
                    ),
                  ),
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
              description: widget.product.description ?? "No description available",
              rating: 4.3,
              numOfReviews: 125,
              isAvailable: isProductAvailable,
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
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchReviews(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final reviews = snapshot.data ?? [];
                        print('Reviews type: ${reviews.runtimeType}');
                        if (reviews is! List) {
                          return Text('Error: Reviews data is not a List.');
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (reviews.isEmpty)
                              Text("No reviews yet.", style: Theme.of(context).textTheme.bodyMedium),
                            ...reviews.map((review) {
                              print('Review rating type: ${review['rating'].runtimeType}, value: ${review['rating']}');
                              return Padding(
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
                                          Row(
                                            children: (() {
                                              int ratingStars = 5;
                                              final ratingRaw = review['rating'];
                                              double? ratingValue;
                                              if (ratingRaw is num) {
                                                ratingValue = ratingRaw.toDouble();
                                              } else if (ratingRaw is String) {
                                                ratingValue = double.tryParse(ratingRaw);
                                              }
                                              if (ratingValue != null && ratingValue > 0 && ratingValue.isFinite && ratingValue < 100) {
                                                ratingStars = ratingValue.floor();
                                              }
                                              if (ratingStars <= 0 || ratingStars.isNaN || ratingStars > 100) ratingStars = 5;
                                              return List.generate(ratingStars, (i) => Icon(Icons.star, color: pinkColor, size: 16));
                                            })(),
                                          ),
                                          const Spacer(),
                                          Text(
                                            review['createdAt'] ?? '',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          if (review['user'] != null && (
                                              (review['user'] is Map && review['user']['_id'] == currentUserId) ||
                                                  (review['user'] is String && review['user'] == currentUserId)
                                          ))
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.pink, size: 20),
                                              tooltip: 'Delete review',
                                              onPressed: () async {
                                                await deleteReview(review['_id']);
                                              },
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        review['user'] != null &&
                                            (review['user'] is Map && review['user']['name'] != null)
                                            ? review['user']['name']
                                            : (
                                            (review['user'] != null && (
                                                (review['user'] is Map && review['user']['_id'] == currentUserId) ||
                                                    (review['user'] is String && review['user'] == currentUserId)
                                            ))
                                                ? "You"
                                                : "Anonymous"
                                        ),
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        review['comment'] ?? "",
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: defaultPadding * 2),
                            Text("Add your review", style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: defaultPadding),
                            Row(
                              children: List.generate(5, (i) => GestureDetector(
                                onTap: () => setState(() => _reviewRating = i + 1.0),
                                child: Icon(
                                  Icons.star,
                                  color: i < _reviewRating ? pinkColor : Colors.grey[300],
                                  size: 28,
                                ),
                              )),
                            ),
                            const SizedBox(height: defaultPadding),
                            TextField(
                              controller: _reviewController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Write your review...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: defaultPadding),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pinkColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: _isSubmittingReview ? null : submitReview,
                                child: _isSubmittingReview
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text("Submit Review", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        );
                      },
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