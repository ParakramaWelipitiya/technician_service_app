import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../customer/customer_dashboard.dart';
import '../technician/technician_dashboard.dart';
import '../../login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const LoginScreen();
    }

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text("Error fetching user data. Please log in again."),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String role =
              userData['role'] ?? 'Customer'; // Default to customer if missing

          if (role == 'Technician') {
            return const TechnicianDashboard();
          } else {
            return const CustomerDashboard();
          }
        },
      ),
    );
  }
}
