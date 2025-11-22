// // import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:flutter/material.dart';
// import '../models/cart_item_model.dart'; // <-- 1. IMPORT
// import '../screens/checkout/views/payment_success_screen.dart';
// import 'package:shop/services/cart_wishlist_api_service.dart'; // <-- 2. IMPORT
// import 'package:shop/services/orders_api_service.dart'; // <-- 3. IMPORT
//
// class PaymentService {
// //  static Razorpay? _razorpay;
//   static BuildContext? _context;
//   static double _currentAmount = 0.0;
//
//   // --- 4. ADD SERVICE REFS & DATA ---
//   static OrdersApiService? _ordersApi;
//   static CartApiService? _cartApi;
//   static List<CartItem>? _cartItems;
//   static Map<String, dynamic>? _shippingInfo;
//
//   // --- 5. MODIFY initialize ---
//   static void initialize({
//     required BuildContext context,
//     required OrdersApiService ordersApi,
//     required CartApiService cartApi,
//   }) {
//     _context = context;
//     _ordersApi = ordersApi;
//     _cartApi = cartApi;
//
//     // _razorpay ??= Razorpay();
//     // _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     // _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     // _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }
//
//   // Dispose Razorpay
//   static void dispose() {
//     _razorpay?.clear();
//     _razorpay = null;
//     _context = null;
//     _ordersApi = null;
//     _cartApi = null;
//     _cartItems = null;
//     _shippingInfo = null;
//   }
//
//   // --- 6. MODIFY startPayment ---
//   static void startPayment({
//     required String key, // <-- From server
//     required double amount, // <-- From server
//     required String orderId, // <-- From server
//     required List<CartItem> cartItems, // <-- From cart screen
//     required Map<String, dynamic> shippingInfo, // <-- From cart screen
//     String? customerName,
//     String? customerEmail,
//     String? customerContact,
//   }) {
//     _currentAmount = amount; // Store the amount for success screen
//     _cartItems = cartItems; // Store cart items
//     _shippingInfo = shippingInfo; // Store shipping info
//
//     var options = {
//       'key': key,
//       'amount': (amount * 100).toInt(), // Amount in paise
//       'name': 'Your Shop Name',
//       'order_id': orderId,
//       'description': 'Payment for order #$orderId',
//       'timeout': 300, // 5 minutes
//       'prefill': {
//         'contact': customerContact ?? '9999999999',
//         'email': customerEmail ?? 'customer@example.com',
//         'name': customerName ?? 'Customer',
//       },
//       'theme': {
//         'color': '#FF7643',
//       },
//       'modal': {
//         'ondismiss': () {
//           _showSnackBar('Payment cancelled by user', Colors.orange);
//         }
//       }
//     };
//
//     try {
//       // _razorpay?.open(options);
//     } catch (e) {
//       _showSnackBar('Error starting payment: ${e.toString()}', Colors.red);
//     }
//   }
//
//   // --- 7. MODIFY _handlePaymentSuccess (This is the most important part) ---
//   static void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     _showSnackBar('Payment Successful! Verifying...', Colors.green);
//
//     if (_ordersApi == null || _cartApi == null || _context == null || _cartItems == null || _shippingInfo == null) {
//       _showSnackBar('Error: Payment service not initialized properly.', Colors.red);
//       return;
//     }
//
//     try {
//       // 1. Verify the payment with your backend
//       final bool isVerified = await _ordersApi!.verifyPayment(
//         razorpayOrderId: response.orderId!,
//         razorpayPaymentId: response.paymentId!,
//         razorpaySignature: response.signature!,
//       );
//
//       if (isVerified) {
//         // 2. If verified, create the *final order* in your database
//
//         // Convert CartItems to the format your API needs
//         List<Map<String, dynamic>> orderItems = _cartItems!.map((item) {
//           return {
//             "name": item.product.title,
//             "price": item.product.priceAfetDiscount ?? item.product.price,
//             "quantity": item.quantity,
//             "image": item.product.image,
//             "product": item.product.productId,
//           };
//         }).toList();
//
//         // Calculate prices again (to be safe)
//         double itemsPrice = _cartItems!.fold(0.0, (sum, item) => sum + item.totalPrice);
//         double taxPrice = 0; // TODO: Calculate tax if needed
//         double shippingPrice = 0; // TODO: Calculate shipping if needed
//         double totalPrice = itemsPrice + taxPrice + shippingPrice;
//
//         await _ordersApi!.createOrder(
//           shippingInfo: _shippingInfo!,
//           orderItems: orderItems,
//           paymentInfo: {
//             "id": response.paymentId,
//             "status": "succeeded",
//           },
//           itemsPrice: itemsPrice,
//           taxPrice: taxPrice,
//           shippingPrice: shippingPrice,
//           totalPrice: totalPrice,
//         );
//
//         // 3. Clear the cart on the backend
//         await _cartApi!.clearCart();
//
//         // 4. Navigate to success screen
//         Navigator.of(_context!).pushAndRemoveUntil(
//           MaterialPageRoute(
//             builder: (context) => PaymentSuccessScreen(
//               paymentId: response.paymentId ?? '',
//               orderId: response.orderId ?? '',
//               amount: _currentAmount,
//             ),
//           ),
//               (route) => false, // Clear all routes behind it
//         );
//       } else {
//         _showSnackBar('Payment verification failed. Contact support.', Colors.red);
//       }
//     } catch (e) {
//       _showSnackBar('Error during payment verification: $e', Colors.red);
//     }
//   }
//
//   // Handle payment error
//   static void _handlePaymentError(PaymentFailureResponse response) {
//     _showSnackBar(
//       'Payment Failed: ${response.message}',
//       Colors.red,
//     );
//     _onPaymentError(response);
//   }
//
//   // Handle external wallet
//   static void _handleExternalWallet(ExternalWalletResponse response) {
//     _showSnackBar(
//       'External Wallet Selected: ${response.walletName}',
//       Colors.blue,
//     );
//   }
//
//   // Show snackbar
//   static void _showSnackBar(String message, Color color) {
//     if (_context != null) {
//       ScaffoldMessenger.of(_context!).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: color,
//           duration: const Duration(seconds: 4),
//           action: SnackBarAction(
//             label: 'OK',
//             textColor: Colors.white,
//             onPressed: () {
//               ScaffoldMessenger.of(_context!).hideCurrentSnackBar();
//             },
//           ),
//         ),
//       );
//     }
//   }
//
//   // Custom callback for payment error
//   static void _onPaymentError(PaymentFailureResponse response) {
//     print('Payment Error: ${response.code}');
//     print('Message: ${response.message}');
//   }
//
// // (generateOrderId is removed as it's now done on the backend)
// }