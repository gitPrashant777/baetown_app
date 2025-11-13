import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';

import '../../../models/onboarding_data.dart';
import 'PersonalDetailsScreen.dart';
import 'combined_photo_upload_screen.dart';
import 'onboarding_question_screen.dart';
// The next file we will create

// This is the main widget that holds the entire onboarding flow
class OnboardingFlowManager extends StatelessWidget {
  const OnboardingFlowManager({super.key});

  @override
  Widget build(BuildContext context) {
    // We use ChangeNotifierProvider to create and provide the OnboardingData
    // to all children widgets in this flow.
    return ChangeNotifierProvider(
      create: (context) => OnboardingData(),
      child: Consumer<OnboardingData>(
        builder: (context, data, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              // Back Button
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  // If on the first page, pop. Otherwise, go to previous page.
                  if (data.pageController.page == 0) {
                    Navigator.of(context).pop();
                  } else {
                    data.previousPage();
                  }
                },
              ),
              // Close Button
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    // Logic to exit onboarding
                    Navigator.of(context).pop();
                  },
                ),
              ],
              // Progress Bar
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: data.currentPage == 0
                    ? Container(height: 4.0) // Empty container for page 0
                    : LinearProgressIndicator(
                  value: data.progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ),
            body: PageView.builder(
              controller: data.pageController,
              // This physics type prevents the user from swiping manually
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.totalOnboardingPages,
              itemBuilder: (context, index) {
                // 1. Personal Details Screen (index 0)
                if (index == 0) {
                  return const PersonalDetailsScreen();
                }

                // 2. Question Screens (index 1 to 12)
                if (index > 0 && index <= data.questions.length) {
                  return OnboardingQuestionScreen(
                    questionIndex: index - 1, // index 1 -> question 0
                  );
                }

                if (index == data.totalOnboardingPages - 1) { // Last page
                  return const CombinedPhotoUploadScreen();
                }

                // Fallback
                return Container(color: Colors.blue);
              },
            ),
          );
    },

      ),
    );
  }
}