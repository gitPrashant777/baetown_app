import 'package:flutter/material.dart';
import '../../../../constants.dart';

// A list of images for the carousel
const List<String> heroImages = [
  "https://www.meglow.in/cdn/shop/files/MeglowWomenBeautyComboCREAMFACEWASHPEEOFF1.png?v=1729852151", // Original image
  "https://www.jiomart.com/images/product/original/rvwdircgyo/meglow-anti-aging-combo-pack-of-2-meglow-anti-ageing-cream-30-gm-with-skin-brightening-cream-for-women-spf-15-50-gm-for-hydrating-toning-rejuvenating-dull-skin-product-images-orvwdircgyo-p602941253-0-202307051210.jpg?im=Resize=(420,420)", // Your image
  "https://www.meglow.in/cdn/shop/files/01_Combo.jpg?v=1735824475" // Third image
];

class OffersCarousel extends StatefulWidget {
  const OffersCarousel({
    super.key,
  });

  @override
  State<OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<OffersCarousel> {
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Height for the hero banner
    double heroHeight = MediaQuery.of(context).size.height * 0.6;

    // Style for the vertical text
    final verticalTextStyle = TextStyle(
      color: whiteColor.withOpacity(0.8), // Base color (will be overridden)
      fontFamily: kSansSerifFont,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
      fontSize: 12,
    );

    return Container(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        children: [
          // --- 1. Horizontally Scrolling Images ---
          PageView.builder(
            controller: _pageController,
            itemCount: heroImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(heroImages[index]),
                  ),
                ),
              );
            },
          ),

          // Content on top of the image
          Positioned(
            bottom: defaultPadding * 2,
            left: defaultPadding,
            right: defaultPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: defaultPadding / 2),
                Text(
                  "MIDNIGHT \nLOTION",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontFamily: kSerifFont, // The new Serif font
                    color: Color(0xFF06055c),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: defaultPadding / 2),
                Text(
                  "55€", // Price
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: kSerifFont,
                    color: Color(0xFF06055c),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                // --- 2. Dot Indicators ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  child: Row(
                    children: List.generate(
                      heroImages.length,
                          (index) => _buildDot(isActive: index == _currentPage),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- 3. Arrow on the right side ---
          Positioned(
            bottom: defaultPadding * 2,
            right: defaultPadding,
            child: IconButton(
              icon:
              const Icon(Icons.arrow_forward, color: Color(0xFF06055c), size: 28),
              onPressed: () {
                if (_currentPage < heroImages.length - 1) {
                  _pageController.nextPage(
                    duration: defaultDuration,
                    curve: Curves.ease,
                  );
                } else {
                  _pageController.animateToPage(
                    0,
                    duration: defaultDuration,
                    curve: Curves.ease,
                  );
                }
              },
            ),
          ),

          // --- 4. Vertical text on the right (UPDATED) ---
          Positioned(
            right: defaultPadding / 2,
            top: 0,
            bottom: defaultPadding * 10, // Leave space for bottom elements
            child: RotatedBox(
              quarterTurns: 1, // Rotates the Column vertically
              child: Row( // This Row acts like a Column due to RotatedBox
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width:45),

                  _buildVerticalLabel("Flash Sale", style: verticalTextStyle),
                  // --- GAP INCREASED ---
                  const SizedBox(width: defaultPadding * 1),
                  _buildVerticalLabel("50% offer", style: verticalTextStyle),
                  // --- GAP INCREASED ---

                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper widget for the vertical labels
  Widget _buildVerticalLabel(String text, {required TextStyle style}) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 4),
      decoration: BoxDecoration(
        color: Color(0xFF06055c), // Your dark blue color
        borderRadius:
        BorderRadius.circular(defaultBorderRadious),
      ),
      child: Text(
        text,
        style: style.copyWith(
            color: whiteColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Helper widget for the dots
  Widget _buildDot({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(right: defaultPadding / 4),
      height: 4,
      width: isActive ? 24 : 12, // Active dot is longer
      decoration: BoxDecoration(
        // Use the 'isActive' boolean to select the color
        color: isActive ? Color(0xFF06055c) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}