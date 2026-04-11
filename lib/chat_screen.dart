import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_detail_screen.dart'; 

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Messages", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text("Please log in to view messages."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bookings').where('customerId', isEqualTo: user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                var allDocs = snapshot.data!.docs;
                var chatThreads = allDocs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return data['status'] == 'Active' || data['status'] == 'Completed';
                }).toList();

                if (chatThreads.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chatThreads.length,
                  itemBuilder: (context, index) {
                    var data = chatThreads[index].data() as Map<String, dynamic>;
                    String bookingId = chatThreads[index].id;
                    String techName = data['technicianName'] ?? "Technician";
                    String category = data['category'] ?? "Service";
                    String status = data['status'] ?? "Active";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
                      shadowColor: Colors.black.withOpacity(0.05),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(
                                bookingId: bookingId,
                                otherUserName: techName,
                                role: "Customer",
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                                child: Icon(Icons.handyman, color: Colors.blue.shade700),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(techName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        if (status == 'Completed')
                                          Text("Completed", style: TextStyle(color: Colors.green.shade600, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text("$category Service Thread", style: TextStyle(color: Colors.grey.shade600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("No active conversations yet.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          const SizedBox(height: 8),
          Text("Book a technician to start chatting!", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        ],
      ),
    );
  }
}