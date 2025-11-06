// lib/screens/cart/views/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/services/cart_wishlist_api_service.dart';
import 'package:shop/models/cart_item_model.dart';
import 'package:shop/services/payment_service.dart';
import 'package:shop/constants.dart';

import '../../../services/orders_api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // ... (initState, dispose, and _processPayment are unchanged) ...
  late OrdersApiService _ordersApi;

  @override
  void initState() {
    super.initState();
    _ordersApi = Provider.of<OrdersApiService>(context, listen: false);
    final cartApi = Provider.of<CartApiService>(context, listen: false);

    PaymentService.initialize(
      context: context,
      ordersApi: _ordersApi,
      cartApi: cartApi,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartService>(context, listen: false).fetchCart();
    });
  }

  @override
  void dispose() {
    PaymentService.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    final cartService = Provider.of<CartService>(context, listen: false);
    if (cartService.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty!'), backgroundColor: Colors.red),
      );
      return;
    }
    final Map<String, dynamic> shippingInfo = {
      "address": "123 Test Street", "city": "Test City", "state": "Test State",
      "country": "India", "pinCode": 110001, "phoneNo": 9999999999,
    };
    final totalAmount = cartService.totalPrice;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Creating your order...'),
            ],
          ),
        );
      },
    );
    try {
      final String? razorpayKey = await _ordersApi.getRazorpayKey();
      if (razorpayKey == null) throw Exception('Failed to get Razorpay key.');
      final orderData = await _ordersApi.createRazorpayOrder(totalAmount);
      if (orderData == null || orderData['id'] == null) {
        throw Exception('Failed to create order on backend.');
      }
      final String razorpayOrderId = orderData['id'];
      final double serverAmount = (orderData['amount'] as num).toDouble() / 100.0;
      Navigator.of(context).pop();
      PaymentService.startPayment(
        key: razorpayKey,
        amount: serverAmount,
        orderId: razorpayOrderId,
        cartItems: cartService.items,
        shippingInfo: shippingInfo,
        customerName: 'Customer',
        customerEmail: 'customer@example.com',
        customerContact: '9999999999',
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }
// Add this method inside your _CartScreenState class

  void _showClearCartDialog(BuildContext context, CartService cartService) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Clear Cart'),
          ],
        ),
        content: const Text('Are you sure you want to remove all items from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // This is the same logic as before, just inside the helper method
              final bool success = await cartService.clearCart();

              Navigator.pop(dialogContext); // Close the dialog

              // Show a message
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cart cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to clear cart'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        final cartItems = cartService.items;
        final isLoading = cartService.isLoading;

        return Scaffold(
          appBar: AppBar(
            title: Text('Cart (${cartItems.length})'),
            actions: [
              if (cartItems.isNotEmpty)
                IconButton(
                  onPressed: () => _showClearCartDialog(context, cartService),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          body: isLoading && cartItems.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : cartItems.isEmpty
              ? const Center(
            // ... (Empty cart UI is unchanged) ...
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
                SizedBox(height: 16),
                Text('Your Cart is Empty', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Add items to your cart to see them here', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          )
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];

                    return Container(
                      // ... (Item container UI is unchanged) ...
                      margin: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(defaultBorderRadious),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // ... (Image and Text details are unchanged) ...
                          if (cartItem.product.images.isNotEmpty && cartItem.product.images.first.isNotEmpty)
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: NetworkImageWithLoader(
                                cartItem.product.images.first,
                                radius: defaultBorderRadious,
                              ),
                            ),
                          const SizedBox(width: defaultPadding),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cartItem.product.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(cartItem.product.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('Category: ${cartItem.product.category}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('₹${cartItem.product.priceAfetDiscount ?? cartItem.product.price}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor, fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // --- DECREMENT BUTTON LOGIC ---
                                          IconButton(
                                            onPressed: () async {
                                              if (cartItem.quantity > 1) {
                                                String? cartItemId = cartItem.cartItemId;
                                                String? productId = cartItem.product.productId;
                                                if (cartItemId == null || productId == null) {
                                                  print("❌ Invalid ID");
                                                  return;
                                                }
                                                // --- FIX: Pass both IDs ---
                                                await cartService.updateQuantity(
                                                  cartItemId: cartItemId,
                                                  productId: productId,
                                                  newQuantity: cartItem.quantity - 1,
                                                );
                                              }
                                            },
                                            icon: const Icon(Icons.remove, size: 20),
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: Text('${cartItem.quantity}', style: Theme.of(context).textTheme.titleMedium),
                                          ),
                                          // --- INCREMENT BUTTON LOGIC ---
                                          IconButton(
                                            onPressed: () async {
                                              final maxAllowed = cartItem.product.getMaxAllowedQuantity();
                                              if (cartItem.quantity < maxAllowed) {
                                                String? cartItemId = cartItem.cartItemId;
                                                String? productId = cartItem.product.productId;
                                                if (cartItemId == null || productId == null) {
                                                  print("❌ Invalid ID");
                                                  return;
                                                }
                                                // --- FIX: Pass both IDs ---
                                                await cartService.updateQuantity(
                                                  cartItemId: cartItemId,
                                                  productId: productId,
                                                  newQuantity: cartItem.quantity + 1,
                                                );
                                              }
                                            },
                                            icon: const Icon(Icons.add, size: 20),
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                          ),
                                          // --- REMOVE BUTTON LOGIC ---
                                          IconButton(
                                            onPressed: () async {
                                              String? cartItemId = cartItem.cartItemId;
                                              String? productId = cartItem.product.productId;
                                              print("🗑️ Attempting to remove cart item with ID: $cartItemId, product ID: $productId");

                                              if (cartItemId == null || productId == null) {
                                                print("❌ Invalid ID");
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Error: Could not find item ID'), backgroundColor: Colors.red),
                                                );
                                                return;
                                              }

                                              // --- FIX: Pass both IDs ---
                                              await cartService.removeFromCart(
                                                cartItemId: cartItemId,
                                                productId: productId,
                                              );
                                            },
                                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Cart Summary
              Container(
                // ... (Cart summary UI is unchanged) ...
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total (${cartItems.length} items)', style: Theme.of(context).textTheme.titleMedium),
                          Text('₹${cartService.totalPrice.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: primaryColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: defaultPadding),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                              : const Text('Proceed to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}