import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../chat/chat_detail_screen.dart';

class TechBookingsScreen extends StatelessWidget {
  const TechBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text("My Bookings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blue.shade800,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.amber,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Active"),
              Tab(text: "Scheduled"),
              Tab(text: "Rejected"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildJobList('Active', Icons.handyman, "No immediate jobs right now.", showScheduledOnly: false),
            
            _buildJobList('Active', Icons.calendar_month, "No upcoming scheduled jobs.", showScheduledOnly: true),
            
            _buildJobList('Rejected', Icons.cancel_outlined, "No rejected jobs.", showScheduledOnly: false),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList(String targetStatus, IconData emptyIcon, String emptyMessage, {required bool showScheduledOnly}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Please log in."));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('technicianId', isEqualTo: user.uid)
          .where('status', isEqualTo: targetStatus)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(emptyIcon, emptyMessage);
        }

        var allJobs = snapshot.data!.docs;
        List<QueryDocumentSnapshot> filteredJobs = [];

        if (targetStatus == 'Active') {
          if (showScheduledOnly) {
            filteredJobs = allJobs.where((doc) => (doc.data() as Map)['scheduledDate'] != null).toList();
          } else {
            filteredJobs = allJobs.where((doc) => (doc.data() as Map)['scheduledDate'] == null).toList();
          }
        } else {
          filteredJobs = allJobs; 
        }

        if (filteredJobs.isEmpty) {
          return _buildEmptyState(emptyIcon, emptyMessage);
        }

        if (showScheduledOnly) {
          filteredJobs.sort((a, b) {
            Timestamp tA = (a.data() as Map)['scheduledDate'];
            Timestamp tB = (b.data() as Map)['scheduledDate'];
            return tA.compareTo(tB);
          });
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredJobs.length,
          itemBuilder: (context, index) {
            var jobData = filteredJobs[index].data() as Map<String, dynamic>;
            String bookingId = filteredJobs[index].id; 
            
            return _buildJobCard(context, bookingId, jobData, targetStatus);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _completeJob(BuildContext context, String bookingId) async {
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'status': 'Completed',
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Job Marked as Completed!"), backgroundColor: Colors.green),
      );
    }
  }

  Widget _buildJobCard(BuildContext context, String bookingId, Map<String, dynamic> jobData, String status) {
    String category = jobData['category'] ?? "General Service";
    String customer = jobData['customerEmail']?.split('@')[0] ?? "Customer";
    String description = jobData['issueDescription'] ?? "No description.";
    String price = jobData['agreedPrice'] ?? "\$0.00";
    bool isEmergency = jobData['isEmergency'] ?? false;
    
    String displayDate = "Immediate / Emergency";
    if (jobData['scheduledDate'] != null) {
      DateTime dt = (jobData['scheduledDate'] as Timestamp).toDate();
      displayDate = DateFormat('MMM dd, yyyy • hh:mm a').format(dt);
    }

    Color cardAccentColor = Colors.blue.shade700;
    if (status == 'Rejected') cardAccentColor = Colors.red.shade400;
    if (status == 'Active') cardAccentColor = Colors.green.shade600;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: cardAccentColor, width: 6))),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("$category Job", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("$price/Hr", style: TextStyle(color: cardAccentColor, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text("Client: $customer", style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
                  if (isEmergency) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text("EMERGENCY", style: TextStyle(color: Colors.red.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ]
                ],
              ),
              const SizedBox(height: 12),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(jobData['scheduledDate'] != null ? Icons.calendar_month : Icons.flash_on, size: 18, color: Colors.blue.shade800),
                    const SizedBox(width: 8),
                    Text(displayDate, style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              Text("Issue Description:", style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
              
              if (status == 'Active') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        // THE CHAT BUTTON LOGIC
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(
                                bookingId: bookingId,
                                otherUserName: customer,
                                role: "Technician",
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text("Message"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _completeJob(context, bookingId),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text("Complete"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}