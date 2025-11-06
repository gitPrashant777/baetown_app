// lib/models/review_model.dart
class ReviewModel {
  // Based on the 'Review' JSON in your api_config.dart
  final String id;
  final String name;
  final double rating;
  final String comment;
  final String? date; // Making date optional

  ReviewModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.comment,
    this.date,
  });

  factory ReviewModel.fromApi(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Anonymous',
      rating: (json['rating'] as num? ?? 0).toDouble(),
      comment: json['comment'] as String? ?? 'No comment.',
      date: json['createdAt'] as String?, // Assuming 'createdAt'
    );
  }

  // Helper to convert the List<Map<String, dynamic>> from your service
  static List<ReviewModel> fromJsonList(List<dynamic> jsonList) {
    if (jsonList.isEmpty) {
      return [];
    }
    return jsonList
        .map((json) => ReviewModel.fromApi(json as Map<String, dynamic>))
        .toList();
  }
}