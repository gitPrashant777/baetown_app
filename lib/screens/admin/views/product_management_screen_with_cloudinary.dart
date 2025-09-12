import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/simple_token_manager.dart';
import 'package:shop/services/cloudinary_service.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';

class ProductManagementScreenWithCloudinary extends StatefulWidget {
  final ProductModel? product; // null for new product, existing product for edit
  final Function(ProductModel)? onProductSaved;

  const ProductManagementScreenWithCloudinary({
    super.key,
    this.product,
    this.onProductSaved,
  });

  @override
  State<ProductManagementScreenWithCloudinary> createState() => _ProductManagementScreenWithCloudinaryState();
}

class _ProductManagementScreenWithCloudinaryState extends State<ProductManagementScreenWithCloudinary> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _maxOrderController = TextEditingController();
  
  List<String> _selectedImages = [];
  List<File> _newImageFiles = [];
  bool _isOutOfStock = false;
  bool _isLoading = false;
  
  // Category selection
  String _selectedCategory = 'Electronics';
  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Shoes',
    'Accessories',
    'Books',
    'Sports',
    'Home & Garden',
    'Health & Beauty',
    'Toys',
    'Food & Beverages',
    'Other',
  ];
  
  // New product flags
  bool _isOnSale = false;
  bool _isPopular = false;
  bool _isBestSeller = false;
  bool _isFlashSale = false;
  DateTime? _flashSaleEnd;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _loadProductData();
    } else {
      // Set default values for new product
      _maxOrderController.text = '5';
    }
  }

  void _loadProductData() {
    final product = widget.product!;
    _titleController.text = product.title;
    _brandController.text = product.brandName ?? "BAETOWN";
    _descriptionController.text = product.description ?? '';
    _selectedCategory = product.category ?? 'Electronics';
    _priceController.text = product.price.toString();
    _discountPriceController.text = product.priceAfetDiscount?.toString() ?? '';
    _stockController.text = product.stockQuantity.toString();
    _maxOrderController.text = product.maxOrderQuantity.toString();
    _selectedImages = List.from(product.images);
    _isOutOfStock = product.isOutOfStock;
    
    // Load new fields if they exist in the product model
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
            _selectedImages.add(image.path); // For display purposes
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
        
        // Also remove from new files if it's a new file
        _newImageFiles.removeWhere((file) => file.path == imagePath);
      }
    });
  }

  Future<List<String>> _uploadImagesToCloudinary() async {
    List<String> uploadedUrls = [];
    
    if (_newImageFiles.isEmpty) {
      print('📷 No new images to upload');
      return uploadedUrls;
    }
    
    try {
      print('☁️ Starting Cloudinary upload for ${_newImageFiles.length} images...');
      
      // Show upload progress
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploading ${_newImageFiles.length} images to Cloudinary...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Upload images to Cloudinary
      final uploadResults = await CloudinaryService.uploadMultipleImages(
        _newImageFiles,
        folder: 'products',
        imageType: 'product',
        onProgress: (completed, total) {
          print('📤 Upload progress: $completed/$total');
        },
      );
      
      // Extract URLs from successful uploads
      for (var result in uploadResults) {
        uploadedUrls.add(result.secureUrl);
        print('✅ Uploaded: ${result.secureUrl}');
      }
      
      print('🎉 Successfully uploaded ${uploadedUrls.length} images to Cloudinary');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully uploaded ${uploadedUrls.length} images!'),
            backgroundColor: successColor,
          ),
        );
      }
      
    } catch (e) {
      print('❌ Error uploading images to Cloudinary: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading images: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
      // Don't throw the error, continue with product creation without images
    }
    
    return uploadedUrls;
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // 1. First upload images to Cloudinary
        print('🚀 Step 1: Uploading images to Cloudinary...');
        final cloudinaryUrls = await _uploadImagesToCloudinary();
        
        // 2. Combine existing images with newly uploaded ones
        List<String> allImageUrls = [];
        
        // Add existing images (URLs that start with http)
        for (String imagePath in _selectedImages) {
          if (imagePath.startsWith('http')) {
            allImageUrls.add(imagePath);
          }
        }
        
        // Add newly uploaded Cloudinary URLs
        allImageUrls.addAll(cloudinaryUrls);
        
        // If no images, add a placeholder
        if (allImageUrls.isEmpty) {
          allImageUrls.add('https://via.placeholder.com/400x400/CCCCCC/FFFFFF?text=No+Image');
        }
        
        print('📷 Total images for product: ${allImageUrls.length}');
        allImageUrls.forEach((url) => print('  - $url'));
        
        // 3. Get authentication token
        print('🔐 Step 2: Getting authentication token...');
        final directToken = SimpleTokenManager.getDirectToken();
        final isDirectAdmin = SimpleTokenManager.isDirectAdmin();
        
        if (directToken == null || !isDirectAdmin) {
          throw Exception('Admin authentication required. Please log in again.');
        }

        // 4. Create product data with Cloudinary image URLs
        print('📦 Step 3: Creating product data...');
        Map<String, dynamic> productData = {
          'name': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'category': _selectedCategory,
          'price': double.parse(_priceController.text),
          'stock': int.parse(_stockController.text),
          'maxOrderQuantity': int.parse(_maxOrderController.text),
          'images': allImageUrls, // Use Cloudinary URLs
          'isOutOfStock': _isOutOfStock,
          
          // New product flags
          'isOnSale': _isOnSale,
          'isPopular': _isPopular,
          'isBestSeller': _isBestSeller,
          'isFlashSale': _isFlashSale,
        };

        // Add flash sale end date if flash sale is enabled
        if (_isFlashSale && _flashSaleEnd != null) {
          print('📅 Flash sale end date before conversion: $_flashSaleEnd');
          print('📅 Flash sale end date type: ${_flashSaleEnd.runtimeType}');
          
          // Validate that _flashSaleEnd is actually a DateTime
          if (_flashSaleEnd is DateTime) {
            final flashSaleEndString = _flashSaleEnd!.toIso8601String();
            print('📅 Flash sale end date ISO string: $flashSaleEndString');
            productData['flashSaleEnd'] = flashSaleEndString;
          } else {
            print('❌ Error: _flashSaleEnd is not a DateTime: ${_flashSaleEnd.runtimeType}');
            print('❌ Invalid value: $_flashSaleEnd');
            // Reset the invalid value
            setState(() {
              _flashSaleEnd = null;
            });
            throw Exception('Invalid flash sale end date. Please select a valid date and time.');
          }
        } else if (_isFlashSale) {
          print('⚠️ Flash sale is enabled but no end date is set');
        }

        print('📦 Final product data: $productData');

        // Add optional fields
        if (_discountPriceController.text.isNotEmpty) {
          double discountPrice = double.parse(_discountPriceController.text);
          double originalPrice = double.parse(_priceController.text);
          productData['salePrice'] = discountPrice;
          if (discountPrice < originalPrice) {
            productData['discount'] = ((originalPrice - discountPrice) / originalPrice * 100).round();
          }
        } else {
          productData['salePrice'] = double.parse(_priceController.text) * 0.9; // 10% discount
          productData['discount'] = 10;
        }

        print('🎯 Step 4: Creating product with ${allImageUrls.length} images...');
        Map<String, dynamic> result = await _createProductDirectAPI(productData, directToken);
        
        if (!result['success']) {
          throw Exception(result['message'] ?? 'Failed to create product');
        }
        
        print('✅ Product created successfully with Cloudinary images!');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product created successfully with ${allImageUrls.length} images!'),
              backgroundColor: successColor,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print('❌ Error creating product: $e');
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating product: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Map<String, dynamic>> _createProductDirectAPI(Map<String, dynamic> productData, String token) async {
    try {
      final dio = Dio();
      
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': '*/*',
      };
      
      print('🌐 Creating product with data: ${jsonEncode(productData)}');
      
      final response = await dio.post(
        'https://mern-backend-t3h8.onrender.com/api/v1/admin/product',
        data: productData,
        options: Options(
          headers: headers,
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'product': response.data['product'],
          'message': 'Product created successfully'
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create product: ${response.statusMessage}'
        };
      }
    } catch (e) {
      print('❌ API Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
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
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProduct,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images Section
              _buildImageSection(),
              
              const SizedBox(height: defaultPadding * 2),
              
              // Product Information
              _buildProductInfoSection(),
              
              const SizedBox(height: defaultPadding * 2),
              
              // Pricing Section
              _buildPricingSection(),
              
              const SizedBox(height: defaultPadding * 2),
              
              // Inventory Section
              _buildInventorySection(),
              
              const SizedBox(height: defaultPadding * 2),
              
              // Product Flags Section
              _buildProductFlagsSection(),
              
              const SizedBox(height: defaultPadding * 3),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.product == null ? 'Create Product' : 'Update Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
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
            Text(
              "Product Images",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
        
        // Image Grid
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _selectedImages[index].startsWith('http')
                          ? Image.network(
                              _selectedImages[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.error, color: Colors.red),
                                );
                              },
                            )
                          : Image.file(
                              File(_selectedImages[index]),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                  ),
                  // Remove button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: errorColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  // Main image indicator
                  if (index == 0)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Main',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        
        const SizedBox(height: defaultPadding),
        
        // Add Images Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickSingleImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Single Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickImages,
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

  Widget _buildProductInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              "Product Information",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
        
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Product Title',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter product title';
            }
            return null;
          },
        ),
        
        const SizedBox(height: defaultPadding),
        
        TextFormField(
          controller: _brandController,
          decoration: const InputDecoration(
            labelText: 'Brand Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter brand name';
            }
            return null;
          },
        ),
        
        const SizedBox(height: defaultPadding),
        
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Product Description',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
            hintText: 'Enter detailed product description...',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter product description';
            }
            return null;
          },
        ),
        
        const SizedBox(height: defaultPadding),
        
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: _isLoading ? null : (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCategory = newValue;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.currency_rupee, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              "Pricing",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid price';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: defaultPadding),
            Expanded(
              child: TextFormField(
                controller: _discountPriceController,
                decoration: const InputDecoration(
                  labelText: 'Discount Price (₹)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_offer),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    double? discountPrice = double.tryParse(value);
                    double? originalPrice = double.tryParse(_priceController.text);
                    if (discountPrice == null) {
                      return 'Please enter valid price';
                    }
                    if (originalPrice != null && discountPrice >= originalPrice) {
                      return 'Discount price must be less than original price';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.inventory, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              "Inventory",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
        
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter valid number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: defaultPadding),
            Expanded(
              child: TextFormField(
                controller: _maxOrderController,
                decoration: const InputDecoration(
                  labelText: 'Max Order Quantity',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_cart),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter max order quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter valid number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: defaultPadding),
        
        SwitchListTile(
          title: const Text('Out of Stock'),
          subtitle: const Text('Mark this product as out of stock'),
          value: _isOutOfStock,
          onChanged: _isLoading ? null : (value) {
            setState(() {
              _isOutOfStock = value;
            });
          },
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildProductFlagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flag, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              "Product Flags",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
        
        // On Sale Flag
        SwitchListTile(
          title: const Text('On Sale'),
          subtitle: const Text('Mark this product as on sale'),
          value: _isOnSale,
          onChanged: _isLoading ? null : (value) {
            setState(() {
              _isOnSale = value;
            });
          },
          activeColor: primaryColor,
        ),
        
        // Popular Flag
        SwitchListTile(
          title: const Text('Popular'),
          subtitle: const Text('Mark this product as popular'),
          value: _isPopular,
          onChanged: _isLoading ? null : (value) {
            setState(() {
              _isPopular = value;
            });
          },
          activeColor: primaryColor,
        ),
        
        // Best Seller Flag
        SwitchListTile(
          title: const Text('Best Seller'),
          subtitle: const Text('Mark this product as best seller'),
          value: _isBestSeller,
          onChanged: _isLoading ? null : (value) {
            setState(() {
              _isBestSeller = value;
            });
          },
          activeColor: primaryColor,
        ),
        
        // Flash Sale Flag
        SwitchListTile(
          title: const Text('Flash Sale'),
          subtitle: const Text('Mark this product as flash sale'),
          value: _isFlashSale,
          onChanged: _isLoading ? null : (value) {
            setState(() {
              _isFlashSale = value;
              if (!value) {
                _flashSaleEnd = null; // Clear flash sale end date if disabled
              }
            });
          },
          activeColor: primaryColor,
        ),
        
        // Flash Sale End Date (only show when flash sale is enabled)
        if (_isFlashSale) ...[
          const SizedBox(height: defaultPadding),
          GestureDetector(
            onTap: _isLoading ? null : () async {
              try {
                print('🗓️ Opening date picker for flash sale end date...');
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _flashSaleEnd ?? DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                
                if (pickedDate != null) {
                  print('📅 Date selected: $pickedDate');
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_flashSaleEnd ?? DateTime.now()),
                  );
                  
                  if (pickedTime != null) {
                    print('⏰ Time selected: $pickedTime');
                    final newDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    print('🎯 Setting flash sale end date: $newDateTime');
                    setState(() {
                      // Ensure we're setting a DateTime object
                      if (newDateTime is DateTime) {
                        _flashSaleEnd = newDateTime;
                      } else {
                        print('❌ Error: newDateTime is not a DateTime object: ${newDateTime.runtimeType}');
                      }
                    });
                    print('✅ Flash sale end date set successfully: $_flashSaleEnd');
                  }
                }
              } catch (e) {
                print('❌ Error setting flash sale end date: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error setting date: $e')),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: primaryColor),
                  const SizedBox(width: defaultPadding),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Flash Sale End Date & Time',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _flashSaleEnd != null && _flashSaleEnd is DateTime
                          ? '${_flashSaleEnd!.day}/${_flashSaleEnd!.month}/${_flashSaleEnd!.year} at ${_flashSaleEnd!.hour}:${_flashSaleEnd!.minute.toString().padLeft(2, '0')}'
                          : 'Tap to select date & time',
                        style: TextStyle(
                          color: (_flashSaleEnd != null && _flashSaleEnd is DateTime) ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _maxOrderController.dispose();
    super.dispose();
  }
}
