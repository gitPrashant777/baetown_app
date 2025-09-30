import 'package:flutter/material.dart';
import '/components/network_image_with_loader.dart';

import '../../../../constants.dart';

class ProductImages extends StatefulWidget {
  const ProductImages({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  State<ProductImages> createState() => _ProductImagesState();
}

class _ProductImagesState extends State<ProductImages> {
  late PageController _controller;

  int _currentPage = 0;

  @override
  void initState() {
    _controller =
        PageController(viewportFraction: 0.9, initialPage: _currentPage);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AspectRatio(
        aspectRatio: 1,
        child: Builder(
          builder: (context) {
            final filteredImages = widget.images.where((img) {
              final url = img.trim().toLowerCase();
              final isValidUrl = url.startsWith('http://') || url.startsWith('https://');
              final isCloudinary = url.contains('cloudinary');
              return isValidUrl && url.isNotEmpty && isCloudinary;
            }).toList();
            if (filteredImages.isEmpty) {
              return ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(defaultBorderRadious * 2),
                ),
                child: Container(
                  color: Colors.grey.withOpacity(0.2),
                  child: Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey, size: 48),
                  ),
                ),
              );
            }
            return Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: filteredImages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(defaultBorderRadious * 2),
                      ),
                      child: NetworkImageWithLoader(
                        filteredImages[index],
                        fit: BoxFit.cover,
                        radius: defaultBorderRadious * 2,
                      ),
                    );
                  },
                ),
                if (filteredImages.length > 1)
                  Positioned(
                    height: 20,
                    bottom: 24,
                    right: MediaQuery.of(context).size.width * 0.15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.all(Radius.circular(50)),
                      ),
                      child: Row(
                        children: List.generate(
                          filteredImages.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(
                                right: index == (filteredImages.length - 1)
                                    ? 0
                                    : defaultPadding / 4),
                            child: CircleAvatar(
                              radius: 3,
                              backgroundColor: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withOpacity(index == _currentPage ? 1 : 0.2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
