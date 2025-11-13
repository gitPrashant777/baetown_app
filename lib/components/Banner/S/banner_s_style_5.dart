import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// Removed unused import: ../banner_discount_tag.dart

import '../../../constants.dart';
import 'banner_s.dart';

class BannerSStyle5 extends StatelessWidget {
  const BannerSStyle5({
    super.key,
    this.image = "https://t4.ftcdn.net/jpg/03/72/21/29/360_F_372212921_l0wtrUbGY168QTCIRHp1W02ug8CVuWSV.jpg",
    required this.title,
    required this.press,
    this.subtitle,
    this.bottomText,
  });
  final String? image;
  final String title;
  final String? subtitle, bottomText;

  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    // --- MODIFICATION START ---
    // Added Padding and ClipRRect
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding/2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        child: BannerS(
          image: image!,
          press: press,
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding/3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (subtitle != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding / 2,
                                vertical: defaultPadding / 8),
                            color: Colors.white70,
                            child: Text(
                              subtitle!,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        // --- MODIFICATION: Reduced spacing ---
                        const SizedBox(height: defaultPadding / 7), // Was defaultPadding / 2
                        Text(
                          title.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: grandisExtendedFont,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        if (bottomText != null)
                          Text(
                            bottomText!,
                            style: const TextStyle(
                              fontFamily: grandisExtendedFont,
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(width: defaultPadding),
                  SvgPicture.asset(
                    "assets/icons/miniRight.svg",
                    height: 30,
                    colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    // --- MODIFICATION END ---
  }
}