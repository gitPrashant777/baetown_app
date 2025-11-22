// assessment_report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // For 'firstWhereOrNull'
import 'package:shop/constants.dart'; // Make sure you import this if _buildTimelineNode uses primaryColor

// Import your app's models and services
import '../../../models/assessment_report.dart';
// import '../../../models/onboarding_data.dart'; // Unused
import '../../../services/firebase_kit_service.dart';
import '../../../services/products_api_service.dart';
import '../../../models/product_model.dart';
import '../../../route/screen_export.dart'; // For navigation

class AssessmentReportScreen extends StatefulWidget {
  final String userName;
  final String userAge;
  final String selectedGender;
  final AssessmentReport assessmentReport;

  const AssessmentReportScreen({
    super.key,
    required this.userName,
    required this.userAge,
    required this.selectedGender,
    required this.assessmentReport,
  });

  @override
  State<AssessmentReportScreen> createState() => _AssessmentReportScreenState();
}

class _AssessmentReportScreenState extends State<AssessmentReportScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedCauseIndex = 0;
  int _selectedSkinCauseIndex = 0;

  // Services
  late ProductsApiService _productsApiService;
  late FirebaseKitService _firebaseKitService;

  // Futures
  late Future<List<ProductModel>> _productsFuture;

  // State
  List<ProductModel> _allProducts = []; // Master list for price calculation
  Map<String, int> _selectedProductQuantities = {}; // Correct state
  double _totalPrice = 0.0;
  double _mrpPrice = 0.0;
  bool _isSaving = false; // For button loading state
