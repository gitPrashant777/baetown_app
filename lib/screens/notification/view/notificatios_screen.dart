import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/DotsV.svg",
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color!,
                BlendMode.srcIn,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          // Recent Section
          Text(
            "Recent",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: defaultPadding),
          
          // Notification Items
          _buildNotificationCard(
            context,
            title: "Order Confirmed",
            subtitle: "Your order for Diamond Solitaire Ring has been confirmed and is being processed.",
            time: "2 hours ago",
            icon: Icons.shopping_bag_outlined,
            iconColor: successColor,
            isUnread: true,
          ),
          
          _buildNotificationCard(
            context,
            title: "Flash Sale Alert",
            subtitle: "Up to 70% off on selected jewelry items. Limited time offer ending soon!",
            time: "4 hours ago",
            icon: Icons.local_fire_department_outlined,
            iconColor: warningColor,
            isUnread: true,
          ),
          
          _buildNotificationCard(
            context,
            title: "Wishlist Update",
            subtitle: "The item 'Gold Chain Bracelet' you wishlisted is now back in stock.",
            time: "1 day ago",
            icon: Icons.favorite_outline,
            iconColor: primaryColor,
            isUnread: false,
          ),
          
          const SizedBox(height: defaultPadding),
          
          // Earlier Section
          Text(
            "Earlier",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: defaultPadding),
          
          _buildNotificationCard(
            context,
            title: "New Arrivals",
            subtitle: "Check out our latest collection of premium watches and accessories.",
            time: "3 days ago",
            icon: Icons.star_outline,
            iconColor: Colors.amber,
            isUnread: false,
          ),
          
          _buildNotificationCard(
            context,
            title: "Payment Successful",
            subtitle: "Your payment for order #12345 has been processed successfully.",
            time: "5 days ago",
            icon: Icons.check_circle_outline,
            iconColor: successColor,
            isUnread: false,
          ),
          
          _buildNotificationCard(
            context,
            title: "Delivery Update",
            subtitle: "Your order has been shipped and will arrive within 2-3 business days.",
            time: "1 week ago",
            icon: Icons.local_shipping_outlined,
            iconColor: Colors.blue,
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(defaultPadding),
        leading: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          // Handle notification tap
        },
      ),
    );
  }
}
