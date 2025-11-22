// model/ConsultantModel.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultantModel {
  final String uid;
  final String name;
  final String specialty;
  final String experienceYears;
  final String experienceLevel;
  final String qualification;
  final String licenseNumber;
  final String about;
  final double consultationFee;
  final String? profileImageUrl;
  final String? certificateUrl;
  final bool isProfileComplete;
  final bool isVerified;
  final bool isAvailable;
  final String phone; // <-- 1. ADD THIS

  ConsultantModel({
    required this.uid,
    required this.name,
    required this.specialty,
    required this.experienceYears,
    required this.experienceLevel,
    required this.qualification,
    required this.licenseNumber,
    required this.about,
    required this.consultationFee,
    this.profileImageUrl,
    this.certificateUrl,
    required this.isProfileComplete,
    required this.isVerified,
    required this.isAvailable,
    required this.phone, // <-- 2. ADD THIS
  });

  // Factory constructor to create a ConsultantModel from a Firestore document
  factory ConsultantModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ConsultantModel(
      // Use the document ID if available, otherwise look for a 'uid' field
      uid: docId ?? map['uid'] ?? '',
      name: map['name'] ?? 'Dr. Anonymous', // Provide default values
      specialty: map['specialty'] ?? 'N/A',
      experienceYears: map['experienceYears'] ?? '0',
      experienceLevel: map['experienceLevel'] ?? 'N/A',
      qualification: map['qualification'] ?? 'N/A',
      licenseNumber: map['licenseNumber'] ?? '',
      about: map['about'] ?? '',
      // Ensure consultationFee is parsed as a number (double)
      consultationFee: (map['consultationFee'] ?? 0).toDouble(),
      profileImageUrl: map['profileImageUrl'],
      certificateUrl: map['certificateUrl'],
      isProfileComplete: map['isProfileComplete'] ?? false,
      isVerified: map['isVerified'] ?? false,
      isAvailable: map['isAvailable'] ?? false,
      phone: map['phone'] ?? '', // <-- 3. ADD THIS
    );
  }

  // Method to convert a ConsultantModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'specialty': specialty,
      'experienceYears': experienceYears,
      'experienceLevel': experienceLevel,
      'qualification': qualification,
      'licenseNumber': licenseNumber,
      'about': about,
      'consultationFee': consultationFee,
      'profileImageUrl': profileImageUrl,
      'certificateUrl': certificateUrl,
      'isProfileComplete': isProfileComplete,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'phone': phone, // <-- 4. ADD THIS
    };
  }
}