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
          // Today Section
          Text(
            "Today",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: defaultPadding),
          
          // Notification Items
          _buildNotificationItem(
            context,
            title: "Order Confirmed",
            subtitle: "Your order for Diamond Solitaire Ring has been confirmed and is being processed.",
            time: "2 hours ago",
            icon: "assets/icons/Order.svg",
            iconColor: successColor,
          ),
          
          _buildNotificationItem(
            context,
            title: "New Arrivals",
            subtitle: "Check out our latest bridal collection with stunning engagement rings.",
            time: "4 hours ago",
            icon: "assets/icons/Gift.svg",
            iconColor: primaryColor,
          ),
          
          const SizedBox(height: defaultPadding),
          
          // Yesterday Section
          Text(
            "Yesterday",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: defaultPadding),
          
          _buildNotificationItem(
            context,
            title: "Flash Sale Alert",
            subtitle: "30% off on all gold necklaces. Limited time offer ending soon!",
            time: "1 day ago",
            icon: "assets/icons/Discount.svg",
            iconColor: warningColor,
          ),
          
          _buildNotificationItem(
            context,
            title: "Wishlist Update",
            subtitle: "Pearl Drop Earrings from your wishlist is now available with discount.",
            time: "1 day ago",
            icon: "assets/icons/Wishlist.svg",
            iconColor: primaryColor,
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
          
          _buildNotificationItem(
            context,
            title: "Welcome to BAETOWN",
            subtitle: "Thank you for joining BAETOWN! Explore our premium jewelry collection.",
            time: "3 days ago",
            icon: "assets/icons/Gift.svg",
            iconColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String time,
    required String icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: defaultPadding),
      padding: const EdgeInsets.all(defaultPadding),
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
      child: Row(
        children: [
          // Icon
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(
                  iconColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: defaultPadding),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