// Add these constants after your state variables
  static const brandSecondary = Color(0xFF04076B);
  static const brandAccent = Color(0xFF1A1A2E);

  // --- 1. URL UPDATED ---
  final String _imageBaseUrl = "https://mern-backend-t3h8.onrender.com/api/v1";

  static const brandPrimary = Color(0xFF020953);
  @override
  void initState() {
    super.initState();
    // Initialize services
    _productsApiService = Provider.of<ProductsApiService>(context, listen: false);
    _firebaseKitService = Provider.of<FirebaseKitService>(context, listen: false);

    // --- REFACTORED DATA LOADING ---
    // Define ONE future to get ALL products
    _productsFuture = _productsApiService.getAllProducts();

    // Create a new combined future that loads all products,
    // then initializes quantities and calculates the price.
    _loadAndInitialize();
  }

  // --- LOGIC METHODS ---

  // NEW: Combined loading and initialization method
  Future<void> _loadAndInitialize() async {
    // 1. Wait for ALL products to be fetched
    final allApiProducts = await _productsFuture;

    // 2. Populate the master list (_allProducts)
    final allProductsMap = <String, ProductModel>{};
    for (var p in allApiProducts) {
      if (p.productId != null) {
        allProductsMap[p.productId!] = p;
      }
    }

    if (!mounted) return;
    setState(() {
      _allProducts = allProductsMap.values.toList();
    });

    // --- THIS IS THE FIX ---
    // We create the lists *after* _allProducts is set
    // and use the new, more flexible filtering logic.
    const hairCategories = ['hair', 'scalp'];
    const skinCategories = ['skin', 'toner', 'face'];

    final hairProducts = _allProducts
        .where((p) {
      final categoryLower = p.category.toLowerCase();
      return hairCategories.any((cat) => categoryLower.contains(cat));
    })
        .toList();

    final skinProducts = _allProducts
        .where((p) {
      final categoryLower = p.category.toLowerCase();
      return skinCategories.any((cat) => categoryLower.contains(cat));
    })
        .toList();

    // 4. Initialize the selected quantities (This still runs)
    _initializeSelectedProducts(hairProducts, skinProducts);
  }

  // MODIFIED: Now takes arguments, doesn't fetch
  void _initializeSelectedProducts(
      List<ProductModel> hairProducts, List<ProductModel> skinProducts) {
    final Map<String, int> initialQuantities = {};

    for (var geminiProduct in widget.assessmentReport.recommendedHairKit) {
      final matchingProduct = hairProducts.firstWhereOrNull(
            (apiProd) =>
        apiProd.title.toLowerCase() == geminiProduct.name.toLowerCase(),
      );
      if (matchingProduct != null && matchingProduct.productId != null) {
        int suggestedQty = _getSuggestedQuantity(matchingProduct);
        initialQuantities[matchingProduct.productId!] = suggestedQty;
      }
    }

    for (var geminiProduct in widget.assessmentReport.recommendedSkinKit) {
      final matchingProduct = skinProducts.firstWhereOrNull(
            (apiProd) =>
        apiProd.title.toLowerCase() == geminiProduct.name.toLowerCase(),
      );
      if (matchingProduct != null && matchingProduct.productId != null) {
        int suggestedQty = _getSuggestedQuantity(matchingProduct);
        initialQuantities[matchingProduct.productId!] = suggestedQty;
      }
    }

    // 4. Set state for quantities and calculate price
    setState(() {
      _selectedProductQuantities = initialQuantities;
      _calculateTotalPrice(); // This will now work
    });
  }

  // Gets the suggested quantity based on diagnosis
  int _getSuggestedQuantity(ProductModel product) {
    int minQty = 2;
    int maxQty = product.maxOrderQuantity;
    int suggestedQty = minQty;

    // Use a list-based check here too for safety
    const hairCategories = ['hair', 'scalp'];
    final categoryLower = product.category.toLowerCase();

    if (hairCategories.any((cat) => categoryLower.contains(cat))) {
      int possibility =
          widget.assessmentReport.regrowthPossibility; // Use int directly
      if (possibility <= 30)
        suggestedQty = 4; // Intensive
      else if (possibility <= 70)
        suggestedQty = 3; // Standard
      else
        suggestedQty = 2; // Maintenance
    } else {
      // Assume skin if not hair
      String diagnosis = widget.assessmentReport.skinDiagnosis.toLowerCase();
      if (diagnosis.contains('severe'))
        suggestedQty = 4;
      else if (diagnosis.contains('moderate'))
        suggestedQty = 3;
      else
        suggestedQty = 2; // Mild or unknown
    }
    return suggestedQty.clamp(minQty, maxQty);
  }

  // Updates the quantity for a product
  void _updateProductQuantity(ProductModel product, int newQuantity) {
    if (product.productId == null) return;
    setState(() {
      int minQty = 0; // 0 to allow removal
      int maxQty = product.maxOrderQuantity;
      int clampedQty = newQuantity.clamp(minQty, maxQty);

      if (clampedQty == 0) {
        _selectedProductQuantities.remove(product.productId!);
      } else {
        _selectedProductQuantities[product.productId!] = clampedQty;
      }
      _calculateTotalPrice(); // Recalculate on every change
    });
  }

  // Calculates total price based on the quantity map
  void _calculateTotalPrice() {
    double total = 0.0;
    double mrp = 0.0;

    for (var entry in _selectedProductQuantities.entries) {
      final productId = entry.key;
      final quantity = entry.value;

      final product = _allProducts.firstWhereOrNull(
            (p) => p.productId == productId,
      );

      if (product != null) {
        total += (product.priceAfetDiscount ?? product.price) * quantity;
        mrp += product.price * quantity;
      }
    }
    setState(() {
      _totalPrice = total;
      _mrpPrice = mrp;
    });
  }

  // Handles saving the kit to Firebase
  Future<void> _saveKitForLater() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    try {
      final List<ProductModel> productsToSave = [];
      for (var entry in _selectedProductQuantities.entries) {
        final product =
        _allProducts.firstWhereOrNull((p) => p.productId == entry.key);
        if (product != null) {
          productsToSave.add(product);
        }
      }

      if (productsToSave.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Your kit is empty."),
              backgroundColor: Colors.orange),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      String kitName = "Custom Kit";
      if (widget.assessmentReport.hairDiagnosis.isNotEmpty &&
          widget.assessmentReport.skinDiagnosis.isNotEmpty) {
        kitName = "Hair & Skin Kit";
      } else if (widget.assessmentReport.hairDiagnosis.isNotEmpty) {
        kitName = widget.assessmentReport.hairDiagnosis;
      } else if (widget.assessmentReport.skinDiagnosis.isNotEmpty) {
        kitName = widget.assessmentReport.skinDiagnosis;
      }
      String diagnosis =
          "${widget.assessmentReport.hairDiagnosis}. ${widget.assessmentReport.skinDiagnosis}";

      await _firebaseKitService.saveKit(
        kitProducts: productsToSave,
        kitName: kitName,
        diagnosis: diagnosis.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Kit saved successfully!"),
            backgroundColor: brandPrimary),
      );

      Navigator.pushNamedAndRemoveUntil(
          context, entryPointScreenRoute, (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error saving kit: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // --- IMAGE URL HELPER ---
  String _buildProductImageUrl(ProductModel product) {
    String imageUrl = product.image;
    if (imageUrl.isEmpty && product.images.isNotEmpty) {
      imageUrl = product.images.first;
    } else if (imageUrl.isEmpty) {
      // Your device can't reach via.placeholder.com.
      // We'll return an empty string to let the errorBuilder handle it gracefully.
      return '';
    }
    if (imageUrl.startsWith('http')) return imageUrl;
    if (imageUrl.startsWith('/')) return '$_imageBaseUrl$imageUrl';
    return '$_imageBaseUrl/$imageUrl';
  }

  // --- MAIN BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // --- MODIFIED: "X" (Close) Button ---
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(entryPointScreenRoute),
        ),
        title: const Text(
          "Assessment Report",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // --- MODIFIED: Removed bottomNavigationBar ---
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDiagnosisSection(),
              const SizedBox(height: 24),
              _buildRootCausesSection(),
              const SizedBox(height: 24),
              _buildHairKitSection(),
              const SizedBox(height: 24),
              _buildSkinRootCausesSection(),
              const SizedBox(height: 24),
              if (widget.assessmentReport.recommendedSkinKit.isNotEmpty)
                Column(
                  children: [
                    _buildSkinKitSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              _buildRecommendedProductsSection(),
              const SizedBox(height: 24),
              _buildAddOnsSection(),
              const SizedBox(height: 24),
              _buildResultsTimelineSection(),
              const SizedBox(height: 24),

              // --- NEW: Added bottom actions here ---
              _buildBottomActions(),
              const SizedBox(height: 20), // Padding at the very bottom
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET 1 (Unchanged) ---
  Widget _buildDiagnosisSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.userName}, ${widget.userAge}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "You've been diagnosed with:",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "• ${widget.assessmentReport.hairDiagnosis}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "• ${widget.assessmentReport.skinDiagnosis}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Start Seeing Results In ${widget.assessmentReport.hairTimeline}",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.selectedGender.toLowerCase() == 'female'
                      ? Icons.female
                      : Icons.male,
                  color: Colors.grey[600],
                  size: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: brandPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Hair Regrowth possibility ${widget.assessmentReport.regrowthPossibility}%",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Stage 2 male pattern hair fall is caused by internal hormone attacking your hair follicles. At your Stage, most hair follicles are still active.",
              style: TextStyle(
                color: brandPrimary,
                height: 1.4,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET 2 (Unchanged) ---
  Widget _buildRootCausesSection() {
    final causes = widget.assessmentReport.hairRootCauses;
    if (causes.isEmpty) return Container();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Hair Loss Root Causes",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(causes.length, (index) {
              final cause = causes[index];
              final isSelected = _selectedCauseIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCauseIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 4,
                      right: index == causes.length - 1 ? 0 : 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange[50] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue[700]!
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          cause.icon,
                          color:
                          isSelected ? Colors.blue[800] : Colors.black87,
                          size: 28,
                        ),
                        const SizedBox(height: 12),
                        // --- START FIX ---
                        SizedBox(
                          height: 40.0, // Forces a fixed height for 2 lines
                          child: Align(
                            alignment: Alignment.center, // Vertically centers 1-line text
                            child: Text(
                              cause.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.blue[900]
                                    : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        // --- END FIX ---
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              causes[_selectedCauseIndex].description,
              style: TextStyle(
                color: Colors.orange[900],
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET 3: *** MODIFIED AS REQUESTED *** ---
  Widget _buildHairKitSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your 1st Month Kit",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<ProductModel>>(
            future: _productsFuture, // Use the single, correct future
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No products found."));
              }

              // **************************************************
              // ** START: MODIFIED LOGIC (Category Filter Fix) **
              // **************************************************
              const hairCategories = ['hair', 'scalp'];

              // Filter for 'Hair' products
              final allApiHairProducts = snapshot.data!
                  .where((p) {
                final categoryLower = p.category.toLowerCase();
                return hairCategories.any((cat) => categoryLower.contains(cat));
              })
                  .toList();
              // **************************************************
              // ** END: MODIFIED LOGIC (Category Filter Fix) **
              // **************************************************


              if (allApiHairProducts.isEmpty) {
                return const Center(child: Text("No hair products found."));
              }

              // 1. Determine product count based on regrowth possibility
              int numProductsToShow;
              int possibility = widget.assessmentReport.regrowthPossibility;

              if (possibility <= 25) {
                numProductsToShow = 5; // Intensive (max)
              } else if (possibility <= 50) {
                numProductsToShow = 4;
              } else if (possibility <= 75) {
                numProductsToShow = 3;
              } else {
                numProductsToShow = 2; // Maintenance (min)
              }

              // 2. Apply clamps
              // Clamp to the user's required range (2-5)
              numProductsToShow = numProductsToShow.clamp(2, 5);
              // Clamp to the number of products we actually have
              numProductsToShow =
                  numProductsToShow.clamp(0, allApiHairProducts.length);

              final List<ProductModel> productsToShow =
              allApiHairProducts.take(numProductsToShow).toList();

              return Column(
                children: productsToShow.map((product) {
                  final currentQty =
                      _selectedProductQuantities[product.productId] ?? 0;
                  int suggestedQty = _getSuggestedQuantity(product);

                  return _buildProductRowCard(
                    product,
                    currentQty,
                    suggestedQty,
                        () => _updateProductQuantity(product, currentQty + 1),
                        () => _updateProductQuantity(product, currentQty - 1),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- WIDGET 4 (Unchanged) ---
  Widget _buildSkinRootCausesSection() {
    final causes = widget.assessmentReport.skinRootCauses;
    if (causes.isEmpty) return Container();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Skin Root Causes",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(causes.length, (index) {
              final cause = causes[index];
              final isSelected = _selectedSkinCauseIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSkinCauseIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 4,
                      right: index == causes.length - 1 ? 0 : 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[50] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                        isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          cause.icon,
                          color: isSelected ? Colors.blue[800] : Colors.black87,
                          size: 28,
                        ),

                        const SizedBox(height: 12),
                        // --- START FIX ---
                        SizedBox(
                          height: 40.0, // Forces a fixed height for 2 lines
                          child: Align(
                            alignment: Alignment.center, // Vertically centers 1-line text
                            child: Text(
                              cause.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color:
                                isSelected ? Colors.blue[900] : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              causes[_selectedSkinCauseIndex].description,
              style: TextStyle(
                color: Colors.blue[900],
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET 5: *** MODIFIED (Proactively) *** ---
  Widget _buildSkinKitSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Skin Care Products",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<ProductModel>>(
            future: _productsFuture, // Use the single, correct future
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No products found."));
              }

              // **************************************************
              // ** START: MODIFIED LOGIC (Category Filter Fix) **
              // **************************************************
              const skinCategories = ['skin', 'toner', 'face'];

              // Filter for 'Skin' products
              final allApiSkinProducts = snapshot.data!
                  .where((p) {
                final categoryLower = p.category.toLowerCase();
                return skinCategories.any((cat) => categoryLower.contains(cat));
              })
                  .toList();



              if (allApiSkinProducts.isEmpty) {
                return const Center(child: Text("No skin products found."));
              }

              // 1. Determine product count based on skin diagnosis
              int numProductsToShow;
              String diagnosis =
              widget.assessmentReport.skinDiagnosis.toLowerCase();

              if (diagnosis.contains('severe')) {
                numProductsToShow = 5; // Max
              } else if (diagnosis.contains('moderate')) {
                numProductsToShow = 4;
              } else if (diagnosis.contains('mild')) {
                numProductsToShow = 3;
              } else {
                numProductsToShow = 2; // Default (min)
              }

              // 2. Apply clamps
              // Clamp to the user's required range (2-5)
              numProductsToShow = numProductsToShow.clamp(2, 5);
              // Clamp to the number of products we actually have
              numProductsToShow =
                  numProductsToShow.clamp(0, allApiSkinProducts.length);

              final List<ProductModel> productsToShow =
              allApiSkinProducts.take(numProductsToShow).toList();

              return Column(
                children: productsToShow.map((product) {
                  final currentQty =
                      _selectedProductQuantities[product.productId] ?? 0;
                  int suggestedQty = _getSuggestedQuantity(product);

                  return _buildProductRowCard(
                    product,
                    currentQty,
                    suggestedQty,
                        () => _updateProductQuantity(product, currentQty + 1),
                        () => _updateProductQuantity(product, currentQty - 1),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- WIDGET 6 (Unchanged) ---
  Widget _buildRecommendedProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Most Popular", // <-- TITLE CHANGED
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<ProductModel>>(
          future: _productsFuture, // This already fetches ALL products
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 220,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text("Error fetching products: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No products found."));
            }

            // --- START: Logic from MostPopular widget ---
            final allProducts = snapshot.data!;

            // Filter products that are marked as popular
            final popularProducts = allProducts
                .where((product) => product.isPopular == true)
                .toList();

            final List<ProductModel> productsToShow;

            // If no products are marked as popular, show middle 6 products
            if (popularProducts.isEmpty && allProducts.isNotEmpty) {
              final startIndex =
              allProducts.length > 6 ? (allProducts.length ~/ 2) - 3 : 0;
              final endIndex = startIndex + 6;
              productsToShow = allProducts
                  .skip(startIndex)
                  .take(endIndex - startIndex)
                  .toList();
            } else {
              // Show popular products, up to 6
              productsToShow = popularProducts.take(6).toList();
            }

            if (productsToShow.isEmpty) {
              return Container(
                height: 220,
                child:
                const Center(child: Text("No popular products available.")),
              );
            }
            // --- END: Logic from MostPopular widget ---

            return Container(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productsToShow.length, // <-- Use new filtered list
                itemBuilder: (context, index) {
                  final product =
                  productsToShow[index]; // <-- Use new filtered list
                  final imageUrl = _buildProductImageUrl(product);

                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) {
                              // Removed the print statement to reduce log noise
                              return Container(
                                height: 120,
                                width: 160,
                                color: Colors.grey[200],
                                child: Icon(Icons.shopping_bag,
                                    color: Colors.grey[600]),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "₹${(product.priceAfetDiscount ?? product.price).toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // --- WIDGET 7 (Unchanged) ---
  Widget _buildAddOnsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 16),
          child: Text(
            "Your Personalised Plan",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ),
        ...widget.assessmentReport.freeAddOns.map(
              (addon) => _buildAddOnCard(addon),
        ),
      ],
    );
  }

  // --- WIDGET 8 (Unchanged) ---
  Widget _buildResultsTimelineSection() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "See best results in ${widget.assessmentReport.hairTimeline}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 32),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 25,
                    left: 0,
                    width: 600,
                    child: Container(
                      height: 2,
                      color: brandPrimary, // <-- Fixed color
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimelineNode(
                        Icons.opacity,
                        "Month 1-3",
                        "Focus on controlling hairfall and improving scalp health.",
                      ),
                      const SizedBox(width: 30),
                      _buildTimelineNode(
                        Icons.local_fire_department,
                        "Month 4-6",
                        "Start seeing visible hair growth and thickness.",
                      ),
                      const SizedBox(width: 30),
                      _buildTimelineNode(
                        Icons.shield,
                        "Month 6-9",
                        "Maintain new growth and strengthen follicles.",
                      ),
                      const SizedBox(width: 30),
                      _buildTimelineNode(
                        Icons.celebration,
                        "Month 12",
                        "Achieve full results and continue maintenance.",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW: Bottom Actions Widget (Unchanged) ---
  Widget _buildBottomActions() {
    return Column(
      children: [
        // 1. Price Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              const Text(
                "Your Custom Kit Price",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "₹${_totalPrice.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_mrpPrice > _totalPrice)
                    Text(
                      "₹${_mrpPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF999999),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Inclusive of all taxes",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2. Button Row
        Row(
          children: [
            // Save for Later Button
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _saveKitForLater,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                      color: _isSaving
                          ? Colors.grey[300]!
                          : const Color(0xFF2D2D2D)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.grey),
                )
                    : const Text(
                  "Save Kit",
                  style: TextStyle(
                    color: Color(0xFF2D2D2D),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Buy Now Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  int totalItemCount = _selectedProductQuantities.values.isEmpty
                      ? 0
                      : _selectedProductQuantities.values
                      .reduce((a, b) => a + b);

                  _showCheckoutDialog(
                    _totalPrice.toStringAsFixed(0),
                    _mrpPrice.toStringAsFixed(0),
                    totalItemCount,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D2D2D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Buy Now",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- HELPER WIDGETS ---

  // --- HELPER: UPDATED for Quantity (Unchanged) ---
  Widget _buildProductRowCard(
      ProductModel product,
      int quantity,
      int suggestedQty,
      VoidCallback onIncrement,
      VoidCallback onDecrement,
      ) {
    final imageUrl = _buildProductImageUrl(product);
    final finalPrice = (product.priceAfetDiscount ?? product.price);
    final bool isSelected = quantity > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? brandPrimary : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? brandPrimary.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover, errorBuilder: (c, e, s) {
                  // I also removed the print from here
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: Icon(Icons.shopping_bag_outlined,
                        color: Colors.grey[600]),
                  );
                }),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                if (product.category.isNotEmpty)
                  _buildTagChip(product.category),
                const SizedBox(height: 4),
                // Suggested Quantity
                Text(
                  "Recommended: $suggestedQty units",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Price & Button Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "₹${finalPrice.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              if (product.priceAfetDiscount != null &&
                  product.priceAfetDiscount! < product.price)
                Text(
                  "₹${product.price.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              const SizedBox(height: 8),

              // Quantity Selector
              if (quantity == 0)
                TextButton(
                  onPressed: onIncrement, // Adds 1
                  style: TextButton.styleFrom(
                    backgroundColor: brandPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    minimumSize: Size(88, 32),
                  ),
                  child: Text(
                    "ADD",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: IconButton(
                          onPressed: onDecrement,
                          icon: Icon(Icons.remove,
                              size: 14, color: Colors.green[900]),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      Text(
                        "$quantity",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green[900],
                        ),
                      ),
                      SizedBox(
                        width: 28,
                        child: IconButton(
                          onPressed: onIncrement,
                          icon: Icon(Icons.add,
                              size: 14, color: Colors.green[900]),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HELPER (Unchanged) ---
  Widget _buildTagChip(String category) {
    // Use the same list-based logic for consistency
    const hairCategories = ['hair', 'scalp'];
    bool isHair = hairCategories.any((cat) => category.toLowerCase().contains(cat));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isHair ? Colors.orange[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isHair ? Colors.orange[800] : Colors.blue[800],
        ),
      ),
    );
  }

  // --- HELPER (Unchanged) ---
  Widget _buildAddOnCard(RecommendedProduct addon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                addon.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: Icon(
                    _getAddOnIcon(addon.name),
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addon.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    addon.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${addon.price}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: brandPrimary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: brandPrimary!),
                  ),
                  child: Text(
                    addon.discountedPrice.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER (Unchanged) ---
  Widget _buildTimelineNode(IconData icon, String month, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: brandPrimary,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: brandPrimary,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          month,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 120,
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  // --- HELPER (Unchanged) ---
  IconData _getAddOnIcon(String addonName) {
    if (addonName.toLowerCase().contains('coach')) return Icons.support_agent;
    if (addonName.toLowerCase().contains('diet')) return Icons.restaurant_menu;
    if (addonName.toLowerCase().contains('doctor'))
      return Icons.medical_services;
    return Icons.card_giftcard;
  }

  // --- HELPER: UPDATED Checkout Dialog (Simpler) ---
  void _showCheckoutDialog(String finalPrice, String mrpPrice, int itemCount) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Checkout",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Order summary",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Text("$itemCount items",
                        style: const TextStyle(color: Color(0xFF666666))),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total MRP"),
                          Text("₹$mrpPrice"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Delivery charges"),
                          Text("FREE",
                              style: TextStyle(color: Color(0xFF4CAF50))),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Amount to be paid",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("₹$finalPrice",
                              style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 1. Pay Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to address screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D2D2D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Add Address & Pay ₹$finalPrice",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // 2. Cancel Button
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}