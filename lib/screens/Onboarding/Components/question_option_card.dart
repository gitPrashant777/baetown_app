import 'package:flutter/material.dart';

class QuestionOptionCard extends StatelessWidget {
  final String optionText;
  final bool isSelected;
  final VoidCallback onTap;

  const QuestionOptionCard({
    super.key,
    required this.optionText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Colors.green;
    final Color unselectedColor = Colors.grey[300]!;
    final Color selectedBackgroundColor = Colors.green.withOpacity(0.1);
    final Color unselectedBackgroundColor = Colors.white;

    return Padding(
      // Reduced spacing between cards
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          // *** THIS IS THE MAIN CHANGE ***
          // Reduced vertical padding to make card less tall
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? selectedBackgroundColor : unselectedBackgroundColor,
            border: Border.all(
              color: isSelected ? selectedColor : unselectedColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Radio Button
              Radio<bool>(
                value: isSelected,
                groupValue: true,
                onChanged: (bool? value) {
                  onTap();
                },
                activeColor: selectedColor,
                // Make radio button a bit smaller
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 12),
              // Option Text
              Expanded(
                child: Text(
                  optionText,
                  style: const TextStyle(
                    // Slightly smaller font
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}