import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../entry_point.dart';
import '../../../models/onboarding_data.dart';
import '../Components/gender_selection_card.dart';

// 1. ADD import for your EntryPoint screen
// (This relative path assumes EntryPoint.dart is in 'screens/'
// and this file is in 'screens/Onboarding/view/')

// This is the NEW File 4

class PersonalDetailsScreen extends StatelessWidget {
  const PersonalDetailsScreen({super.key});

  // 2. CREATE a helper method for navigation
  void _navigateToDashboard(BuildContext context) {
    // This clears all screens on top of the new one,
    // so the user can't go "back" into the onboarding flow.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const EntryPoint()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<OnboardingData>(context);
    final bool isContinueEnabled = data.nameController.text.isNotEmpty &&
        data.ageController.text.isNotEmpty &&
        data.selectedGender != null;

    // 3. WRAP with PopScope to catch the system back button
    return PopScope(
      canPop: false, // Prevents default back navigation
      onPopInvoked: (didPop) {
        if (didPop) return;
        // On system back, navigate to dashboard
        _navigateToDashboard(context);
      },
      // 4. ADD Scaffold to host the AppBar
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          // 5. ADD a "close" button
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // On close button tap, navigate to dashboard
              _navigateToDashboard(context);
            },
          ),
        ),
        // 6. SET the original widget as the body
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: data.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Let's get started",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "We need a few details to kickstart your journey",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                // --- Full Name ---
                const Text("Full Name", style: TextStyle(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: data.nameController,
                  decoration: getInputDecoration("Please enter your name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                  onChanged: (_) => data.notifyListeners(), // To update button state
                ),
                const SizedBox(height: 24),

                // --- Age ---
                const Text("Age", style: TextStyle(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: data.ageController,
                  decoration: getInputDecoration("Please enter your age")
                      .copyWith(
                    helperText: "Age must be between 18 to 70 years",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please enter your age";
                    final age = int.tryParse(value);
                    if (age == null) return "Please enter a valid number";
                    if (age < 18 || age > 70) return "Age must be between 18 and 70";
                    return null;
                  },
                  onChanged: (_) => data.notifyListeners(), // To update button state
                ),
                const SizedBox(height: 24),

                // --- Gender ---
                const Text("Select your gender", style: TextStyle(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GenderSelectionCard(
                        label: "Male",
                        icon: Icons.male_rounded,
                        isSelected: data.selectedGender == "Male",
                        onTap: () => data.setGender("Male"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GenderSelectionCard(
                        label: "Female",
                        icon: Icons.female_rounded,
                        isSelected: data.selectedGender == "Female",
                        onTap: () => data.setGender("Female"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // --- Continue Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isContinueEnabled ? Colors.black : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    // Disable button if form is incomplete
                    onPressed: isContinueEnabled ? data.submitPersonalDetails : null,
                    child: Text(
                      "CONTINUE",
                      style: TextStyle(
                        color: isContinueEnabled ? Colors.white : Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for text field styling
  InputDecoration getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
    );
  }
}