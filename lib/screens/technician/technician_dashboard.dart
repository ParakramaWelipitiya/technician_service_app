import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'dart:ui'; 
import 'package:intl/intl.dart';
import 'tech_history_screen.dart';
import 'tech_bookings_screen.dart';
import 'tech_profile_screen.dart';
import '../../login_screen.dart'; 

class TechnicianDashboard extends StatefulWidget {
  const TechnicianDashboard({super.key});

  @override
  State<TechnicianDashboard> createState() => _TechnicianDashboardState();
}

class _TechnicianDashboardState extends State<TechnicianDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TechHomeView(),
    const TechHistoryScreen(),
    const TechBookingsScreen(),
    const TechProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in again.")));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('technicians').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        bool isVerifiedByAdmin = false;
        if (snapshot.hasData && snapshot.data!.exists) {
          var techData = snapshot.data!.data() as Map<String, dynamic>;
          isVerifiedByAdmin = techData['isApproved'] ?? false; 
        }

        return Scaffold(
          body: Stack(
            children: [
              Scaffold(
                body: _pages[_selectedIndex],
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: isVerifiedByAdmin ? _onItemTapped : null, 
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.blue.shade800,
                  unselectedItemColor: Colors.grey,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                    BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
                    BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Bookings"),
                    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
                  ],
                ),
              ),

              if (!isVerifiedByAdmin)
                Container(
                  color: Colors.white.withOpacity(0.1),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, 
                          children: [
                            Icon(Icons.admin_panel_settings, size: 80, color: Colors.amber.shade600),
                            const SizedBox(height: 24),
                            const Text("Account Not Verified", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            Text("Your documents are currently under review by our admin team. Please wait for approval before accepting jobs.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5)),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  if (context.mounted) {
                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                                  }
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text("Log Out"),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.red.shade50,
                                  foregroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    );
  }
}

class TechHomeView extends StatefulWidget {
  const TechHomeView({super.key});

  @override
  State<TechHomeView> createState() => _TechHomeViewState();
}

class _TechHomeViewState extends State<TechHomeView> {
  Future<List<DocumentSnapshot>>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userDataFuture = Future.wait([
        FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        FirebaseFirestore.instance.collection('technicians').doc(user.uid).get(),
      ]);
    }
  }

  Future<void> _acceptJob(BuildContext context, String bookingId) async {
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'status': 'Active',
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Job Accepted!"), backgroundColor: Colors.green.shade700));
    }
  }

  Future<void> _declineJob(BuildContext context, String bookingId) async {
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'status': 'Rejected',
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Job Declined."), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade800, Colors.blue.shade500],
            ),
          ),
          padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                      FutureBuilder<List<DocumentSnapshot>>(
                        future: _userDataFuture,
                        builder: (context, snapshot) {
                          String firstName = "Technician";
                          String lastName = "";
                          String username = "";
                          if (snapshot.hasData && snapshot.data != null) {
                            var userDoc = snapshot.data![0].data() as Map<String, dynamic>?;
                            var techDoc = snapshot.data![1].data() as Map<String, dynamic>?;
                            firstName = techDoc?['firstName'] ?? "Technician";
                            lastName = techDoc?['lastName'] ?? "";
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
                  const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.notifications_none, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _buildStatCard("Today's Earnings", "\$0.00", Icons.monetization_on)),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('bookings')
                          .where('technicianId', isEqualTo: user?.uid)
                          .where('status', isEqualTo: 'Pending')
                          .snapshots(),
                      builder: (context, snapshot) {
                        int pendingCount = 0;
                        if (snapshot.hasData) pendingCount = snapshot.data!.docs.length;
                        return _buildStatCard("Pending Requests", "$pendingCount", Icons.assignment);
                      }
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("New Job Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .where('technicianId', isEqualTo: user?.uid)
                .where('status', isEqualTo: 'Pending')
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
                      Icon(Icons.coffee, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text("You're all caught up!", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      const Text("No pending job requests right now.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              var pendingJobs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: pendingJobs.length,
                itemBuilder: (context, index) {
                  var jobData = pendingJobs[index].data() as Map<String, dynamic>;
                  String bookingId = pendingJobs[index].id; 

                  return _buildJobRequestCard(
                    context,
                    bookingId,
                    jobData['category'] ?? "General",
                    jobData['customerEmail']?.split('@')[0] ?? "Customer",
                    jobData['issueDescription'] ?? "No description provided.",
                    jobData['agreedPrice'] ?? "\$0.00",
                    jobData['isEmergency'] ?? false,
                    jobData['scheduledDate'],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade800, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildJobRequestCard(BuildContext context, String bookingId, String category, String customerName, String description, String price, bool isEmergency, Timestamp? scheduledDate) {
    
    String displayDate = "Immediate / Emergency";
    if (scheduledDate != null) {
      displayDate = DateFormat('MMM dd, yyyy • hh:mm a').format(scheduledDate.toDate());
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEmergency ? Colors.red.shade200 : Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$category Job", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (isEmergency)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text("EMERGENCY", style: TextStyle(color: Colors.red.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              else
                Text("$price/Hr", style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(customerName, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
          
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(scheduledDate != null ? Icons.calendar_month : Icons.flash_on, size: 14, color: Colors.blue.shade700),
              const SizedBox(width: 6),
              Text(displayDate, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),

          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
            child: Text(description, style: TextStyle(color: Colors.grey.shade800, fontSize: 13, fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _declineJob(context, bookingId),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                  child: const Text("Decline"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptJob(context, bookingId),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
                  child: const Text("Accept"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}