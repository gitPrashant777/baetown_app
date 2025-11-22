import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';

import '../../../models/onboarding_data.dart';
import 'PersonalDetailsScreen.dart';
import 'combined_photo_upload_screen.dart';
import 'onboarding_question_screen.dart';

class OnboardingFlowManager extends StatefulWidget {
  const OnboardingFlowManager({super.key});

  @override
  State<OnboardingFlowManager> createState() => _OnboardingFlowManagerState();
}

class _OnboardingFlowManagerState extends State<OnboardingFlowManager> {
  Future<bool> _onWillPop(BuildContext context, OnboardingData data) async {
    if (data.currentPage == 0) {
      return true; // Allow back navigation on first page
    } else {
      data.previousPage();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return ChangeNotifierProvider(
      create: (context) => OnboardingData(),
      child: Consumer<OnboardingData>(
        builder: (context, data, child) {
          return PopScope(
            canPop: data.currentPage == 0,
            onPopInvoked: (didPop) async {
              if (!didPop && data.currentPage > 0) {
                data.previousPage();
              }
            },
            child: Scaffold(
              backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FB),
              appBar: AppBar(
                backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
                elevation: 0,
                toolbarHeight: isTablet ? 70 : 60,
                leading: Container(
                  margin: EdgeInsets.all(isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : const Color(0xFF020953).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: isDark ? Colors.white : const Color(0xFF020953),
                      size: isTablet ? 26 : 24,
                    ),
                    onPressed: () {
                      if (data.currentPage == 0) {
                        Navigator.of(context).pop();
                      } else {
                        data.previousPage();
                      }
                    },
                  ),
                ),
                centerTitle: true,
                title: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 18 : 14,
                    vertical: isTablet ? 10 : 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF020953), Color(0xFF04076B)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Step ${data.currentPage + 1}/${data.totalOnboardingPages}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: EdgeInsets.all(isTablet ? 12 : 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : const Color(0xFF020953).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white : const Color(0xFF020953),
                        size: isTablet ? 26 : 24,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
                bottom: data.currentPage > 0
                    ? PreferredSize(
                  preferredSize: Size.fromHeight(isTablet ? 12 : 10),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: data.progress,
                            backgroundColor: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF020953),
                            ),
                            minHeight: isTablet ? 6 : 5,
                          ),
                        ),
                        SizedBox(height: isTablet ? 6 : 4),
                      ],
                    ),
                  ),
                )
                    : PreferredSize(
                  preferredSize: const Size.fromHeight(4),
                  child: Container(height: 4),
                ),
              ),
              body: PageView.builder(
                controller: data.pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.totalOnboardingPages,
                onPageChanged: (index) {
                  HapticFeedback.lightImpact();
                },
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const PersonalDetailsScreen();
                  }

                  if (index > 0 && index <= data.questions.length) {
                    return OnboardingQuestionScreen(
                      questionIndex: index - 1,
                    );
                  }

                  if (index == data.totalOnboardingPages - 1) {
                    return const CombinedPhotoUploadScreen();
                  }

                  return Container(
                    color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FB),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF020953),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
