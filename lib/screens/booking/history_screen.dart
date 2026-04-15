import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../chat/chat_detail_screen.dart'; 

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  
  Future<void> _submitReview(String bookingId, String techId, int selectedRating, String reviewText) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'isRated': true,
        'ratingGiven': selectedRating,
        'reviewText': reviewText,
      });

      DocumentReference techRef = FirebaseFirestore.instance.collection('users').doc(techId);
      DocumentSnapshot techSnap = await techRef.get();
      
      if (techSnap.exists) {
        var techData = techSnap.data() as Map<String, dynamic>;
        int currentTotalReviews = techData['totalReviews'] ?? 0;
        double currentRatingSum = (techData['ratingSum'] ?? 0).toDouble();

        int newTotalReviews = currentTotalReviews + 1;
        double newRatingSum = currentRatingSum + selectedRating;
        double newAverage = newRatingSum / newTotalReviews;

        await techRef.update({
          'totalReviews': newTotalReviews,
          'ratingSum': newRatingSum,
          'averageRating': double.parse(newAverage.toStringAsFixed(1)),
        });
      }

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text("Thank you for your review!"), backgroundColor: Colors.green.shade700)
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showRatingDialog(BuildContext context, String bookingId, String techId, String techName) {
    int _rating = 5; 
    final TextEditingController _reviewController = TextEditingController();
    bool _isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24, 
                bottom: MediaQuery.of(context).viewInsets.bottom + 24, 
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Rate $techName", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          iconSize: 40,
                          icon: Icon(index < _rating ? Icons.star : Icons.star_border, color: Colors.amber),
                          onPressed: () => setStateSheet(() => _rating = index + 1),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reviewController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Write a short review (optional)...",
                        filled: true, fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isSubmitting
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            setStateSheet(() => _isSubmitting = true);
                            await _submitReview(bookingId, techId, _rating, _reviewController.text.trim());
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Submit Review", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("My Bookings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text("Please log in."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bookings').where('customerId', isEqualTo: user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildEmptyState();

                var customerBookings = snapshot.data!.docs.toList();
                customerBookings.sort((a, b) {
                  var aData = a.data() as Map<String, dynamic>;
                  var bData = b.data() as Map<String, dynamic>;
                  Timestamp? tA = aData['createdAt'];
                  Timestamp? tB = bData['createdAt'];
                  if (tA == null || tB == null) return 0;
                  return tB.compareTo(tA);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: customerBookings.length,
                  itemBuilder: (context, index) {
                    var booking = customerBookings[index].data() as Map<String, dynamic>;
                    String bookingId = customerBookings[index].id;
                    
                    String techId = booking['technicianId'] ?? "";
                    String techName = booking['technicianName'] ?? "Technician";
                    String category = booking['category'] ?? "Service";
                    String price = booking['agreedPrice'] ?? "\$0.00";
                    String status = booking['status'] ?? "Pending";
                    bool isRated = booking['isRated'] ?? false; 

                    Color badgeColor = Colors.grey;
                    if (status == 'Pending') badgeColor = Colors.orange.shade500;
                    if (status == 'Active') badgeColor = Colors.blue.shade600; 
                    if (status == 'Completed') badgeColor = Colors.green.shade600;
                    if (status == 'Rejected') badgeColor = Colors.red.shade500;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(techName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
                                  child: Text(
                                    status == 'Active' ? 'Accepted' : status,
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("$category Service", style: TextStyle(color: Colors.grey.shade600)),
                            const SizedBox(height: 12),
                            const Divider(),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total:", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                                Text(price, style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),

                            if (status == 'Active') ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => ChatDetailScreen(bookingId: bookingId, otherUserName: techName, role: "Customer"),
                                    ));
                                  },
                                  icon: const Icon(Icons.chat_bubble_outline),
                                  label: Text("Message $techName"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue.shade700, side: BorderSide(color: Colors.blue.shade200),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                  ),
                                ),
                              ),
                            ],

                            if (status == 'Completed' && !isRated) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _showRatingDialog(context, bookingId, techId, techName),
                                  icon: const Icon(Icons.star_outline),
                                  label: const Text("Leave a Review"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.amber.shade700, side: BorderSide(color: Colors.amber.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                  ),
                                ),
                              ),
                            ] else if (status == 'Completed' && isRated) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                                  const SizedBox(width: 8),
                                  Text("You reviewed this service.", style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontStyle: FontStyle.italic)),
                                ],
                              )
                            ]
                          ],
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
          Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("You haven't booked any services yet.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
        ],
      ),
    );
  }
}