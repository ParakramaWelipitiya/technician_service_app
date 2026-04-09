import 'package:flutter/material.dart';
import 'technician_profile_screen.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryName;

  const CategoryScreen({super.key, required this.categoryName});

  void _showBookingPopup(BuildContext context, String techName, String price) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the popup to be taller
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Book $techName", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text("Category: $categoryName • Rate: $price/Hr", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              
              const Text("Describe your issue:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "E.g., The pipe is leaking...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Emergency (+\$50)"),
                subtitle: const Text("Need them immediately?"),
                value: false, 
                activeColor: Colors.red,
                onChanged: (val) {},
              ),
              
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Booking request sent to $techName!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Confirm Booking"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$categoryName Available"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // UPDATED: Added imagePath to the dummy data
          _buildTechListTile(context, "Syeila Onstefen", "4.9", "(200)", "\$34.00", "2.4 km", "assets/sample_6.png"),
          _buildTechListTile(context, "John Doe", "4.7", "(85)", "\$40.00", "5.1 km", "assets/sample_8.png"),
          _buildTechListTile(context, "Mike Smith", "4.5", "(42)", "\$30.00", "8.0 km", "assets/sample_9.png"),
        ],
      ),
    );
  }

  Widget _buildTechListTile(BuildContext context, String name, String rating, String reviews, String price, String distance, String imagePath) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        // THE FIX: Adding onTap to the ListTile to navigate to the Profile Screen
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TechnicianProfileScreen(
                name: name,
                category: categoryName, // We pull this from the screen's main variable
                rating: rating,
                reviews: reviews,
                price: price,
                imagePath: imagePath,
              ),
            ),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade200,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(" $rating $reviews"),
              ],
            ),
            const SizedBox(height: 4),
            Text("$price/Hr • $distance away", style: const TextStyle(color: Colors.grey)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _showBookingPopup(context, name, price),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          child: const Text("Book"),
        ),
      ),
    );
  }
}