import 'package:flutter/material.dart';
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildVerticalTechCard(context, "Syeila Onstefen", "Plumber", "4.9", "(200)", "\$34.00", "2.4 km", "assets/sample_6.png"),
          _buildVerticalTechCard(context, "Loka Madya", "Home Care", "4.8", "(150)", "\$14.00", "12 km", "assets/sample_7.png"),
          _buildVerticalTechCard(context, "John Doe", "Electricity", "4.7", "(80)", "\$40.00", "5 km", "assets/sample_8.png"),
          _buildVerticalTechCard(context, "Alex Fixit", "Handcraft", "4.5", "(42)", "\$25.00", "8 km", "assets/sample_9.png"),
        ],
      ),
    );
  }

  Widget _buildVerticalTechCard(BuildContext context, String name, String category, String rating, String reviews, String price, String distance, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TechnicianProfileScreen(
              name: name, category: category, rating: rating, reviews: reviews, price: price, imagePath: imagePath,
            ),
          ),
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