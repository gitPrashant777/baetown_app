import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/user_session.dart'; // <--- Add this
import '../../../entry_point.dart';
import '../../../models/onboarding_data.dart';
import '../Components/gender_selection_card.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  Future<void> _loadInitialData() async {
    if (!mounted) return; // Check if the widget is still in the tree

    try {
      // Get provider (listen: false is crucial here)
      final data = Provider.of<OnboardingData>(context, listen: false);

      // Get session data
      final session = await UserSession.getUserSession();

      // Check if session and user data exist
      if (session != null && session['userData'] != null) {

        final userName = session['userData']['name'] as String?;

        if (userName != null && userName.isNotEmpty) {
          data.nameController.text = userName;
          data.notifyListeners(); // This updates the "Continue" button state
        }
      }
    } catch (e) {
      print("Error loading user data for onboarding: $e");
      // If it fails, the user can just type their name manually
    }
  }

  void _navigateToDashboard(BuildContext context) {
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _navigateToDashboard(context);
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FB),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: data.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Header with gradient accent
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF020953), Color(0xFF04076B)],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 15),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF020953), Color(0xFF04076B)],
                            ).createShader(bounds),
                            child: const Text(
                              "Let's get started",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "We need a few details to kickstart your personalized beauty journey",
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white60 : Colors.black54,
                              height: 1.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Full Name Field
                      _buildFieldLabel("Full Name", isDark),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: data.nameController,
                        hint: "Enter your full name",
                        isDark: isDark,
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your name";
                          }
                          return null;
                        },
                        onChanged: (_) => data.notifyListeners(),
                      ),

                      const SizedBox(height: 18),

                      // Age Field
                      _buildFieldLabel("Age", isDark),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: data.ageController,
                        hint: "Enter your age",
                        isDark: isDark,
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        helperText: "Age must be between 18 to 80 years",
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Please enter your age";
                          final age = int.tryParse(value);
                          if (age == null) return "Please enter a valid number";
                          if (age < 18 || age > 80)
                            return "Age must be between 18 and 80";
                          return null;
                        },
                        onChanged: (_) => data.notifyListeners(),
                      ),

                      const SizedBox(height: 28),

                      // Gender Selection
                      _buildFieldLabel("Select your gender", isDark),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildModernGenderCard(
                              label: "Male",
                              icon: Icons.male_rounded,
                              isSelected: data.selectedGender == "Male",
                              onTap: () => data.setGender("Male"),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildModernGenderCard(
                              label: "Female",
                              icon: Icons.female_rounded,
                              isSelected: data.selectedGender == "Female",
                              onTap: () => data.setGender("Female"),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 50),

                      // Continue Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: isContinueEnabled
                              ? const LinearGradient(
                            colors: [Color(0xFF020953), Color(0xFF04076B)],
                          )
                              : null,
                          color: isContinueEnabled ? null : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isContinueEnabled
                              ? [
                            BoxShadow(
                              color:
                              const Color(0xFF020953).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                              : [],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isContinueEnabled
                                ? data.submitPersonalDetails
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "CONTINUE",
                                    style: TextStyle(
                                      color: isContinueEnabled
                                          ? Colors.white
                                          : Colors.grey[500],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  if (isContinueEnabled) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Privacy note
                      Center(
                        child: Text(
                          "Your data is secure and private",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : const Color(0xFF020953),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required IconData icon,
    TextInputType? keyboardType,
    String? helperText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.grey[400],
          fontSize: 15,
        ),
        helperText: helperText,
        helperStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.black45,
          fontSize: 12,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF020953).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF020953),
            size: 20,
          ),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF020953),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildModernGenderCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF020953), Color(0xFF04076B)],
              )
                  : null,
              color: isSelected
                  ? null
                  : isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : isDark
                    ? Colors.white12
                    : Colors.grey[300]!,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: const Color(0xFF020953).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFF020953).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: isSelected ? Colors.white : const Color(0xFF020953),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : isDark
                        ? Colors.white70
                        : const Color(0xFF020953),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSelected ? 24 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
