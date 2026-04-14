import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'technician_reviews_screen.dart';

class TechnicianProfileScreen extends StatefulWidget {
  final String technicianId;

  const TechnicianProfileScreen({super.key, required this.technicianId});

  @override
  State<TechnicianProfileScreen> createState() =>
      _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  bool _isAboutExpanded = false;
  late Future<DocumentSnapshot> _technicianFuture;

  @override
  void initState() {
    super.initState();
    _technicianFuture = FirebaseFirestore.instance
        .collection('technicians')
        .doc(widget.technicianId)
        .get();
  }

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
              Container(
                height: 4, width: 40,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
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

  void _showBookingSheet(BuildContext context, Map<String, dynamic> techData, String techName) {
    List<dynamic> services = techData['services'] ?? [];
    if (services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("This technician has no listed services yet.")));
      return;
    }

    Map<String, dynamic>? selectedService = services[0];
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(height: 5, width: 40, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 24),
                  Text("Book $techName", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  const Text("Select Service", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, dynamic>>(
                        isExpanded: true,
                        value: selectedService,
                        items: services.map((s) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: s,
                            child: Text("${s['name']} - \$${s['rate']}/hr"),
                          );
                        }).toList(),
                        onChanged: (val) => setSheetState(() => selectedService = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context, initialDate: DateTime.now().add(const Duration(days: 1)),
                                  firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 60)),
                                );
                                if (picked != null) setSheetState(() => selectedDate = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(selectedDate != null ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}" : "Select Date"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                if (picked != null) setSheetState(() => selectedTime = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 18, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(selectedTime != null ? selectedTime!.format(context) : "Select Time"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () async {
                            if (selectedDate == null || selectedTime == null || selectedService == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a date and time.")));
                              return;
                            }

                            setSheetState(() => isSubmitting = true);
                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                await FirebaseFirestore.instance.collection('bookings').add({
                                  'customerId': user.uid,
                                  'technicianId': widget.technicianId,
                                  'technicianName': techName,
                                  'serviceName': selectedService!['name'],
                                  'rate': selectedService!['rate'],
                                  'date': selectedDate!.toIso8601String(),
                                  'time': '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                                  'status': 'Pending',
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking Request Sent Successfully!"), backgroundColor: Colors.green));
                                }
                              }
                            } catch (e) {
                              setSheetState(() => isSubmitting = false);
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(55),
                            backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Confirm Booking", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: _technicianFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text("Technician not found."));

          final techData = snapshot.data!.data() as Map<String, dynamic>;
          final name = "${techData['firstName'] ?? ''} ${techData['lastName'] ?? ''}".trim();
          List<dynamic> services = techData['services'] ?? [];
          final category = services.isNotEmpty ? services[0]['name'] : 'Professional Services';
          final rating = (double.tryParse(techData['averageRating']?.toString() ?? '0') ?? 0.0).toStringAsFixed(1);
          final reviews = techData['totalReviews']?.toString() ?? '0';
          final price = services.isNotEmpty ? "\$${services[0]['rate']}" : "\$0.00";
          final imagePath = techData['profilePicture'] ?? 'assets/sample_6.png';
          final liveBio = techData['bio'] ?? techData['about'] ?? "Professional technician ready to provide excellent service.";

          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: _buildBottomBar(context, name, price, techData),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, imagePath),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileTitle(name, rating, reviews),
                        const SizedBox(height: 8),
                        Text(category, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 32),
                        _buildAboutMe(liveBio),
                        const SizedBox(height: 32),
                        _buildServicesSection(services),
                        const SizedBox(height: 32),
                        _buildReviewsSection(context, name),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String imagePath) {
    return Stack(
      children: [
        Container(
          height: 300, width: double.infinity, color: Colors.grey.shade200,
          child: imagePath.startsWith('http') 
              ? Image.network(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.handyman, size: 100, color: Colors.grey))
              : Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.handyman, size: 100, color: Colors.grey)),
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
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 8)]),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  Widget _buildProfileTitle(String name, String rating, String reviews) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text("$rating ($reviews)", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutMe(String bio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("About me", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          bio,
          style: TextStyle(color: Colors.grey.shade600, height: 1.5),
          maxLines: _isAboutExpanded ? null : 3,
          overflow: _isAboutExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (bio.length > 100)
          GestureDetector(
            onTap: () => setState(() => _isAboutExpanded = !_isAboutExpanded),
            child: Text(_isAboutExpanded ? "Show less" : "Read more..", style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildServicesSection(List<dynamic> services) {
    if (services.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Services & Pricing", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: services.map((s) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.shade100)),
              child: Text("${s['name']} - \$${s['rate']}/hr", style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 13)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context, String techName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Latest Review", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicianReviewsScreen(techName: techName, technicianId: widget.technicianId))),
              child: const Text("See All"),
            ),
          ],
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('technicians').doc(widget.technicianId).collection('reviews').orderBy('timestamp', descending: true).limit(1).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20), width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: Text("No reviews yet. Be the first to book!", style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
              );
            }
            var reviewData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            double ratingValue = double.tryParse(reviewData['rating'].toString()) ?? 5.0;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: List.generate(5, (index) => Icon(index < ratingValue ? Icons.star : Icons.star_border, color: Colors.amber, size: 16))),
                  const SizedBox(height: 12),
                  Text(reviewData['comment'] ?? "No comment provided.", style: TextStyle(color: Colors.grey.shade600, height: 1.5)),
                  const SizedBox(height: 12),
                  Text("- ${reviewData['customerName'] ?? 'Customer'}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, String name, String price, Map<String, dynamic> techData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, -5))]),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Starting at", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text.rich(TextSpan(children: [TextSpan(text: price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const TextSpan(text: " /Hr", style: TextStyle(color: Colors.grey, fontSize: 14))])),
              ],
            ),
            ElevatedButton(
              onPressed: () => _showBookingSheet(context, techData, name),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Book", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}