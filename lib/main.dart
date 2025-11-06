// lib/main.dart
// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/services/api_service.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/services/cart_wishlist_api_service.dart';
import 'package:shop/services/firebase_kit_service.dart';
import 'package:shop/services/products_api_service.dart';
import 'package:shop/services/reviews_api_service.dart';
import 'package:shop/theme/app_theme.dart';
import 'package:shop/models/user_session.dart';
import 'package:provider/provider.dart';
import 'services/orders_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UserSession.loadSession();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // Add your Firebase options here
  );
  print('🚨🚨🚨 MAIN: App started - checking existing session...');
  if (UserSession.authToken != null) {
    print('🚨🚨🚨 MAIN: Found existing token...');
  } else {
    print('🚨🚨🚨 MAIN: No existing token found - user needs to login');
  }

  runApp(
    MultiProvider(
      providers: [
        // --- BASE SERVICES (Create a single instance) ---
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        Provider<FirebaseKitService>(
          create: (_) => FirebaseKitService(),
        ),
        Provider<ProductsApiService>(
          create: (_) => ProductsApiService(),
        ),

        // --- PROXY PROVIDERS (Services that depend on ApiService) ---
        // These get the shared ApiService and pass it to the constructor
        ProxyProvider<ApiService, ReviewsApiService>(
          update: (_, apiService, __) => ReviewsApiService(apiService),
        ),
        ProxyProvider<ApiService, OrdersApiService>(
          update: (_, apiService, __) => OrdersApiService(apiService),
        ),
        ProxyProvider<ApiService, CartApiService>(
          update: (_, apiService, __) => CartApiService(apiService),
        ),
        ProxyProvider<ApiService, WishlistApiService>(
          update: (_, apiService, __) => WishlistApiService(apiService),
        ),

        // --- CHANGENOTIFIER PROVIDERS (Services that manage UI state) ---
        ChangeNotifierProvider<CartService>(
          create: (context) => CartService(
            // It gets the shared CartApiService
            Provider.of<CartApiService>(context, listen: false),
          )..fetchCart(), // Fetch the cart as soon as the app starts
        ),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BAETOWN Jewelry - Premium Jewelry Collection',
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      initialRoute: splashScreenRoute,
    );
  }
}