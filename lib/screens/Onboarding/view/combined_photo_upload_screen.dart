import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/onboarding_data.dart';

class CombinedPhotoUploadScreen extends StatefulWidget {
  const CombinedPhotoUploadScreen({super.key});

  @override
  State<CombinedPhotoUploadScreen> createState() =>
      _CombinedPhotoUploadScreenState();
}

class _CombinedPhotoUploadScreenState extends State<CombinedPhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  // Pick an image and assign it to the correct type (skin or scalp)
  Future<void> _pickImage(ImageSource source, String type) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80, // Compress image slightly
    );

    if (pickedFile != null) {
      final data = Provider.of<OnboardingData>(context, listen: false);
      if (type == 'skin') {
        data.setSkinImage(File(pickedFile.path));
      } else if (type == 'scalp') {
        data.setScalpImage(File(pickedFile.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to data to rebuild when images are selected
    final data = Provider.of<OnboardingData>(context);
    final bool canSubmit = data.skinImage != null && data.scalpImage != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // 1. Icon
          Icon(
            Icons.camera_alt_outlined,
            color: Colors.green, // Changed to green
            size: 36,
          ),
          const SizedBox(height: 20),
          // 2. Heading
          const Text(
            "AI PHOTO ANALYSIS",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Upload clear photos for the most accurate AI analysis and kit recommendation.",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 32),

          // --- Skin Photo Upload Section ---
          _buildUploadSection(
            context: context,
            title: "Skin Photo Upload",
            description: "Detects acne, pigmentation, and fine lines.",
            imageFile: data.skinImage,
            onPickGallery: () => _pickImage(ImageSource.gallery, 'skin'),
            onPickCamera: () => _pickImage(ImageSource.camera, 'skin'),
          ),

          const SizedBox(height: 32),

          // --- Scalp Photo Upload Section ---
          _buildUploadSection(
            context: context,
            title: "Hair/Scalp Photo Upload",
            description: "Detects thinning, dryness, and dandruff.",
            imageFile: data.scalpImage,
            onPickGallery: () => _pickImage(ImageSource.gallery, 'scalp'),
            onPickCamera: () => _pickImage(ImageSource.camera, 'scalp'),
          ),

          const SizedBox(height: 48),

          // --- Submit Button ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canSubmit ? Colors.green : Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              // Disable button if both images aren't uploaded
              onPressed: canSubmit
                  ? () => data.submitPhotosAndAnalyze(context)
                  : null,
              child: Text(
                "Submit & Analyze",
                style: TextStyle(
                  color: canSubmit ? Colors.white : Colors.grey[500],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper widget for a single upload section (Skin or Scalp)
  Widget _buildUploadSection({
    required BuildContext context,
    required String title,
    required String description,
    File? imageFile,
    required VoidCallback onPickGallery,
    required VoidCallback onPickCamera,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 16),
          // Image Preview or Placeholder
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: imageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                ),
              )
                  : const Icon(Icons.image_outlined, size: 50, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text("Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.15),
                    foregroundColor: Colors.green,
                    elevation: 0,
                  ),
                  onPressed: onPickGallery,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text("Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.15),
                    foregroundColor: Colors.green,
                    elevation: 0,
                  ),
                  onPressed: onPickCamera,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}