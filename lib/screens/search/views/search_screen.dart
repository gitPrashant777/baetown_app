import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/components/network_image_with_loader.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> searchResults = [];
  List<String> recentSearches = ['Diamond Ring', 'Gold Necklace', 'Pearl Earrings'];
  bool isSearching = false;
  String selectedCategory = 'All';
  
  final List<String> categories = ['All', 'Rings', 'Necklaces', 'Earrings', 'Bracelets', 'Bridal'];
  
  final List<String> popularSearches = [
    'Diamond Ring',
    'Gold Necklace', 
    'Pearl Earrings',
    'Wedding Bands',
    'Tennis Bracelet',
    'Bridal Set',
    'Gemstone Ring',
    'Silver Chain'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      // Filter products based on search query
      searchResults = demoPopularProducts.where((product) {
        return product.title.toLowerCase().contains(query.toLowerCase()) ||
               product.brandName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });

    // Add to recent searches if not already present
    if (!recentSearches.contains(query)) {
      setState(() {
        recentSearches.insert(0, query);
        if (recentSearches.length > 5) {
          recentSearches.removeLast();
        }
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchResults = [];
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search jewelry...',
              prefixIcon: Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, size: 20),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onChanged: _performSearch,
            onSubmitted: _performSearch,
          ),
        ),
      ),
      body: Column(
        children: [
          // Categories Filter
          if (!isSearching)
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = category;
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
                },
              ),
            ),

          Expanded(
            child: isSearching
                ? _buildSearchResults()
                : _buildDefaultContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return Center(
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
            SizedBox(height: defaultPadding),
            Text(
              'No jewelry found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching for rings, necklaces, or earrings',
              style: TextStyle(
                color: Theme.of(context).disabledColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Text(
            '${searchResults.length} ${searchResults.length == 1 ? 'result' : 'results'} found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: defaultPadding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: defaultPadding,
              mainAxisSpacing: defaultPadding,
            ),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              return ProductCard(
                image: searchResults[index].image,
                brandName: searchResults[index].brandName,
                title: searchResults[index].title,
                price: searchResults[index].price,
                priceAfetDiscount: searchResults[index].priceAfetDiscount,
                dicountpercent: searchResults[index].dicountpercent,
                press: () {
                  // Navigate to product details
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      recentSearches.clear();
                    });
                  },
                  child: Text('Clear All'),
                ),
              ],
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentSearches.map((search) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, size: 16),
                        SizedBox(width: 4),
                        Text(search),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: defaultPadding * 2),
          ],

          // Popular Searches
          Text(
            'Popular Searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: defaultPadding),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popularSearches.map((search) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, size: 16, color: primaryColor),
                      SizedBox(width: 4),
                      Text(
                        search,
                        style: TextStyle(color: primaryColor),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: defaultPadding * 2),

          // Search Suggestions
          Text(
            'Browse by Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: defaultPadding),
          
          _buildCategoryCard('Engagement Rings', 'assets/icons/diamond.svg', 'Find the perfect symbol of love'),
          _buildCategoryCard('Wedding Jewelry', 'assets/icons/Gift.svg', 'Complete your special day'),
          _buildCategoryCard('Fashion Jewelry', 'assets/icons/Accessories.svg', 'Everyday elegance'),
          _buildCategoryCard('Luxury Collection', 'assets/icons/Gift.svg', 'Premium designer pieces'),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, String icon, String subtitle) {
    return Container(
      margin: EdgeInsets.only(bottom: defaultPadding),
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(
                  primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(width: defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
