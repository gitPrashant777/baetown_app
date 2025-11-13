import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop/services/firebase_kit_service.dart';
import 'package:shop/route/route_constants.dart'; // --- ADDED: For route names

import '../../../models/SavedKitModel.dart';
import 'KitDetailScreen.dart';

// You might need to import your Assessment Report Screen to navigate to it
// import 'assessment_report_screen.dart';

// --- CONVERTED TO STATEFULWIDGET ---
class MyKitScreen extends StatefulWidget {
  const MyKitScreen({super.key});

  @override
  State<MyKitScreen> createState() => _MyKitScreenState();
}

class _MyKitScreenState extends State<MyKitScreen> {
  // --- NEW STATE ---
  late Future<List<SavedKitModel>> _savedKitsFuture;
  late FirebaseKitService _firebaseKitService;

  @override
  void initState() {
    super.initState();
    // Get the service, but don't listen
    _firebaseKitService =
        Provider.of<FirebaseKitService>(context, listen: false);
    // Fetch the kits
    _loadKits();
  }

  void _loadKits() {
    setState(() {
      _savedKitsFuture = _firebaseKitService.getSavedKits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // No AppBar needed since EntryPoint already provides one
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Re-assessment Button
              _buildReAssessmentButton(context),

              const SizedBox(height: 24),

              // 2. NEW: Consultation Banner
              _buildConsultationBanner(context),

              const SizedBox(height: 24),

              // 3. Saved Kits Section
              Text(
                "Your Saved Kits",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // --- MODIFIED: Use FutureBuilder to show real kits ---
              FutureBuilder<List<SavedKitModel>>(
                future: _savedKitsFuture,
                builder: (context, snapshot) {
                  // Loading State
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // Error State
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          "Error loading kits: ${snapshot.error}",
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  // Empty State
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          "You have no saved kits yet.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  // Success State: Show list of kits
                  final kits = snapshot.data!;
                  return ListView.builder(
                    itemCount: kits.length,
                    shrinkWrap: true, // Important inside SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), // Let parent scroll
                    itemBuilder: (context, index) {
                      final kit = kits[index];
                      return _buildSavedKitCard(
                        context: context,
                        kit: kit, // Pass the whole kit
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the Re-assessment Button
  Widget _buildReAssessmentButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // --- MODIFIED: Navigate to Onboarding Screen ---
        // This will push the onboarding screen on top of the current screen.
        Navigator.pushNamed(context, onboarding);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.refresh, color: Colors.green[700], size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Take a Re-assessment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Your concerns might have changed. Get a new plan.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  // ***********************************************
  // ** NEW WIDGET ADDED HERE **
  // ***********************************************

  /// A banner to promote in-app consultations
  Widget _buildConsultationBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.video_call_rounded, color: Colors.green[800], size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Want Expert Advice?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Book an in-app consultation (chat, voice, or video) with our practitioners.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[800],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // TODO: Handle navigation to booking screen
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Book Consultation"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ***********************************************
  // ** END OF NEW WIDGET **
  // ***********************************************

  // --- MODIFIED: Helper widget to accept SavedKitModel ---
  Widget _buildSavedKitCard({
    required BuildContext context,
    required SavedKitModel kit,
  }) {
    // Determine icon and color based on kit name
    IconData icon = Icons.medical_services;
    Color color = Colors.grey;
    if (kit.kitName.toLowerCase().contains('hair')) {
      icon = Icons.health_and_safety;
      color = Colors.green;
    } else if (kit.kitName.toLowerCase().contains('skin')) {
      icon = Icons.face_retouching_natural;
      color = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kit.kitName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Assessed on ${kit.assessmentDate}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Button
          TextButton(
            onPressed: () {
              // --- THIS IS THE FIX ---
              // Navigate to the new detail screen and pass the kit data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KitDetailScreen(kit: kit),
                ),
              );
              // --- END OF FIX ---
            },
            child: const Text("View Kit"),
          ),
        ],
      ),
    );
  }
}