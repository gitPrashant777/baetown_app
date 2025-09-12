import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/views/added_to_cart_message_screen.dart';
import 'package:shop/screens/product/views/components/product_list_tile.dart';
import 'package:shop/screens/product/views/location_permission_store_availability_screen.dart';
import 'package:shop/screens/product/views/size_guide_screen.dart';
import 'package:shop/services/cart_service.dart';
import 'components/product_quantity.dart';
import 'components/selected_colors.dart';
import 'components/selected_size.dart';
import 'components/unit_price.dart';

class ProductBuyNowScreen extends StatefulWidget {
  const ProductBuyNowScreen({super.key, required this.product});

  final ProductModel product;

  @override
  _ProductBuyNowScreenState createState() => _ProductBuyNowScreenState();
}

class _ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  int quantity = 1;
  int selectedColorIndex = 2;
  int selectedSizeIndex = 1;
  final List<String> sizes = ["S", "M", "L", "XL", "XXL"];
  final List<Color> colors = [
    const Color(0xFFEA6262),
    const Color(0xFFB1CC63),
    const Color(0xFFFFBF5F),
    const Color(0xFF9FE1DD),
    const Color(0xFFC482DB),
  ];
  
  // Use the product passed from the details screen
  late ProductModel currentProduct;
  
  @override
  void initState() {
    super.initState();
    // Use the actual product passed from the previous screen
    currentProduct = widget.product;
  }
  
  double get totalPrice => (currentProduct.priceAfetDiscount ?? currentProduct.price) * quantity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CartButton(
        price: totalPrice,
        title: "Add to cart",
        subTitle: "Total price",
        press: () {
          // Add item to cart with selected options
          for (int i = 0; i < quantity; i++) {
            CartService().addToCart(currentProduct);
          }
          
          // Show success message
          customModalBottomSheet(
            context,
            isDismissible: false,
            child: const AddedToCartMessageScreen(),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 2, vertical: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(),
                Text(
                  currentProduct.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                _WishlistIconButton(),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: NetworkImageWithLoader(productDemoImg1),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UnitPrice(
                                price: currentProduct.price,
                                priceAfterDiscount: currentProduct.priceAfetDiscount,
                              ),
                              const SizedBox(height: defaultPadding / 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: defaultPadding / 2,
                                  vertical: defaultPadding / 4,
                                ),
                                decoration: BoxDecoration(
                                  color: currentProduct.stockQuantity > 10 
                                      ? Colors.green.withOpacity(0.1)
                                      : currentProduct.stockQuantity > 0
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: currentProduct.stockQuantity > 10 
                                        ? Colors.green
                                        : currentProduct.stockQuantity > 0
                                            ? Colors.orange
                                            : Colors.red,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  currentProduct.stockQuantity > 0 
                                      ? "Available: ${currentProduct.stockQuantity} units"
                                      : "Out of Stock",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: currentProduct.stockQuantity > 10 
                                        ? Colors.green
                                        : currentProduct.stockQuantity > 0
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ProductQuantity(
                          numOfItem: quantity,
                          onIncrement: () {
                            setState(() {
                              if (quantity < currentProduct.stockQuantity && 
                                  quantity < currentProduct.maxOrderQuantity) {
                                quantity++;
                              }
                            });
                          },
                          onDecrement: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Divider()),
                SliverToBoxAdapter(
                  child: SelectedColors(
                    colors: colors,
                    selectedColorIndex: selectedColorIndex,
                    press: (value) {
                      setState(() {
                        selectedColorIndex = value;
                      });
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: SelectedSize(
                    sizes: sizes,
                    selectedIndex: selectedSizeIndex,
                    press: (value) {
                      setState(() {
                        selectedSizeIndex = value;
                      });
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTile(
                    title: "Size guide",
                    svgSrc: "assets/icons/Sizeguid.svg",
                    isShowBottomBorder: true,
                    press: () {
                      customModalBottomSheet(
                        context,
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: const SizeGuideScreen(),
                      );
                    },
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          "Store pickup availability",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        const Text(
                            "Select a size to check store availability and In-Store pickup options.")
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTile(
                    title: "Check stores",
                    svgSrc: "assets/icons/Stores.svg",
                    isShowBottomBorder: true,
                    press: () {
                      customModalBottomSheet(
                        context,
                        height: MediaQuery.of(context).size.height * 0.92,
                        child: const LocationPermissonStoreAvailabilityScreen(),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: defaultPadding))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _WishlistIconButton extends StatefulWidget {
  @override
  _WishlistIconButtonState createState() => _WishlistIconButtonState();
}

class _WishlistIconButtonState extends State<_WishlistIconButton> {
  bool isInWishlist = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          isInWishlist = !isInWishlist;
        });
        // TODO: Add actual wishlist API call here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isInWishlist ? 'Added to wishlist' : 'Removed from wishlist',
            ),
            duration: Duration(milliseconds: 1000),
          ),
        );
      },
      icon: Icon(
        isInWishlist ? Icons.favorite : Icons.favorite_border,
        color: isInWishlist 
          ? Colors.red 
          : Theme.of(context).textTheme.bodyLarge!.color,
      ),
    );
  }
}
