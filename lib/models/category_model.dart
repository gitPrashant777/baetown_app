class CategoryModel {
  final String title;
  final String? image, svgSrc;
  final List<CategoryModel>? subCategories;

  CategoryModel({
    required this.title,
    this.image,
    this.svgSrc,
    this.subCategories,
  });
}

final List<CategoryModel> demoCategoriesWithImage = [
  CategoryModel(title: "Bridal Jewelry", image: "https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80"),
  CategoryModel(title: "Gold Collection", image: "https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80"),
  CategoryModel(title: "Kids Jewelry", image: "https://images.unsplash.com/photo-1601821765780-754fa98637c1?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80"),
  CategoryModel(title: "Jewelry Accessories", image: "https://images.unsplash.com/photo-1588444645841-9d4e0022cbd3?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80"),
];

final List<CategoryModel> demoCategories = [
  CategoryModel(
    title: "On Sale",
    svgSrc: "assets/icons/Sale.svg",
    subCategories: [
      CategoryModel(title: "All Jewelry"),
      CategoryModel(title: "Diamond Collection"),
      CategoryModel(title: "Gold Jewelry"),
      CategoryModel(title: "Silver Jewelry"),
      CategoryModel(title: "Gemstone Jewelry"),
    ],
  ),
  CategoryModel(
    title: "Rings",
    svgSrc: "assets/icons/diamond.svg",
    subCategories: [
      CategoryModel(title: "Engagement Rings"),
      CategoryModel(title: "Wedding Bands"),
      CategoryModel(title: "Diamond Rings"),
      CategoryModel(title: "Gemstone Rings"),
      CategoryModel(title: "Fashion Rings"),
    ],
  ),
  CategoryModel(
    title: "Necklaces",
    svgSrc: "assets/icons/Gift.svg",
    subCategories: [
      CategoryModel(title: "Pendant Necklaces"),
      CategoryModel(title: "Pearl Necklaces"),
      CategoryModel(title: "Chain Necklaces"),
      CategoryModel(title: "Statement Necklaces"),
      CategoryModel(title: "Chokers"),
    ],
  ),
  CategoryModel(
    title: "Earrings",
    svgSrc: "assets/icons/Accessories.svg",
    subCategories: [
      CategoryModel(title: "Stud Earrings"),
      CategoryModel(title: "Hoop Earrings"),
      CategoryModel(title: "Drop Earrings"),
      CategoryModel(title: "Pearl Earrings"),
      CategoryModel(title: "Diamond Earrings"),
    ],
  ),
  CategoryModel(
    title: "Bracelets",
    svgSrc: "assets/icons/Accessories.svg",
    subCategories: [
      CategoryModel(title: "Tennis Bracelets"),
      CategoryModel(title: "Charm Bracelets"),
      CategoryModel(title: "Bangles"),
      CategoryModel(title: "Chain Bracelets"),
      CategoryModel(title: "Cuff Bracelets"),
    ],
  ),
  CategoryModel(
    title: "Kids Jewelry",
    svgSrc: "assets/icons/Child.svg",
    subCategories: [
      CategoryModel(title: "Kids Necklaces"),
      CategoryModel(title: "Kids Earrings"),
      CategoryModel(title: "Kids Bracelets"),
      CategoryModel(title: "Hair Accessories"),
      CategoryModel(title: "Kids Rings"),
    ],
  ),
  CategoryModel(
    title: "Bridal Collection",
    svgSrc: "assets/icons/Gift.svg",
    subCategories: [
      CategoryModel(title: "Bridal Sets"),
      CategoryModel(title: "Wedding Jewelry"),
      CategoryModel(title: "Bridal Earrings"),
      CategoryModel(title: "Bridal Necklaces"),
      CategoryModel(title: "Anniversary Gifts"),
    ],
  ),
];
