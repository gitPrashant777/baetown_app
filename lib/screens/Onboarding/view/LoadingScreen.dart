// LoadingScreen.dart - Updated
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/assessment_report.dart';
import '../../../models/onboarding_data.dart';
// Make sure this import path is correct for your project
import '../../../services/gemini.dart';
import 'assessment_report_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _runAnalysisAndNavigate();
  }

  Future<void> _runAnalysisAndNavigate() async {
    final data = Provider.of<OnboardingData>(context, listen: false);
    final geminiService = GeminiService();

    try {
      final AssessmentReport report = await geminiService.getAssessmentFromGemini(data);

      // --- FIX IS HERE (Line 1) ---
      final String userName = data.nameController.text;
      final String userAge = data.ageController.text;
      // Get the gender from the onboarding data
      final String selectedGender = data.selectedGender ?? 'Male'; // Default to 'Male' if null
      // --- END FIX ---

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            // --- AND HERE (Line 2) ---
            builder: (context) => AssessmentReportScreen(
              userName: userName,
              userAge: userAge,
              assessmentReport: report,
              selectedGender: selectedGender, // Pass the gender
            ),
            // --- END FIX ---
          ),
        );
      }
    } catch (e) {
      print("Error fetching assessment: $e");
      if (mounted) {
        // Also pop on error
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                size: 80,
                color: Colors.grey[800],
              ),
              const SizedBox(height: 32),
              const Text(
                "Customising your plan ...",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              _buildChecklistItem("Analysing your responses", true),
              const SizedBox(height: 16),
              _buildChecklistItem("Diagnosing hair loss", true),
              const SizedBox(height: 16),
              _buildChecklistItem("Building recommendations", false),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String text, bool isCompleted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isCompleted ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    );
  }
}