import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/onboarding_data.dart';

class AiAnalysisScreen extends StatefulWidget {
  const AiAnalysisScreen({super.key});

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  final ImagePicker _picker = ImagePicker();

  // Function to pick image and store it in OnboardingData
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      // Get the data model
      final data = Provider.of<OnboardingData>(context, listen: false);

      // Store the image file
      data.setScalpImage(File(pickedFile.path));

      // Move to the next page (which will be the loading screen)
      data.pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // 1. Icon
          Icon(
            Icons.camera_alt_outlined,
            color: Colors.grey[400],
            size: 36,
          ),
          const SizedBox(height: 20),
          // 2. Heading
          const Text(
            "SCALP IMAGE",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 40),
          // 3. Sample Image
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // You should replace this with the actual sample image
              child: Image.asset(
                'assets/images/scalp_sample.png', // Add this image to your assets
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 4. Helper Text
          const Center(
            child: Text(
              "Click a photo like the sample above",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              "This image helps doctors diagnose",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          // 5. Buttons
          // "Upload From Gallery" Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.15),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => _pickImage(ImageSource.gallery),
              child: const Text(
                "Upload From Gallery",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // "Take Scalp Photo" Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => _pickImage(ImageSource.camera),
              child: const Text(
                "Take Scalp Photo",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}