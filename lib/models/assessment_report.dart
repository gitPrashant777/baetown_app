// lib/models/assessment_report.dart
import 'package:flutter/material.dart';

// Helper function to map Icon names (strings) from Gemini to real Flutter Icons
IconData getIconData(String? iconName) {
  // A map of common icons you use in your app
  const Map<String, IconData> iconMap = {
    "health_and_safety": Icons.health_and_safety,
    "waves": Icons.waves,
    "grass": Icons.grass,
    "local_fire_department": Icons.local_fire_department_outlined,
    "work_outline": Icons.work_outline,
    "sentiment_dissatisfied": Icons.sentiment_dissatisfied_outlined,
    "opacity": Icons.opacity_outlined,
    "highlight_off": Icons.highlight_off,
    "default": Icons.help_outline, // Added a default
  };
  // Use a default icon if the name is null or not in the map
  return iconMap[iconName?.toLowerCase()] ?? Icons.help_outline;
}

class RecommendedProduct {
  final String name;
  final String tag;
  final String description;
  final String price;
  final String discountedPrice;
  final String imageUrl;

  RecommendedProduct({
    required this.name,
    required this.tag,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.imageUrl,
  });

  // --- UPDATED: Safer 'fromJson' ---
  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      name: json['name'] as String? ?? 'Unnamed Product', // Default name
      tag: json['tag'] as String? ?? '', // Default to empty tag
      description: json['description'] as String? ?? 'No description available.',
      price: json['price'] as String? ?? '0',
      discountedPrice: json['discountedPrice'] as String? ?? '0',
      imageUrl: json['imageUrl'] as String? ?? 'assets/images/placeholder.png',
    );
  }
}

class RootCause {
  final String name;
  final IconData icon;
  final String description;

  RootCause({
    required this.name,
    required this.icon,
    required this.description,
  });

  // --- UPDATED: Safer 'fromJson' ---
  factory RootCause.fromJson(Map<String, dynamic> json) {
    return RootCause(
      name: json['name'] as String? ?? 'Unknown Cause',
      icon: getIconData(json['iconName'] as String?), // Use safer icon getter
      description: json['description'] as String? ?? 'No details available.',
    );
  }
}

class AssessmentReport {
  // (Fields remain the same)
  final String hairDiagnosis;
  final String hairTimeline;
  final int regrowthPossibility;
  final List<RootCause> hairRootCauses;
  final List<RecommendedProduct> recommendedHairKit;
  final String skinDiagnosis;
  final String skinTimeline;
  final List<RootCause> skinRootCauses;
  final List<RecommendedProduct> recommendedSkinKit;
  final List<RecommendedProduct> freeAddOns;
  final String totalPrice;
  final String discountedTotalPrice;

  AssessmentReport({
    required this.hairDiagnosis,
    required this.hairTimeline,
    required this.regrowthPossibility,
    required this.hairRootCauses,
    required this.recommendedHairKit,
    required this.skinDiagnosis,
    required this.skinTimeline,
    required this.skinRootCauses,
    required this.recommendedSkinKit,
    required this.freeAddOns,
    required this.totalPrice,
    required this.discountedTotalPrice,
  });

  // --- UPDATED: Safer 'fromJson' ---
  factory AssessmentReport.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse lists (handles null or empty lists)
    List<T> parseList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      final list = json[key] as List<dynamic>?; // Check for null list
      if (list == null) {
        return []; // Return an empty list if key is missing
      }
      return list
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return AssessmentReport(
      // Hair
      hairDiagnosis: json['hairDiagnosis'] as String? ?? 'Analysis Incomplete',
      hairTimeline: json['hairTimeline'] as String? ?? 'N/A',
      regrowthPossibility: json['regrowthPossibility'] as int? ?? 0,
      hairRootCauses: parseList('hairRootCauses', RootCause.fromJson),
      recommendedHairKit:
      parseList('recommendedHairKit', RecommendedProduct.fromJson),

      // Skin
      skinDiagnosis: json['skinDiagnosis'] as String? ?? 'Analysis Incomplete',
      skinTimeline: json['skinTimeline'] as String? ?? 'N/A',
      skinRootCauses: parseList('skinRootCauses', RootCause.fromJson),
      recommendedSkinKit:
      parseList('recommendedSkinKit', RecommendedProduct.fromJson),

      // Common
      freeAddOns: parseList('freeAddOns', RecommendedProduct.fromJson),
      totalPrice: json['totalPrice'] as String? ?? '0',
      discountedTotalPrice:
      json['discountedTotalPrice'] as String? ?? '0',
    );
  }
}