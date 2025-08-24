import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/user_session.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/admin/views/inventory_management_screen.dart';
import 'package:shop/screens/admin/views/components/admin_dashboard_card.dart';
import 'package:shop/screens/admin/views/product_list_management_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int totalProducts = 0;
  int outOfStockProducts = 0;
  int lowStockProducts = 0;

  @override
  void initState() {
    super.initState();
    _calculateStats();
  }

  void _calculateStats() {
    totalProducts = demoPopularProducts.length;
    outOfStockProducts = demoPopularProducts.where((p) => p.isOutOfStock || p.stockQuantity <= 0).length;
    lowStockProducts = demoPopularProducts.where((p) => p.stockQuantity > 0 && p.stockQuantity <= 5).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Panel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'user_view':
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    entryPointScreenRoute,
                    (route) => false,
                  );
                  break;
                case 'logout':
                  UserSession.clearSession();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    logInScreenRoute,
                    (route) => false,
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'user_view',
                child: Row(
                  children: [
                    Icon(Icons.home),
                    SizedBox(width: 8),
                    Text('Switch to User View'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: errorColor),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: errorColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: defaultPadding),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome Admin!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            UserSession.userEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: defaultPadding * 1.5),
            
            Text(
              "Dashboard Overview",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: defaultPadding),
            
            // Dashboard Cards
            Row(
              children: [
                Expanded(
                  child: AdminDashboardCard(
                    title: "Total Products",
                    value: totalProducts.toString(),
                    icon: "assets/icons/Category.svg",
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: AdminDashboardCard(
                    title: "Out of Stock",
                    value: outOfStockProducts.toString(),
                    icon: "assets/icons/Danger Circle.svg",
                    color: errorColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            
            Row(
              children: [
                Expanded(
                  child: AdminDashboardCard(
                    title: "Low Stock",
                    value: lowStockProducts.toString(),
                    icon: "assets/icons/info.svg",
                    color: warningColor,
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: AdminDashboardCard(
                    title: "In Stock",
                    value: (totalProducts - outOfStockProducts).toString(),
                    icon: "assets/icons/Doublecheck.svg",
                    color: successColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: defaultPadding * 2),
            
            Text(
              "Management Tools",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: defaultPadding),
            
            // Management Options
            _buildManagementOption(
              context,
              title: "Inventory Management",
              subtitle: "Manage product stock, quantities & availability",
              icon: "assets/icons/Category.svg",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InventoryManagementScreen(
                      onProductUpdated: () {
                        setState(() {
                          _calculateStats();
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            
            _buildManagementOption(
              context,
              title: "Product Management",
              subtitle: "Add, edit, and manage product catalog with images",
              icon: "assets/icons/Add.svg",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductListManagementScreen(),
                  ),
                ).then((_) {
                  setState(() {
                    _calculateStats();
                  });
                });
              },
            ),
            
            _buildManagementOption(
              context,
              title: "Order Management",
              subtitle: "View and manage customer orders",
              icon: "assets/icons/Order.svg",
              onTap: () {
                // Navigate to order management (to be implemented)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Order Management - Coming Soon")),
                );
              },
            ),
            
            _buildManagementOption(
              context,
              title: "Product Analytics",
              subtitle: "View sales analytics and product performance",
              icon: "assets/icons/Chart.svg",
              onTap: () {
                // Navigate to analytics (to be implemented)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Analytics - Coming Soon")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SvgPicture.asset(
              icon,
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                primaryColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ),
    );
  }
}
