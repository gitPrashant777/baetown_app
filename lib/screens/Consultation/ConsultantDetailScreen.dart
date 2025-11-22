// lib/screens/consultants/consultant_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/models/user_session.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- 1. ADD THIS IMPORT

// --- 2. REMOVED UNUSED IMPORTS ---
// import 'dart:async';
// import 'package:shop/services/call_service.dart';
// import 'Ui/call_screen.dart';
// ----------------------------------

import 'Ui/chat_screen.dart'; // Still needed for Chat
import 'Ui/MyBookingsScreen.dart';
import 'Ui/ConsultantModel.dart';

class ConsultantDetailScreen extends StatefulWidget {
  final ConsultantModel consultant;

  const ConsultantDetailScreen({super.key, required this.consultant});

  @override
  State<ConsultantDetailScreen> createState() => _ConsultantDetailScreenState();
}

class _ConsultantDetailScreenState extends State<ConsultantDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const brandPrimary = Color(0xFF020953);

  String _selectedConsultationType = 'Video Call';
  final List<String> _consultationTypes = ['Video Call', 'Voice Call', 'Chat'];

  // --- 3. REMOVED STATE FROM MyBookingsScreen ---
  // final CallService _callService = CallService();
  // StreamSubscription? _callSubscription;
  bool _isCalling = false;
  // -------------------------------------------

  // --- 4. REMOVED dispose() METHOD ---
  // @override
  // void dispose() {
  //   _callSubscription?.cancel();
  //   super.dispose();
  // }
  // ---------------------------------

  // --- 5. UPDATED _startConsultation ---
  Future<void> _startConsultation() async {
    // Check your static UserSession class instead of Firebase
    if (UserSession.authToken == null || UserSession.userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You must be logged in to start.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get user details from the session
    final apiUser = UserSession.userData!;
    final String userId =
        apiUser['id'] ?? apiUser['_id'] ?? apiUser['uid'] ?? 'unknown_user';
    final String userName = apiUser['name'] ?? 'Patient';

    // Set loading state
    setState(() => _isCalling = true);

    // ⚠️ CHAT CREDENTIAL REMOVED (No longer needed for Firebase Chat)
    // final String chatCredential = "123456";
    // --------------------------------------------------------------------------

    try {
      // --- Create the consultation document immediately ---
      // This logs that an attempt was made, regardless of type
      final docRef = _firestore.collection('consultations').doc();
      final String consultationId = docRef.id; // Renamed channelName to consultationId
      final DateTime now = DateTime.now();

      final consultationData = {
        'consultantId': widget.consultant.uid,
        'consultantName': widget.consultant.name,
        'userId': userId,
        'userName': userName,
        'date': now, // Use current date
        'time':
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}', // Use current time
        'consultationType': _selectedConsultationType,
        'status': 'pending', // 'pending' so it appears in doctor's list
        'createdAt': FieldValue.serverTimestamp(),
        'channelName': consultationId, // Keep original key name for consistency with calls
      };

      // Save to Firestore for history/logging
      await docRef.set(consultationData);

      // --- Navigate based on type ---
      if (_selectedConsultationType == 'Chat') {
        // Stop loading spinner
        setState(() => _isCalling = false);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              consultationId: consultationId, // 🎯 FIX: Renamed parameter to consultationId
              uid: userId, // Pass the patient's ID
              // chatCredential REMOVED
            ),
          ),
        );
      } else {
        // --- 6. THIS IS THE NEW LOGIC for 'Video Call' or 'Voice Call' ---
        // We will launch the phone's dialer instead of an in-app call.
        final phoneNumber = widget.consultant.phone;

        if (phoneNumber.isEmpty) {
          throw Exception('Consultant phone number is not available.');
        }

        final Uri launchUri = Uri(
          scheme: 'tel',
          path: phoneNumber,
        );

        // Check if the device can handle the 'tel' scheme
        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri);
        } else {
          throw Exception('Could not launch phone dialer.');
        }

        // Stop loading spinner
        setState(() => _isCalling = false);
        // --- END OF NEW LOGIC ---
      }
    } catch (e) {
      setState(() => _isCalling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- 7. REMOVED _startCall method ---
  // The _startCall (Agora) method is no longer needed.
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(26) // 0.1
                    : brandPrimary.withAlpha(20), // 0.08
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded,
                    color: isDark ? Colors.white : brandPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      brandPrimary.withAlpha(51), // 0.2
                      const Color(0xFF04076B).withAlpha(26), // 0.1
                    ],
                  ),
                ),
                child: widget.consultant.profileImageUrl != null
                    ? Image.network(widget.consultant.profileImageUrl!,
                    fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                      return Center(
                          child: Icon(Icons.person,
                              size: 100,
                              color: brandPrimary.withAlpha(77))); // 0.3
                    })
                    : Center(
                    child: Icon(Icons.person,
                        size: 100,
                        color: brandPrimary.withAlpha(77))), // 0.3
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Name + Verified Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Dr. ${widget.consultant.name}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : brandPrimary,
                          ),
                        ),
                      ),
                      if (widget.consultant.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(26), // 0.1
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.verified,
                                  size: 16, color: Colors.green[700]),
                              const SizedBox(width: 4),
                              Text('Verified',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[700])),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(widget.consultant.specialty,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black87,
                      )),

                  const SizedBox(height: 4),

                  Text(widget.consultant.qualification,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.black54,
                      )),

                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatCard(
                              'Experience',
                              '${widget.consultant.experienceYears} years',
                              Icons.work_outline,
                              isDark)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildStatCard(
                              'Fee',
                              '₹${widget.consultant.consultationFee.toInt()}',
                              Icons.currency_rupee,
                              isDark)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // About section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                          isDark ? Colors.white12 : Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: brandPrimary.withAlpha(26), // 0.1
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.info_outline,
                                  color: brandPrimary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text('About',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color:
                                    isDark ? Colors.white : brandPrimary)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(widget.consultant.about,
                            style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color:
                                isDark ? Colors.white70 : Colors.black87)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Consultation Type
                  Text('Select Consultation Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : brandPrimary,
                      )),

                  const SizedBox(height: 12),

                  Row(
                    children: _consultationTypes.map((type) {
                      bool selected = _selectedConsultationType == type;
                      IconData icon = Icons.videocam_outlined;
                      if (type == 'Voice Call') icon = Icons.call_outlined;
                      if (type == 'Chat') icon = Icons.chat_outlined;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedConsultationType = type),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: selected
                                  ? const LinearGradient(
                                colors: [brandPrimary, Color(0xFF04076B)],
                              )
                                  : null,
                              color: selected
                                  ? null
                                  : (isDark
                                  ? Colors.white.withAlpha(26) // 0.1
                                  : Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(icon,
                                    color: selected
                                        ? Colors.white
                                        : (isDark
                                        ? Colors.white70
                                        : Colors.black87),
                                    size: 24),
                                const SizedBox(height: 8),
                                Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: selected
                                        ? Colors.white
                                        : (isDark
                                        ? Colors.white70
                                        : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // --- 8. UPDATED BUTTON (No code change, just context) ---
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isCalling
                          ? null
                          : _startConsultation, // <-- Uses updated function
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isCalling
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                          : Text(
                        // Text will update based on selection
                        'START ${_selectedConsultationType.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  // ---------------------------

                  const SizedBox(height: 24),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            brandPrimary.withAlpha(26), // 0.1
            const Color(0xFF04076B).withAlpha(13), // 0.05
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brandPrimary.withAlpha(51)), // 0.2
      ),
      child: Column(
        children: [
          Icon(icon, color: brandPrimary, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : brandPrimary,
              )),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black54,
              )),
        ],
      ),
    );
  }
}