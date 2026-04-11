import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ADDED: To read live database
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

class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({super.key});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ""; // Tracks what the user is typing
  Future<List<DocumentSnapshot>>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userDataFuture = Future.wait([
        FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        FirebaseFirestore.instance.collection('customers').doc(user.uid).get(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade300, Colors.white],
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
                        FutureBuilder<List<DocumentSnapshot>>(
                          future: _userDataFuture,
                          builder: (context, snapshot) {
                            String firstName = "User";
                            String lastName = "";
                            String username = "";
                            if (snapshot.hasData && snapshot.data != null) {
                              var userDoc = snapshot.data![0].data() as Map<String, dynamic>?;
                              var customerDoc = snapshot.data![1].data() as Map<String, dynamic>?;
                              firstName = customerDoc?['firstName'] ?? "User";
                              lastName = customerDoc?['lastName'] ?? "";
                              username = userDoc?['username'] ?? "";
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Hello 👋", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                                const SizedBox(height: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("$firstName $lastName".trim(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                    if (username.isNotEmpty)
                                      Text(username, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.black87),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase(); // Updates screen as you type
                      });
                    },
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Search name or service...",
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
                      _buildCategory(context, "House", "assets/sample_1.png"),
                      _buildCategory(context, "Electricity", "assets/sample_2.png"),
                      _buildCategory(context, "Handcraft", "assets/sample_3.png"),
                      _buildCategory(context, "Plumber", "assets/sample_4.png"),
                      _buildCategory(context, "More", "assets/sample_5.png"),
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
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllTechniciansScreen())),
                  child: Text("View All", style: TextStyle(color: Colors.blue.shade700)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          SizedBox(
            height: 260, 
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance // Query technicians directly
                  .collection('technicians')
                  .where('isApproved', isEqualTo: true) 
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No technicians available right now.", style: TextStyle(color: Colors.grey)));
                }

                var allDocs = snapshot.data!.docs;

                if (_searchQuery.isNotEmpty) {
                  allDocs = allDocs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String fullName = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".toLowerCase();
                    List<dynamic> categories = data['searchCategories'] ?? [];
                    bool matchesCategory = categories.any((cat) => cat.toString().toLowerCase().contains(_searchQuery));
                                        
                    return fullName.contains(_searchQuery) || matchesCategory;
                  }).toList();
                }

                if (allDocs.isEmpty) {
                  return const Center(child: Text("No matches found.", style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: allDocs.length,
                  itemBuilder: (context, index) {
                    var data = allDocs[index].data() as Map<String, dynamic>;
                    var docId = allDocs[index].id;
                    
                    String name = "${data['firstName'] ?? 'Tech'} ${data['lastName'] ?? ''}".trim();
                    List<dynamic> services = data['services'] ?? [];

                    String displayCategory = services.isNotEmpty ? services[0]['name'] : "General Services";
                    String displayPrice = services.isNotEmpty ? "\$${services[0]['rate']}" : "\$0.00";
                    String rating = (double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0).toStringAsFixed(1);

                    return _buildTechnicianCard(
                      context, 
                      docId,
                      name, 
                      displayCategory, 
                      rating,
                      "(0)", // Placeholder for reviews count
                      displayPrice, 
                      "Nearby",
                      "assets/sample_6.png"
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryScreen(categoryName: title))),
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: ClipOval(child: Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.category, color: Colors.blue))),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianCard(BuildContext context, String technicianId, String name, String category, String rating, String reviews, String price, String distance, String imagePath) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (context) => TechnicianProfileScreen(technicianId: technicianId),
      )),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
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
                    child: Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, size: 50, color: Colors.grey)),
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: CircleAvatar(backgroundColor: Colors.white, radius: 16, child: Icon(Icons.favorite_border, size: 18, color: Colors.grey.shade600)),
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
                      Text.rich(TextSpan(children: [TextSpan(text: price, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14)), const TextSpan(text: " / Hr", style: TextStyle(color: Colors.grey, fontSize: 12))])),
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