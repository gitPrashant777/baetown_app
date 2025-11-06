import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/user_session.dart';
import 'package:shop/services/products_api_service.dart';
import 'package:shop/services/auth_api_service.dart';
import 'package:shop/services/api_service.dart';
import 'dart:io';
import 'dart:convert';

class ProductManagementScreen extends StatefulWidget {
  final ProductModel? product;
  final Function(ProductModel)? onProductSaved;

  const ProductManagementScreen({
    super.key,
    this.product,
    this.onProductSaved,
  });

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _stockController = TextEditingController();
  final _maxOrderController = TextEditingController();

  final ProductsApiService _productsApiService = ProductsApiService();
  final AuthApiService _authApiService = AuthApiService();
  final ApiService _apiService = ApiService();

  List<String> _selectedImages = [];
  List<File> _newImageFiles = [];
  bool _isOnSale = false;
  bool _isPopular = false;
  bool _isBestSeller = false;
  bool _isFlashSale = false;
  bool _isOutOfStock = false;
  bool _isLoading = false;
  DateTime? _flashSaleEnd;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Accessories',
    'Home & Garden',
    'Sports',
    'Books',
    'Beauty',
    'Toys',
    'Food & Beverages',
    'Other'
  ];

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _loadProductData();
    }
  }

  void _loadProductData() {
    final product = widget.product!;
    _nameController.text = product.title;
    _descriptionController.text = product.description;
    _selectedCategory = _categories.contains(product.category) ? product.category : 'Other';
    _priceController.text = product.price.toString();
    _salePriceController.text = product.priceAfetDiscount?.toString() ?? '';
    _discountController.text = product.dicountpercent?.toString() ?? '';
    _stockController.text = product.stockQuantity.toString();
    _maxOrderController.text = product.maxOrderQuantity.toString();
    _selectedImages = List.from(product.images);
    _isOutOfStock = product.isOutOfStock;
    _isOnSale = product.isOnSale ?? false;
    _isPopular = product.isPopular ?? false;
    _isBestSeller = product.isBestSeller ?? false;
    _isFlashSale = product.isFlashSale ?? false;
    _flashSaleEnd = product.flashSaleEnd;
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (images.isNotEmpty) {
        setState(() {
          for (var image in images) {
            _newImageFiles.add(File(image.path));
            _selectedImages.add(image.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<void> _pickSingleImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (image != null) {
        setState(() {
          _newImageFiles.add(File(image.path));
          _selectedImages.add(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _selectedImages.length) {
        String imagePath = _selectedImages[index];
        _selectedImages.removeAt(index);
        _newImageFiles.removeWhere((file) => file.path == imagePath);
      }
    });
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentToken = await _apiService.getAuthToken();
      if (currentToken == null) throw Exception('No authentication token found.');

      // Calculate discount if applicable
      int? discountPercent;
      double? discountPrice;
      if (_salePriceController.text.isNotEmpty) {
        double originalPrice = double.parse(_priceController.text);
        discountPrice = double.parse(_salePriceController.text);
        if (discountPrice < originalPrice) {
          discountPercent = ((originalPrice - discountPrice) / originalPrice * 100).round();
        }
      }

      final product = ProductModel(
        productId: widget.product?.productId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory ?? 'Other',
        price: double.parse(_priceController.text),
        priceAfetDiscount: discountPrice,
        dicountpercent: discountPercent,
        stockQuantity: int.parse(_stockController.text),
        maxOrderQuantity: int.tryParse(_maxOrderController.text) ?? 5,
        isOutOfStock: _isOutOfStock,
        image: _selectedImages.isNotEmpty ? _selectedImages.first : '',
        images: _selectedImages,
        isOnSale: _isOnSale,
        isPopular: _isPopular,
        isBestSeller: _isBestSeller,
        isFlashSale: _isFlashSale,
        flashSaleEnd: _flashSaleEnd,
      );

      Map<String, dynamic> result;
      if (widget.product == null) {
        result = await _productsApiService.createProduct(product);
      } else {
        result = await _productsApiService.updateProduct(widget.product!.productId!, product);
      }

      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Failed to save product');
      }

      widget.onProductSaved?.call(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null
                ? 'Product created successfully!'
                : 'Product updated successfully!'),
            backgroundColor: successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving product: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? "Add New Product" : "Edit Product",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              const WORKING_TOKEN =
                  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4YmIyNmJlNjhlMzhhZTY3ZWY3ZWQwYyIsInJvbGUiOiJhZG1pbiIsImlhdCI6MTc1NzE2MzQ5MywiZXhwIjoxNzU3NDIyNjkzfQ.Ww8X84uP0UtXZg8qL6TwrjuTpKU3f-dtyntGRHX2c2s';
              await UserSession.setAuthToken(WORKING_TOKEN);
              await UserSession.loadSession();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Token updated!')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: defaultPadding * 2),
              _buildFormFields(),
              const SizedBox(height: defaultPadding * 2),
              _buildPriceSection(),
              const SizedBox(height: defaultPadding * 2),
              _buildStockSection(),
              const SizedBox(height: defaultPadding * 3),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library, color: primaryColor),
            const SizedBox(width: 8),
            const Text('Product Images',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: defaultPadding),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _selectedImages[index].startsWith('http')
                              ? Image.network(_selectedImages[index], fit: BoxFit.cover)
                              : Image.file(File(_selectedImages[index]), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: defaultPadding),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickSingleImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Single Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(width: defaultPadding),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('Add Multiple'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, color: primaryColor),
            const SizedBox(width: 8),
            const Text('Product Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: defaultPadding),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Product Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
          value == null || value.isEmpty ? 'Please enter product name' : null,
        ),
        const SizedBox(height: defaultPadding),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Product Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) =>
          value == null || value.isEmpty ? 'Please enter description' : null,
        ),
        const SizedBox(height: defaultPadding),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: _categories
              .map((String category) =>
              DropdownMenuItem(value: category, child: Text(category)))
              .toList(),
          onChanged: (String? newValue) => setState(() => _selectedCategory = newValue),
          validator: (value) =>
          value == null || value.isEmpty ? 'Please select a category' : null,
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.currency_rupee, color: primaryColor),
            const SizedBox(width: 8),
            const Text('Pricing',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: defaultPadding),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Original Price (₹)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter price'
                    : (double.tryParse(value) == null
                    ? 'Please enter valid price'
                    : null),
              ),
            ),
            const SizedBox(width: defaultPadding),
            Expanded(
              child: TextFormField(
                controller: _salePriceController,
                decoration: const InputDecoration(
                  labelText: 'Sale Price (₹)',
                  border: OutlineInputBorder(),
                  hintText: 'Optional',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value != null &&
                    value.isNotEmpty &&
                    double.tryParse(value) == null
                    ? 'Enter valid number'
                    : null,
              ),
            ),
          ],
        ),
        CheckboxListTile(
          title: const Text('On Sale'),
          value: _isOnSale,
          onChanged: (value) => setState(() => _isOnSale = value ?? false),
          activeColor: primaryColor,
        ),
        CheckboxListTile(
          title: const Text('Popular Product'),
          value: _isPopular,
          onChanged: (value) => setState(() => _isPopular = value ?? false),
          activeColor: primaryColor,
        ),
        CheckboxListTile(
          title: const Text('Best Seller'),
          value: _isBestSeller,
          onChanged: (value) => setState(() => _isBestSeller = value ?? false),
          activeColor: primaryColor,
        ),
        CheckboxListTile(
          title: const Text('Flash Sale'),
          value: _isFlashSale,
          onChanged: (value) => setState(() => _isFlashSale = value ?? false),
          activeColor: primaryColor,
        ),
        if (_isFlashSale)
          Row(
            children: [
              Expanded(
                child: Text(
                  'Flash Sale End: ${_flashSaleEnd != null ? _flashSaleEnd!.toString().split(' ')[0] : 'Not set'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                    _flashSaleEnd ?? DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _flashSaleEnd = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: const Text('Set Date'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.inventory, color: primaryColor),
            const SizedBox(width: 8),
            const Text('Stock Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: defaultPadding),
        TextFormField(
          controller: _stockController,
          decoration: const InputDecoration(
            labelText: 'Stock Quantity',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) => value == null || value.isEmpty
              ? 'Enter stock quantity'
              : (int.tryParse(value) == null ? 'Enter valid number' : null),
        ),
        const SizedBox(height: defaultPadding),
        TextFormField(
          controller: _maxOrderController,
          decoration: const InputDecoration(
            labelText: 'Max Order Quantity',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) => value == null || value.isEmpty
              ? 'Enter max order quantity'
              : (int.tryParse(value) == null ? 'Enter valid number' : null),
        ),
        const SizedBox(height: defaultPadding),
        CheckboxListTile(
          title: const Text('Out of Stock'),
          value: _isOutOfStock,
          onChanged: (val) => setState(() => _isOutOfStock = val ?? false),
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          widget.product == null ? 'Create Product' : 'Update Product',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _maxOrderController.dispose();
    super.dispose();
  }
}
