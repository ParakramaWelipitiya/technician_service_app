import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'technician_profile_screen.dart';

class AllTechniciansScreen extends StatelessWidget {
  const AllTechniciansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Technicians"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('technicians').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading technicians"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final technicians = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: technicians.length,
              itemBuilder: (context, index) {
                var technicianDoc = technicians[index];
                var technician = technicianDoc.data() as Map<String, dynamic>;
                final String name = "${technician['firstName'] ?? ''} ${technician['lastName'] ?? ''}".trim();
                List<dynamic> services = technician['services'] ?? [];
                final String category = services.isNotEmpty ? services[0]['name'] : 'General Services';
                final String price = services.isNotEmpty ? "\$${services[0]['rate']}" : "\$0.00";
                final String rating = (double.tryParse(technician['rating']?.toString() ?? '0') ?? 0.0).toStringAsFixed(1);

                return _buildVerticalTechCard(
                  context,
                  technicianDoc.id,
                  name,
                  category,
                  rating,
                  technician['reviews']?.toString() ?? '(0)',
                  price,
                  technician['location'] ?? 'Unknown',
                  technician['profilePicture'] ?? 'assets/sample_6.png', // Placeholder
                );
              },
            );
          } else {
            return const Center(child: Text("No technicians found"));
          }
        },
      ),
    );
  }

  Widget _buildVerticalTechCard(BuildContext context, String technicianId, String name, String category, String rating, String reviews, String price, String distance, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TechnicianProfileScreen(technicianId: technicianId)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(category, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(" $rating $reviews", style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("$price/Hr", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      Text(distance, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
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