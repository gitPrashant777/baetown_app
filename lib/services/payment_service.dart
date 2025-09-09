import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import '../screens/checkout/views/payment_success_screen.dart';
import '../services/cart_service.dart';

class PaymentService {
  static Razorpay? _razorpay;
  static BuildContext? _context;
  static double _currentAmount = 0.0;

  // Initialize Razorpay
  static void initialize(BuildContext context) {
    _context = context;
    _razorpay ??= Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Dispose Razorpay
  static void dispose() {
    _razorpay?.clear();
    _razorpay = null;
    _context = null;
  }

  // Start payment
  static void startPayment({
    required double amount,
    required String orderId,
    String? customerName,
    String? customerEmail,
    String? customerContact,
  }) {
    _currentAmount = amount; // Store the amount for success screen
    
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your Razorpay API key
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Your Shop Name',
      'order_id': orderId,
      'description': 'Payment for order #$orderId',
      'timeout': 300, // 5 minutes
      'prefill': {
        'contact': customerContact ?? '9999999999',
        'email': customerEmail ?? 'customer@example.com',
        'name': customerName ?? 'Customer',
      },
      'theme': {
        'color': '#FF7643',
      },
      'modal': {
        'ondismiss': () {
          _showSnackBar('Payment cancelled by user', Colors.orange);
        }
      }
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      _showSnackBar('Error starting payment: ${e.toString()}', Colors.red);
    }
  }

  // Handle successful payment
  static void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _showSnackBar(
      'Payment Successful! Payment ID: ${response.paymentId}',
      Colors.green,
    );
    
    // You can add your post-payment success logic here
    // For example: update order status, clear cart, navigate to success page
    _onPaymentSuccess(response);
  }

  // Handle payment error
  static void _handlePaymentError(PaymentFailureResponse response) {
    _showSnackBar(
      'Payment Failed: ${response.message}',
      Colors.red,
    );
    
    // You can add your payment failure logic here
    _onPaymentError(response);
  }

  // Handle external wallet
  static void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackBar(
      'External Wallet Selected: ${response.walletName}',
      Colors.blue,
    );
  }

  // Show snackbar
  static void _showSnackBar(String message, Color color) {
    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(_context!).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  // Custom callback for payment success
  static void _onPaymentSuccess(PaymentSuccessResponse response) {
    // Navigate to payment success screen
    if (_context != null) {
      Navigator.of(_context!).push(
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            paymentId: response.paymentId ?? '',
            orderId: response.orderId ?? '',
            amount: _currentAmount,
          ),
        ),
      );
    }
    
    print('Payment Success: ${response.paymentId}');
    print('Order ID: ${response.orderId}');
    print('Signature: ${response.signature}');
  }

  // Custom callback for payment error
  static void _onPaymentError(PaymentFailureResponse response) {
    // Add your custom logic here
    // For example:
    // - Log error
    // - Show retry option
    // - Update analytics
    
    print('Payment Error: ${response.code}');
    print('Message: ${response.message}');
  }

  // Generate a simple order ID (you should use your backend to generate this)
  static String generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'order_$timestamp';
  }
}
