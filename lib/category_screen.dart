import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'technician_profile_screen.dart';
import 'booking_screen.dart'; 

class CategoryScreen extends StatelessWidget {
  final String categoryName;

  const CategoryScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("$categoryName Available", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('technicians')
            .where('isApproved', isEqualTo: true)
            .where('searchCategories', arrayContains: categoryName)
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
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("No $categoryName technicians found yet.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            );
          }

          var allDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allDocs.length,
            itemBuilder: (context, index) {
              String techId = allDocs[index].id; 
              var data = allDocs[index].data() as Map<String, dynamic>;
              
              String name = "${data['firstName'] ?? 'Tech'} ${data['lastName'] ?? ''}".trim();
              List<dynamic> services = data['services'] ?? [];
              String price = "\$0.00";
              // Find the price for the specific category being viewed
              for (var svc in services) {
                if (svc['name'] == categoryName) {
                  price = "\$${svc['rate']}";
                  break;
                }
              }
              String rating = (double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0).toStringAsFixed(1);
              String reviews = data['reviews']?.toString() ?? '(0)'; // Placeholder
              String imagePath = data['profilePicture'] ?? 'assets/sample_6.png'; // Placeholder

              String displayRating = data['averageRating'] != null ? data['averageRating'].toString() : "New";
              String displayReviews = data['totalReviews'] != null ? "(${data['totalReviews']})" : "(0)";

              return _buildTechListTile(
                context, techId, name, rating, reviews, price, "Nearby", imagePath
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTechListTile(BuildContext context, String techId, String name, String rating, String reviews, String price, String distance, String imagePath) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell( 
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TechnicianProfileScreen(technicianId: techId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 65, height: 65,
                  color: Colors.blue.shade50,
                  child: Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.person, color: Colors.blue.shade300, size: 32)),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text("$rating ", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(reviews, style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text("$distance away", style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("$price/Hr", style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(
                            techId: techId,
                            techName: name,
                            categoryName: categoryName,
                            price: price,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700, 
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      minimumSize: const Size(60, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Book", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}