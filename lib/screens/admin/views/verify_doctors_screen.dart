import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/constants.dart';
import 'package:shop/components/network_image_with_loader.dart'; // Assuming you have this, or use Image.network

class VerifyDoctorsScreen extends StatelessWidget {
  const VerifyDoctorsScreen({super.key});

  // Function to Approve/Reject Doctor
  Future<void> _updateDoctorStatus(BuildContext context, String uid, bool approve) async {
    try {
      await FirebaseFirestore.instance.collection('consultants').doc(uid).update({
        'isVerified': approve,
        'verificationStatus': approve ? 'approved' : 'rejected',
        // If rejected, you might want to set isProfileComplete to false so they can edit again
        'isProfileComplete': approve ? true : false,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'Doctor Verified!' : 'Doctor Rejected'),
            backgroundColor: approve ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Doctors", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // 1. FETCH REAL DATA FROM FIREBASE
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('consultants')
            .where('isProfileComplete', isEqualTo: true) // Only show those who submitted
        //.where('isVerified', isNotEqualTo: true) // Optional: Only show unverified
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No pending verifications found."),
            );
          }

          // 2. DISPLAY REAL LIST
          final doctors = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];
              final data = doc.data() as Map<String, dynamic>;

              // Check current status
              final bool isVerified = data['isVerified'] ?? false;
              if (isVerified) return const SizedBox(); // Skip already verified (optional)

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Profile Image
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: data['profileImageUrl'] != null
                                ? NetworkImage(data['profileImageUrl'])
                                : null,
                            child: data['profileImageUrl'] == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'Unknown Name', // Get from user data or consultant data
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "${data['specialty']} • ${data['experienceYears']} Yrs Exp",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Details
                      _infoRow("License:", data['licenseNumber'] ?? 'N/A'),
                      _infoRow("Phone:", data['phone'] ?? 'N/A'),
                      _infoRow("Qualification:", data['qualification'] ?? 'N/A'),

                      const SizedBox(height: 12),
                      const Text("Certificate:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      // Certificate Preview
                      if (data['certificateUrl'] != null)
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[100],
                            image: DecorationImage(
                              image: NetworkImage(data['certificateUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        const Text("No certificate uploaded", style: TextStyle(color: Colors.red)),

                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _updateDoctorStatus(context, doc.id, false),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text("Reject"),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateDoctorStatus(context, doc.id, true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              child: const Text("Verify & Approve"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}