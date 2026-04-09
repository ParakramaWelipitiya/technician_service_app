import 'package:flutter/material.dart';
import 'technician_reviews_screen.dart'; // We will create this next!

class TechnicianProfileScreen extends StatefulWidget {
  final String name;
  final String category;
  final String rating;
  final String reviews;
  final String price;
  final String imagePath;

  const TechnicianProfileScreen({
    super.key,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.imagePath,
  });

  @override
  State<TechnicianProfileScreen> createState() => _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  bool _isAboutExpanded = false;

  final String _aboutText = 
      "Skilled maintenance professional focused on accurate diagnostics and lasting repairs. "
      "Whether it is routine maintenance or an emergency fix, I am committed to doing the job "
      "right the first time with efficiency. I carry all my own tools and specialize in older "
      "home infrastructure. Customer satisfaction is my highest priority.";

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(height: 4, width: 40, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.bookmark_border, color: Colors.blue),
                title: const Text("Save Technician"),
                subtitle: const Text("Add to your saved list for later"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved to your Profile!")));
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.red),
                title: const Text("Report", style: TextStyle(color: Colors.red)),
                subtitle: const Text("Report inappropriate behavior or fake profiles"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report submitted.")));
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Price", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: widget.price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const TextSpan(text: "/Hr", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Booking flow for ${widget.name} coming soon!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Book", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.handyman, size: 100, color: Colors.grey),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircleButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                        _buildCircleButton(Icons.more_horiz, () => _showMoreOptions(context)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(widget.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text("${widget.rating} ${widget.reviews}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("${widget.category} - 5 years Experience", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  
                  const SizedBox(height: 32),

                  const Text("About me", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    _aboutText,
                    style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                    maxLines: _isAboutExpanded ? null : 3,
                    overflow: _isAboutExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAboutExpanded = !_isAboutExpanded;
                      });
                    },
                    child: Text(
                      _isAboutExpanded ? "Show less" : "Read more..", 
                      style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Review", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TechnicianReviewsScreen(techName: widget.name)),
                          );
                        },
                        child: const Text("See All"),
                      ),
                    ],
                  ),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 16))),
                        const SizedBox(height: 12),
                        Text(
                          "Excellent work. Showed up exactly on time, knew exactly what to do, and completed the repair efficiently.",
                          style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                        ),
                        const SizedBox(height: 12),
                        const Text("- Mr. ABC AB", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}