import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("My Bookings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text("Please log in."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('customerId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text("You haven't booked any services yet.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      ],
                    ),
                  );
                }

                var customerBookings = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: customerBookings.length,
                  itemBuilder: (context, index) {
                    var booking = customerBookings[index].data() as Map<String, dynamic>;
                    
                    String techName = booking['technicianName'] ?? "Technician";
                    String category = booking['category'] ?? "Service";
                    String price = booking['agreedPrice'] ?? "\$0.00";
                    String status = booking['status'] ?? "Pending";
                    bool isEmergency = booking['isEmergency'] ?? false;

                    Color badgeColor = Colors.grey;
                    Color textColor = Colors.white;
                    if (status == 'Pending') badgeColor = Colors.orange.shade500;
                    if (status == 'Active') badgeColor = Colors.blue.shade600; // Accepted
                    if (status == 'Completed') badgeColor = Colors.green.shade600;
                    if (status == 'Rejected') badgeColor = Colors.red.shade500;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(techName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
                                  child: Text(
                                    status == 'Active' ? 'Accepted' : status, // Show 'Accepted' instead of 'Active' to customers
                                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text("$category Service", style: TextStyle(color: Colors.grey.shade700)),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (isEmergency)
                                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 18),
                                    if (isEmergency) const SizedBox(width: 4),
                                    Text(isEmergency ? "Emergency Call" : "Standard Booking", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                  ],
                                ),
                                Text(price, style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 16)),
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
}