import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TechnicianReviewsScreen extends StatelessWidget {
  final String technicianId;
  final String techName;

  const TechnicianReviewsScreen({super.key, required this.technicianId, required this.techName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Reviews for $techName", style: const TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('technicians').doc(technicianId).collection('reviews').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("No reviews yet.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            );
          }

          var reviews = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              var review = reviews[index].data() as Map<String, dynamic>;
              double rating = double.tryParse(review['rating'].toString()) ?? 5.0;
              String comment = review['comment'] ?? "No comment provided.";
              String customerName = review['customerName'] ?? "Customer";
              
              String dateStr = "Recent";
              if (review['timestamp'] != null) {
                DateTime date = (review['timestamp'] as Timestamp).toDate();
                dateStr = DateFormat('MMM dd, yyyy').format(date);
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 4))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(dateStr, style: TextStyle(color: Colors.grey.shade500, fontSize: 12))]),
                    const SizedBox(height: 8),
                    Row(children: List.generate(5, (starIndex) => Icon(starIndex < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 16))),
                    const SizedBox(height: 12),
                    Text(comment, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}