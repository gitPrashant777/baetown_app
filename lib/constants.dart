import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'models/product_model.dart';

// Just for demo - High quality jewelry images
const productDemoImg1 = "https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=80";
const productDemoImg2 = "https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=80";
const productDemoImg3 = "https://images.unsplash.com/photo-1601821765780-754fa98637c1?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=80";
const productDemoImg4 = "https://images.unsplash.com/photo-1588444645841-9d4e0022cbd3?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=80";
const productDemoImg5 = "https://images.unsplash.com/photo-1611591437281-460bfbe1220a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=80";
const productDemoImg6 = "https://images.unsplash.com/photo-1596944924616-7b38e7cfac36?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=80";

// End For demo

// --- NEW FONT CONSTANTS (For Target UI) ---
// We will use a Serif font for headings and a Sans-Serif for body text.
// ❗️IMPORTANT: You must add these fonts to your pubspec.yaml
const kSerifFont = "Playfair Display"; // Example: A Google Font
const kSansSerifFont = "Montserrat"; // Example: A Google Font
// --- END NEW FONT CONSTANTS ---

const grandisExtendedFont = "Grandis Extended"; // Original font

// On color 80, 60.... those means opacity
const Color pinkColor = primaryColor;
// Add these to your constants.dart file if not already present


// Make sure you have this color defined
const Color kPrimaryColor = Color(0xFF020953);

// --- UPDATED COLORS FOR NEW THEME ---
// Original values are commented out

const Color primaryColor = Color(0xFF20263E); // Original: const Color(0xFFE91E63);
const Color kLightBeigeColor = Color(0xFFF7F5F3); // New color for card backgrounds
const Color kBorderColor = Color(0xFFEAEBEE); // New color for inactive borders

const MaterialColor primaryMaterialColor =
MaterialColor(0xFF20263E, <int, Color>{ // Original: 0xFFE91E63
  50: Color(0xFFEAEBEE), // Original: 0xFFFCE4EC
  100: Color(0xFFC9CCD8), // Original: 0xFFF8BBD9
  200: Color(0xFFA5ABC1), // Original: 0xFFF48FB1
  300: Color(0xFF818AAB), // Original: 0xFFF06292
  400: Color(0xFF636F9A), // Original: 0xFFEC407A
  500: Color(0xFF20263E), // Original: 0xFFE91E63
  600: Color(0xFF1D2338), // Original: 0xFFD81B60
  700: Color(0xFF191F31), // Original: 0xFFC2185B
  800: Color(0xFF161B2A), // Original: 0xFFAD1457
  900: Color(0xFF101423), // Original: 0xFF880E4F
});

// Using original names but with new theme colors
const Color blackColor = Color(0xFF20263E); // Original: const Color(0xFF16161E);
const Color blackColor80 = Color(0xFF6E7288); // Original: const Color(0xFF45454B);
const Color blackColor60 = Color(0xFF9094A5); // Original: const Color(0xFF737378);
const Color blackColor40 = Color(0xFFB3B6C2); // Original: const Color(0xFFA2A2A5);
const Color blackColor20 = Color(0xFFD6D8DE); // Original: const Color(0xFFD0D0D2);
const Color blackColor10 = Color(0xFFEAEBEE); // Original: const Color(0xFFE8E8E9);
const Color blackColor5 = Color(0xFFF5F5F7); // Original: const Color(0xFFF3F3F4);

const Color whiteColor = Color(0xFFFFFFFF); // Original: Colors.white
const Color whileColor80 = Color(0xFFCCCCCC);
const Color whileColor60 = Color(0xFF999999);
const Color whileColor40 = Color(0xFF666666);
const Color whileColor20 = Color(0xFF333333);
const Color whileColor10 = Color(0xFF191919);
const Color whileColor5 = Color(0xFF0D0D0D);

const Color greyColor = Color(0xFF9094A5); // Original: const Color(0xFFB8B5C3);
const Color lightGreyColor = Color(0xFFF7F5F3); // Original: const Color(0xFFF8F8F9);
const Color darkGreyColor = Color(0xFF20263E); // Original: const Color(0xFF1C1C25);

const Color purpleColor = Color(0xFF20263E); // Original: const Color(0xFFE91E63);
const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);
// --- END UPDATED COLORS ---

const double defaultPadding = 20.0; // Original: 16.0
const double defaultBorderRadious = 12.0;
const Duration defaultDuration = Duration(milliseconds: 300);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(8, errorText: 'password must be at least 8 digits long'),
  // Temporarily commented out regex validation for special characters
  // PatternValidator(r'(?=.*?[#?!@$%^&*-])',
  //     errorText: 'passwords must have at least one special character')
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: "Enter a valid email address"),
]);

const pasNotMatchErrorText = "passwords do not match";

// Demo products list for screens that need it
final List<ProductModel> demoPopularProducts = [
  ProductModel(
    productId: "demo1",
    title: "Diamond Ring",
    brandName: "BAETOWN",
    description: "Beautiful diamond ring",
    category: "Jewelry",
    price: 299.99,
    stockQuantity: 10,
    maxOrderQuantity: 2,
    isOutOfStock: false,
    image: productDemoImg1,
    images: [productDemoImg1, productDemoImg2],
  ),
  ProductModel(
    productId: "demo2",
    title: "Gold Bracelet",
    brandName: "BAETOWN",
    description: "Elegant gold bracelet",
    category: "Jewelry",
    price: 199.99,
    stockQuantity: 5,
    maxOrderQuantity: 1,
    isOutOfStock: false,
    image: productDemoImg3,
    images: [productDemoImg3, productDemoImg4],
  ),
  ProductModel(
    productId: "demo3",
    title: "Silver Necklace",
    brandName: "BAETOWN",
    description: "Classic silver necklace",
    category: "Jewelry",
    price: 149.99,
    stockQuantity: 8,
    maxOrderQuantity: 3,
    isOutOfStock: false,
    image: productDemoImg5,
    images: [productDemoImg5, productDemoImg6],
  ),
];