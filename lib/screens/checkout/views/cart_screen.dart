import 'package:flutter/material.dart';
import 'package:shop/components/cart_item_widget.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/services/cart_wishlist_api_service.dart';
import 'package:shop/models/cart_item_model.dart';
import 'package:shop/services/payment_service.dart';
import 'package:shop/constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartApiService _cartApi = CartApiService();
  List<dynamic> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  @override
  void dispose() {
    // Dispose Razorpay payment service
    PaymentService.dispose();
    super.dispose();
  }

  Future<void> _fetchCart() async {
    setState(() => _isLoading = true);
    try {
      final cartData = await _cartApi.getCart();
      setState(() {
        final rawCart = cartData?['cart'] ?? [];
        _cartItems = rawCart is List
            ? rawCart.map((item) => CartItem.fromJson(item)).toList()
            : [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching cart: $e');
      setState(() => _isLoading = false);
    }
  }

  // Helper function to get the product ID for API calls
  String? _getProductId(CartItem cartItem) {
    // Try common product ID field names - adjust based on your ProductModel
  return cartItem.product.productId ?? cartItem.cartItemId;
  }

  void _processPayment() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Initialize Razorpay with current context
    PaymentService.initialize(context);

    final totalAmount = _cartItems.fold(0.0, (sum, item) => sum + (item.totalPrice));
    final orderId = PaymentService.generateOrderId();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Processing payment...'),
            ],
          ),
        );
      },
    );

    // Close loading dialog after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pop(); // Close loading dialog
      
      // Start Razorpay payment
      PaymentService.startPayment(
        amount: totalAmount,
        orderId: orderId,
        customerName: 'Customer', // You can get this from user profile
        customerEmail: 'customer@example.com', // You can get this from user profile
        customerContact: '9999999999', // You can get this from user profile
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _cartItems;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart (${cartItems.length})'),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Are you sure you want to remove all items from cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Use the API to clear cart instead of just clearing the list
                          final success = await _cartApi.clearCart();
                          if (success) {
                            setState(() {
                              _cartItems.clear();
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cart cleared successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to clear cart'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 100,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Your Cart is Empty',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add items to your cart to see them here',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
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
                          final productId = cartItem.product.productId;
                          return CartItemWidget(
                            cartItem: cartItem,
                            index: index,
                            onRemove: () async {
                              print('DEBUG: cartItem.product.productId = ${cartItem.product.productId}, cartItem.cartItemId = ${cartItem.cartItemId}');
                              String? idToDelete = productId;
                              if (idToDelete == null || idToDelete.isEmpty) {
                                print('Warning: productId missing, falling back to cartItemId');
                                idToDelete = cartItem.cartItemId;
                              }
                              if (idToDelete == null || idToDelete.isEmpty) {
                                print('Error: No valid ID found for removal');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Unable to remove item - invalid ID'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              print('Removing item with ID: $idToDelete');
                              final success = await _cartApi.removeFromCart(idToDelete);
                              if (success) {
                                await _fetchCart(); // Refresh the cart
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Item removed from cart'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to remove item'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            onUpdateQuantity: (newQuantity) async {
                              if (cartItem.cartItemId == null || cartItem.cartItemId.isEmpty) {
                                print('Error: No valid cart item ID found for update');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Unable to update quantity - invalid cart item ID'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (newQuantity <= 0) {
                                // If quantity is 0 or less, remove the item
                                final success = await _cartApi.removeFromCart(cartItem.cartItemId);
                                if (success) {
                                  await _fetchCart();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Item removed from cart'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                                return;
                              }
                              print('Updating cart item ${cartItem.cartItemId} quantity to: $newQuantity');
                              final result = await _cartApi.updateCartItem(
                                itemId: cartItem.cartItemId,
                                quantity: newQuantity
                              );
                              if (result != null) {
                                await _fetchCart(); // Refresh the cart
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to update quantity'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    // Cart Summary
                    Container(
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
                                Text(
                                  'Total (${cartItems.length} items)',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '₹${cartItems.fold(0.0, (sum, item) => sum + (item.totalPrice)).toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: defaultPadding),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _processPayment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  'Proceed to Checkout',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
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