import 'package:flutter/material.dart';
import '../../../models/onboarding_data.dart';
import '../Components/question_option_card.dart';
import 'package:provider/provider.dart';

class OnboardingQuestionScreen extends StatelessWidget {
  final int questionIndex;

  const OnboardingQuestionScreen({
    super.key,
    required this.questionIndex,
  });

  @override
  Widget build(BuildContext context) {
    // We use 'Consumer' to listen to changes in OnboardingData
    return Consumer<OnboardingData>(
      builder: (context, data, child) {
        final question = data.questions[questionIndex];
        final currentAnswer = data.answers[questionIndex];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 1. Icon
              Icon(
                question.icon,
                color: Colors.green,
                size: 40,
              ),
              const SizedBox(height: 24),
              // 2. Heading
              Text(
                question.heading,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              // 3. Question Text
              Text(
                question.questionText,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              // 4. Options List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: question.options.length,
                itemBuilder: (context, optionIndex) {
                  final optionText = question.options[optionIndex];

                  return QuestionOptionCard(
                    optionText: optionText,
                    isSelected: optionText == currentAnswer,
                    onTap: () {
                      // This is where the magic happens!
                      // We call the function in OnboardingData
                      data.selectAnswer(questionIndex, optionText);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}