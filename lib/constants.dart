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

const grandisExtendedFont = "Grandis Extended";

// On color 80, 60.... those means opacity

const Color primaryColor = Color(0xFFE91E63); // Changed to pink

const MaterialColor primaryMaterialColor =
    MaterialColor(0xFFE91E63, <int, Color>{
  50: Color(0xFFFCE4EC),
  100: Color(0xFFF8BBD9),
  200: Color(0xFFF48FB1),
  300: Color(0xFFF06292),
  400: Color(0xFFEC407A),
  500: Color(0xFFE91E63),
  600: Color(0xFFD81B60),
  700: Color(0xFFC2185B),
  800: Color(0xFFAD1457),
  900: Color(0xFF880E4F),
});

const Color blackColor = Color(0xFF16161E);
const Color blackColor80 = Color(0xFF45454B);
const Color blackColor60 = Color(0xFF737378);
const Color blackColor40 = Color(0xFFA2A2A5);
const Color blackColor20 = Color(0xFFD0D0D2);
const Color blackColor10 = Color(0xFFE8E8E9);
const Color blackColor5 = Color(0xFFF3F3F4);

const Color whiteColor = Colors.white;
const Color whileColor80 = Color(0xFFCCCCCC);
const Color whileColor60 = Color(0xFF999999);
const Color whileColor40 = Color(0xFF666666);
const Color whileColor20 = Color(0xFF333333);
const Color whileColor10 = Color(0xFF191919);
const Color whileColor5 = Color(0xFF0D0D0D);

const Color greyColor = Color(0xFFB8B5C3);
const Color lightGreyColor = Color(0xFFF8F8F9);
const Color darkGreyColor = Color(0xFF1C1C25);
// const Color greyColor80 = Color(0xFFC6C4CF);
// const Color greyColor60 = Color(0xFFD4D3DB);
// const Color greyColor40 = Color(0xFFE3E1E7);
// const Color greyColor20 = Color(0xFFF1F0F3);
// const Color greyColor10 = Color(0xFFF8F8F9);
// const Color greyColor5 = Color(0xFFFBFBFC);

const Color purpleColor = Color(0xFFE91E63); // Changed to pink (same as primary)
const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);

const double defaultPadding = 16.0;
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
