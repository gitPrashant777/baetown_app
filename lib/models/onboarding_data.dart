import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/Onboarding/view/LoadingScreen.dart';

// A simple class to define the structure of a question
class OnboardingQuestion {
  final String heading;
  final IconData icon;
  final String questionText;
  final List<String> options;

  OnboardingQuestion({
    required this.heading,
    required this.icon,
    required this.questionText,
    required this.options,
  });
}

// This class holds all the app's state for the onboarding flow
class OnboardingData extends ChangeNotifier {
  final PageController pageController = PageController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final int totalOnboardingPages;
  // --- NEW ---
  // Controllers for the new personal details screen
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String? selectedGender;
  File? skinImage;
  File? scalpImage;
  int _currentPage = 0;
  int get currentPage => _currentPage;

  OnboardingData() : totalOnboardingPages = 1 + 12 + 1 { // 14 total
    pageController.addListener(() {
      _currentPage = pageController.page?.round() ?? 0;
      notifyListeners();
    });
  }
  void setSkinImage(File image) {
    skinImage = image;
    print("Skin image set: ${image.path}");
    notifyListeners();
  }

  // --- NEW ---
  // Function to store the uploaded scalp image
  void setScalpImage(File image) {
    scalpImage = image;
    print("Scalp image set: ${image.path}");
    notifyListeners();
  }
  Future<void> submitPhotosAndAnalyze(BuildContext context) async {
    if (skinImage == null || scalpImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload both photos before continuing.")),
      );
      return;
    }

    print("All data collected. Navigating to Loading Screen.");

    // Show loading screen while analyzing
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: this,
          child: const LoadingScreen(),
        ),
      ),
    );
  }

  // This map will store the answers, e.g., {0: "Mostly Sitting", 1: "6-8 hours"}
  final Map<int, String> _answers = {};
  Map<int, String> get answers => _answers;

  // --- Here are the 12 questions based on your prompt ---
  final List<OnboardingQuestion> questions = [
    // 1. Lifestyle: Work Type
    OnboardingQuestion(
      heading: "LIFESTYLE",
      icon: Icons.work_outline,
      questionText: "What is your work type?",
      options: [
        "Sedentary (Mostly sitting / desk job)",
        "Lightly Active (Some walking)",
        "Active (Mostly on your feet)",
        "Heavy Labor (Physical work)",
      ],
    ),
    // 2. Lifestyle: Sleep Habits
    OnboardingQuestion(
      heading: "LIFESTYLE",
      icon: Icons.do_not_disturb_on_total_silence,
      questionText: "How well do you sleep?",
      options: [
        "Very peacefully for 6-8 hours",
        "Disturbed, I wake up at least once",
        "Have difficulty falling asleep",
        "I sleep less than 6 hours",
      ],
    ),
    // 3. Lifestyle: Stress Levels
    OnboardingQuestion(
      heading: "LIFESTYLE",
      icon: Icons.sentiment_dissatisfied_outlined,
      questionText: "How would you describe your stress levels?",
      options: [
        "Low / Rarely stressed",
        "Moderate / Stressed a few times a week",
        "High / Stressed almost daily",
      ],
    ),
    // 4. Skin: Acne
    OnboardingQuestion(
      heading: "SKIN CONCERNS",
      icon: Icons.face_retouching_natural,
      questionText: "Are you concerned with acne or pimples?",
      options: ["Yes, frequently", "Yes, occasionally", "No, rarely or never"],
    ),
    // 5. Skin: Pigmentation/Dryness
    OnboardingQuestion(
      heading: "SKIN CONCERNS",
      icon: Icons.opacity_outlined,
      questionText: "What is your main skin concern?",
      options: ["Dryness / Flakiness", "Oiliness / Large Pores", "Pigmentation / Dark Spots", "Aging / Fine Lines", "None"],
    ),
    // 6. Hair: Hairfall
    OnboardingQuestion(
      heading: "HAIR CONCERNS",
      icon: Icons.highlight_off, // Using a generic icon
      questionText: "How would you describe your hair fall?",
      options: [
        "None to minimal",
        "Noticeable (e.g., on pillow or in shower)",
        "Heavy / Clumps of hair",
        "I have thinning patches",
      ],
    ),
    // 7. Hair: Dandruff
    OnboardingQuestion(
      heading: "HAIR CONCERNS",
      icon: Icons.grain_outlined,
      questionText: "Do you have dandruff?",
      options: [
        "No",
        "Yes, mild that comes and goes",
        "Yes, heavy dandruff that sticks to the scalp",
      ],
    ),
    // 8. Gut: Digestion
    OnboardingQuestion(
      heading: "GUT HEALTH",
      icon: Icons.health_and_safety, // Placeholder, no 'stomach' icon
      questionText: "Do you have Gas, Acidity or Bloating?",
      options: ["Yes, frequently", "Yes, occasionally", "No, rarely or never"],
    ),
    // 9. Gut: Metabolism
    OnboardingQuestion(
      heading: "GUT HEALTH",
      icon: Icons.local_fire_department_outlined,
      questionText: "How is your metabolism / appetite?",
      options: ["High / Always hungry", "Balanced / Regular", "Low / Rarely feel hungry", "Irregular"],
    ),
    // 10. Lifestyle: Exercise
    OnboardingQuestion(
      heading: "LIFESTYLE",
      icon: Icons.fitness_center_outlined,
      questionText: "How often do you exercise?",
      options: ["Daily", "3-4 times a week", "1-2 times a week", "Rarely or never"],
    ),
    // 11. Lifestyle: Food Preferences
    OnboardingQuestion(
      heading: "LIFESTYLE",
      icon: Icons.fastfood_outlined,
      questionText: "What best describes your food preference?",
      options: ["Vegetarian", "Non-Vegetarian", "Vegan", "Jain", "Mixed"],
    ),
    // 12. Medical: History
    OnboardingQuestion(
      heading: "MEDICAL HISTORY",
      icon: Icons.medical_services_outlined,
      questionText: "Do you have any known allergies or chronic issues?",
      options: ["Yes, allergies", "Yes, chronic issues (Thyroid, PCOD, etc.)", "Yes, both", "No, none that I know of"],
    ),
  ];

  void selectAnswer(int questionIndex, String answer) {
    _answers[questionIndex] = answer;

    // Check if we are on the last question (index 11)
    if (questionIndex == questions.length - 1) {
      print("Survey complete! Moving to Photo Upload.");
      // This was the last question, now move to the photo upload page
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      // Not the last question, just go to the next question
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }

    notifyListeners();
  }
  // Function to go to the previous page
  void previousPage() {
    if (pageController.page != null && pageController.page! > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }
// --- NEW ---
  // Function to set gender and notify UI
  void setGender(String gender) {
    selectedGender = gender;
    notifyListeners();
  }

  // --- NEW ---
  // Function to validate and submit personal details
  void submitPersonalDetails() {
    if (formKey.currentState!.validate() && selectedGender != null) {
      // All good, move to the next page
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }
  // Get the current progress (0.0 to 1.0)
  double get progress {
    if (_currentPage == 0) return 0.0;

    
    double questionProgress = _answers.length.toDouble() / questions.length.toDouble();

    // If we are on the photo page (index 13), show full progress.
    if (_currentPage == totalOnboardingPages - 1) {
      return 1.0;
    }

    return questionProgress;
  }
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    pageController.dispose();
    super.dispose();
  }
}