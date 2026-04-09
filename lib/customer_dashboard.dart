import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'discover_screen.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart'; 
import 'notifications_screen.dart';
import 'category_screen.dart';
import 'technician_profile_screen.dart'; 
import 'all_technicians_screen.dart';    

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHomeView(), 
    const DiscoverScreen(),
    const ChatScreen(),
    const HistoryScreen(),
    const ProfileScreen(), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Discover"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"), 
        ],
      ),
    );
  }
}

class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String displayName = "User";
    
    if (user != null && user.email != null) {
      displayName = user.email!.split('@')[0];
      if (displayName.isNotEmpty) {
        displayName = displayName[0].toUpperCase() + displayName.substring(1);
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade300,
                  Colors.white,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello 👋", 
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayName,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.black87),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Search service here...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategory(context, "House", "assets/house.png"),
                      _buildCategory(context, "Electricity", "assets/electricity.png"),
                      _buildCategory(context, "Handcraft", "assets/handcraft.png"),
                      _buildCategory(context, "Plumber", "assets/plumber.png"),
                      _buildCategory(context, "More", "assets/more.png"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Near on you", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AllTechniciansScreen()),
                    );
                  },
                  child: Text("View All", style: TextStyle(color: Colors.blue.shade700)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          SizedBox(
            height: 260, 
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              children: [
                _buildTechnicianCard(context, "Sample Technician 1", "Plumber", "4.9", "(200)", "\$34.00", "24 km", "assets/sample_technician_1.jpg"),
                _buildTechnicianCard(context, "Sample Technician 2", "Home Care", "4.8", "(150)", "\$14.00", "12 km", "assets/sample_technician_2.jpg"),
                _buildTechnicianCard(context, "Sample Technician 3", "Electricity", "4.7", "(80)", "\$40.00", "5 km", "assets/sample_technician_3.png"),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper Widget for Categories
  Widget _buildCategory(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoryScreen(categoryName: title)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Technician Cards
  Widget _buildTechnicianCard(BuildContext context, String name, String category, String rating, String reviews, String price, String distance, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TechnicianProfileScreen(
              name: name,
              category: category,
              rating: rating,
              reviews: reviews,
              price: price,
              imagePath: imagePath,
            ),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16,
                    child: Icon(Icons.favorite_border, size: 18, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(" $reviews", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: price, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14)),
                            const TextSpan(text: " / Hr", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(distance, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}