import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/services/cart_service.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  final CartService _cartService = CartService();
  final List _pages = const [
    HomeScreen(),
    DiscoverScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  Widget _buildCartIcon(bool isActive) {
    int cartCount = _cartService.items.length;
    Color? iconColor = isActive ? primaryColor : Theme.of(context).textTheme.bodyLarge!.color!;

    return Stack(
      children: [
        SvgPicture.asset(
          "assets/icons/Bag.svg",
          height: 24,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
        if (cartCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                cartCount > 99 ? '99+' : cartCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  SvgPicture svgIcon(String src, {Color? color}) {
    return SvgPicture.asset(
      src,
      height: 24,
      colorFilter: ColorFilter.mode(
          color ??
              Theme.of(context).iconTheme.color!.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 1),
          BlendMode.srcIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // Prevent default back behavior
        onPopInvoked: (didPop) async {
          if (didPop) return;

          // Show exit confirmation dialog
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Are you sure you want to exit the app?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );

          if (shouldExit == true) {
            // Exit the app
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            // pinned: true,
            // floating: true,
            // snap: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: const SizedBox(),
            leadingWidth: 0,
            centerTitle: false,
            title: Text(
              "BAETOWN",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, searchScreenRoute);
                },
                icon: SvgPicture.asset(
                  "assets/icons/Search.svg",
                  height: 24,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).textTheme.bodyLarge!.color!,
                      BlendMode.srcIn),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, bookmarkScreenRoute);
                },
                icon: Icon(
                  Icons.favorite_border, // Heart shape icon
                  size: 24,
                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, cartScreenRoute);
                },
                icon: _buildCartIcon(false),
              ),
            ],
          ),
          // body: _pages[_currentIndex],
          body: PageTransitionSwitcher(
            duration: defaultDuration,
            transitionBuilder: (child, animation, secondAnimation) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondAnimation,
                child: child,
              );
            },
            child: _pages[_currentIndex],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.only(top: defaultPadding / 2),
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : const Color(0xFF101015),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index != _currentIndex) {
                  setState(() {
                    _currentIndex = index;
                  });
                }
              },
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : const Color(0xFF101015),
              type: BottomNavigationBarType.fixed,
              // selectedLabelStyle: TextStyle(color: primaryColor),
              selectedFontSize: 12,
              selectedItemColor: primaryColor,
              unselectedItemColor: Theme.of(context).iconTheme.color!.withOpacity(0.6),
              items: [
                BottomNavigationBarItem(
                  icon: svgIcon("assets/icons/Shop.svg"),
                  activeIcon:
                      svgIcon("assets/icons/Shop.svg", color: primaryColor),
                  label: "Shop",
                ),
                BottomNavigationBarItem(
                  icon: svgIcon("assets/icons/Category.svg"),
                  activeIcon:
                      svgIcon("assets/icons/Category.svg", color: primaryColor),
                  label: "Discover",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.6),
                  ),
                  activeIcon: Icon(
                    Icons.notifications,
                    color: primaryColor,
                  ),
                  label: "Notifications",
                ),
                BottomNavigationBarItem(
                  icon: svgIcon("assets/icons/Profile.svg"),
                  activeIcon:
                      svgIcon("assets/icons/Profile.svg", color: primaryColor),
                  label: "Profile",
                ),
              ],
            ),
          ),
        )); // PopScope closing
  }
}
