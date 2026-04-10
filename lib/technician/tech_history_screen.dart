import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TechHistoryScreen extends StatelessWidget {
  const TechHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Job History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text("Please log in."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('technicianId', isEqualTo: user.uid)
                  .where('status', isEqualTo: 'Completed') // ONLY SHOW COMPLETED
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
                        Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text("No completed jobs yet.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      ],
                    ),
                  );
                }

                var completedJobs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: completedJobs.length,
                  itemBuilder: (context, index) {
                    var jobData = completedJobs[index].data() as Map<String, dynamic>;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade50,
                          child: Icon(Icons.check_circle, color: Colors.green.shade600),
                        ),
                        title: Text("${jobData['category']} Job", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Client: ${jobData['customerEmail']?.split('@')[0]}"),
                        trailing: Text(
                          "${jobData['agreedPrice']}", 
                          style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}