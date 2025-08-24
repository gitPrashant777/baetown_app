import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/admin/views/components/inventory_product_card.dart';
import 'package:shop/screens/admin/views/components/stock_update_dialog.dart';
import 'package:shop/screens/admin/views/product_management_screen.dart';

class InventoryManagementScreen extends StatefulWidget {
  final VoidCallback? onProductUpdated;

  const InventoryManagementScreen({
    super.key,
    this.onProductUpdated,
  });

  @override
  State<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  List<ProductModel> products = List.from(demoPopularProducts);
  String selectedFilter = 'All';
  final List<String> filterOptions = ['All', 'In Stock', 'Out of Stock', 'Low Stock'];

  List<ProductModel> get filteredProducts {
    switch (selectedFilter) {
      case 'In Stock':
        return products.where((p) => !p.isOutOfStock && p.stockQuantity > 5).toList();
      case 'Out of Stock':
        return products.where((p) => p.isOutOfStock || p.stockQuantity <= 0).toList();
      case 'Low Stock':
        return products.where((p) => p.stockQuantity > 0 && p.stockQuantity <= 5).toList();
      default:
        return products;
    }
  }

  void _updateProductStock(ProductModel product, int newStock, int newMaxOrder, bool outOfStock) {
    setState(() {
      int index = products.indexWhere((p) => p.productId == product.productId);
      if (index != -1) {
        products[index] = product.copyWith(
          stockQuantity: newStock,
          maxOrderQuantity: newMaxOrder,
          isOutOfStock: outOfStock,
        );
        
        // Update the global demo list as well
        int globalIndex = demoPopularProducts.indexWhere((p) => p.productId == product.productId);
        if (globalIndex != -1) {
          demoPopularProducts[globalIndex] = products[index];
        }
      }
    });
    
    widget.onProductUpdated?.call();
  }

  void _showStockUpdateDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => StockUpdateDialog(
        product: product,
        onUpdate: _updateProductStock,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Inventory Management",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Filter Products",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: defaultPadding / 2),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filterOptions.map((filter) {
                      bool isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          selectedColor: primaryColor.withOpacity(0.2),
                          checkmarkColor: primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? primaryColor : null,
                            fontWeight: isSelected ? FontWeight.w600 : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Products List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/Category.svg",
                          height: 64,
                          width: 64,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).disabledColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        Text(
                          "No products found",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(defaultPadding),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: defaultPadding),
                        child: InventoryProductCard(
                          product: product,
                          onTap: () => _showStockUpdateDialog(product),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductManagementScreen(
                onProductSaved: (product) {
                  setState(() {
                    products.add(product);
                    demoPopularProducts.add(product); // Update global list
                  });
                  widget.onProductUpdated?.call();
                },
              ),
            ),
          );
        },
        backgroundColor: primaryColor,
        label: const Text(
          "Add Product",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
