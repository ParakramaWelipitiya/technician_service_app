import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../login_screen.dart';

class TechProfileScreen extends StatefulWidget {
  const TechProfileScreen({super.key});

  @override
  State<TechProfileScreen> createState() => _TechProfileScreenState();
}

class _TechProfileScreenState extends State<TechProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _bioController = TextEditingController();
  
  List<dynamic> _services = [];
  String? _profilePicUrl;
  bool _isApproved = false;
  
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadTechnicianData();
  }

  Future<void> _loadTechnicianData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('technicians').doc(user.uid).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _mobileController.text = data['mobile'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _services = List.from(data['services'] ?? []);
          _profilePicUrl = data['profilePicture'];
          _isApproved = data['isApproved'] ?? false;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading profile: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image == null) return;

      setState(() => _isUploadingImage = true);

      File file = File(image.path);
      String fileName = 'profile_pictures/${user.uid}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      await storageRef.putFile(file);
      String downloadURL = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('technicians').doc(user.uid).update({'profilePicture': downloadURL});

      setState(() { _profilePicUrl = downloadURL; _isUploadingImage = false; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile picture updated!"), backgroundColor: Colors.green));
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to upload: $e")));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      List<String> searchCategories = _services.map((s) => s['name'].toString()).toList();
      await FirebaseFirestore.instance.collection('technicians').doc(user.uid).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'bio': _bioController.text.trim(),
        'services': _services,
        'searchCategories': searchCategories, 
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving profile: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final rateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add Service", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Service Name", filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
              const SizedBox(height: 12),
              TextField(controller: rateController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Hourly Rate (\$)", prefixIcon: const Icon(Icons.attach_money), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && rateController.text.isNotEmpty) {
                  setState(() => _services.add({'name': nameController.text.trim(), 'rate': rateController.text.trim()}));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.blue.shade300, Colors.white], stops: const [0.0, 0.25])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _isUploadingImage ? null : _pickAndUploadImage,
                        child: Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4), boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10)]),
                          child: ClipOval(child: _isUploadingImage ? const Center(child: CircularProgressIndicator()) : _profilePicUrl != null ? Image.network(_profilePicUrl!, fit: BoxFit.cover) : Icon(Icons.person, size: 60, color: Colors.grey.shade400)),
                        ),
                      ),
                      Positioned(bottom: 0, right: 0, child: CircleAvatar(backgroundColor: Colors.blue.shade700, radius: 18, child: const Icon(Icons.camera_alt, color: Colors.white, size: 18))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: _isApproved ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: _isApproved ? Colors.green.shade200 : Colors.orange.shade200)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_isApproved ? Icons.verified : Icons.pending, size: 18, color: _isApproved ? Colors.green.shade700 : Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(_isApproved ? "Verified Professional" : "Verification Pending", style: TextStyle(color: _isApproved ? Colors.green.shade700 : Colors.orange.shade700, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Personal Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(children: [Expanded(child: _buildTextField("First Name", Icons.person_outline, _firstNameController)), const SizedBox(width: 16), Expanded(child: _buildTextField("Last Name", Icons.person_outline, _lastNameController))]),
                        const SizedBox(height: 16),
                        _buildTextField("Mobile Number", Icons.phone_outlined, _mobileController),
                        const SizedBox(height: 16),
                        _buildTextField("Bio / About Me", Icons.description_outlined, _bioController, maxLines: 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Services & Pricing", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), TextButton.icon(onPressed: _showAddServiceDialog, icon: const Icon(Icons.add_circle), label: const Text("Add"))]),
                        const Divider(),
                        if (_services.isEmpty) const Padding(padding: EdgeInsets.all(16.0), child: Text("No services added. Customers won't be able to book you until you add a service!", style: TextStyle(color: Colors.red))),
                        ..._services.asMap().entries.map((entry) {
                          int index = entry.key; var service = entry.value;
                          return ListTile(contentPadding: EdgeInsets.zero, title: Text(service['name'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("\$${service['rate']} / Hour", style: TextStyle(color: Colors.blue.shade700)), trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => setState(() => _services.removeAt(index))));
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _isSaving
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(55), backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text("Save Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {int maxLines = 1}) {
    return TextFormField(
      controller: controller, maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label, prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.blue.shade300) : null,
        filled: true, fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.blue.shade300, width: 2)),
      ),
      validator: (value) => value!.isEmpty ? 'Required' : null,
    );
  }
}