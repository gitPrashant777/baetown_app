import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'dart:io';

class ProductManagementScreen extends StatefulWidget {
  final ProductModel? product; // null for new product, existing product for edit
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
  final _titleController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _maxOrderController = TextEditingController();
  
  List<String> _selectedImages = [];
  List<File> _newImageFiles = [];
  bool _isOutOfStock = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _loadProductData();
    }
  }

  void _loadProductData() {
    final product = widget.product!;
    _titleController.text = product.title;
    _brandController.text = product.brandName;
    _priceController.text = product.price.toString();
    _discountPriceController.text = product.priceAfetDiscount?.toString() ?? '';
    _stockController.text = product.stockQuantity.toString();
    _maxOrderController.text = product.maxOrderQuantity.toString();
    _selectedImages = List.from(product.images);
    _isOutOfStock = product.isOutOfStock;
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

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one image')),
        );
        return;
      }

      // Calculate discount percentage if both prices are provided
      int? discountPercent;
      double? discountPrice;
      if (_discountPriceController.text.isNotEmpty) {
        discountPrice = double.parse(_discountPriceController.text);
        double originalPrice = double.parse(_priceController.text);
        if (discountPrice < originalPrice) {
          discountPercent = ((originalPrice - discountPrice) / originalPrice * 100).round();
        }
      }

      final product = ProductModel(
        image: _selectedImages.first, // First image as main image for compatibility
        images: _selectedImages,
        title: _titleController.text,
        brandName: _brandController.text,
        price: double.parse(_priceController.text),
        priceAfetDiscount: discountPrice,
        dicountpercent: discountPercent,
        stockQuantity: int.parse(_stockController.text),
        maxOrderQuantity: int.parse(_maxOrderController.text),
        isOutOfStock: _isOutOfStock,
        productId: widget.product?.productId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      );

      // In a real app, you would save the images to a server/cloud storage
      // For demo purposes, we'll just save the product with image paths
      
      widget.onProductSaved?.call(product);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.product == null ? 'Product created successfully!' : 'Product updated successfully!'),
          backgroundColor: successColor,
        ),
      );
      
      Navigator.pop(context);
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
              
              const SizedBox(height: defaultPadding * 3),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
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
                onPressed: _pickSingleImage,
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
          onChanged: (value) {
            setState(() {
              _isOutOfStock = value;
            });
          },
          activeColor: primaryColor,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _maxOrderController.dispose();
    super.dispose();
  }
}
