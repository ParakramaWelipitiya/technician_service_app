import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatefulWidget {
  final String techId;
  final String techName;
  final String categoryName;
  final String price;

  const BookingScreen({
    super.key,
    required this.techId,
    required this.techName,
    required this.categoryName,
    required this.price,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _issueController = TextEditingController();
  bool _isEmergency = false;
  bool _isSubmitting = false;

  Future<void> _submitBooking() async {
    if (_issueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please describe the issue first.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('bookings').add({
          'customerId': user.uid,
          'customerEmail': user.email,
          'technicianId': widget.techId,
          'technicianName': widget.techName,
          'category': widget.categoryName,
          'agreedPrice': widget.price,
          'issueDescription': _issueController.text.trim(),
          'isEmergency': _isEmergency,
          'status': 'Pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Booking sent successfully! Waiting for technician to accept."),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Confirm Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Booking Details", style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(widget.techName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${widget.categoryName} Service • ${widget.price}/Hr", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text("Describe your issue:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _issueController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "E.g., The pipe under the kitchen sink is leaking and causing water damage...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.blue.shade300, width: 2)),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: _isEmergency ? Colors.red.shade50 : Colors.white,
                  border: Border.all(color: _isEmergency ? Colors.red.shade200 : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  title: Text("Emergency (+\$50)", style: TextStyle(fontWeight: FontWeight.bold, color: _isEmergency ? Colors.red.shade700 : Colors.black87)),
                  subtitle: Text("Need them immediately?", style: TextStyle(color: _isEmergency ? Colors.red.shade400 : Colors.grey)),
                  value: _isEmergency,
                  activeColor: Colors.red,
                  onChanged: (val) => setState(() => _isEmergency = val),
                ),
              ),
              const SizedBox(height: 40),

              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(55),
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Confirm & Send Request", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}