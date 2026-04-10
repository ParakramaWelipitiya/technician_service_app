import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_dashboard.dart';
import 'technician/technician_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _selectedRole = 'Customer';
  bool _isLoading = false;
  
  int _currentStep = 0;
  bool _isFileUploaded = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _usernameController = TextEditingController();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _idController = TextEditingController();
  final _mobileController = TextEditingController();

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    if (_selectedRole == 'Technician' && !_isFileUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload a certificate")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Map<String, dynamic> userData = {
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_selectedRole == 'Customer') {
        userData['username'] = _usernameController.text.trim();
      } else {
        userData['firstName'] = _firstNameController.text.trim();
        userData['lastName'] = _lastNameController.text.trim();
        userData['idNumber'] = _idController.text.trim();
        userData['mobile'] = _mobileController.text.trim();
        userData['isApproved'] = false; 
      }

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(userData);

      if (mounted) {
        if (_selectedRole == 'Customer') {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CustomerDashboard()), (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const TechnicianDashboard()), (route) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Registration failed")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Lets the gradient flow behind the app bar
      appBar: AppBar(
        title: const Text("Create Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        // DASHBOARD MATCHING GRADIENT
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.white],
            stops: const [0.0, 0.3], // Faster fade so the Stepper/Forms are on white
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: _selectedRole == 'Customer' ? _buildCustomerView() : _buildTechnicianView(),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRoleSelector(),
          const SizedBox(height: 32),
          _buildTextField("Username", Icons.person_outline, _usernameController),
          const SizedBox(height: 16),
          _buildTextField("Email", Icons.email_outlined, _emailController),
          const SizedBox(height: 16),
          _buildTextField("Password", Icons.lock_outline, _passwordController, isPassword: true),
          const SizedBox(height: 16),
          _buildTextField("Confirm Password", Icons.lock_outline, _confirmPasswordController, isPassword: true),
          const SizedBox(height: 48),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(55),
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Register as Customer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
        ],
      ),
    );
  }

  Widget _buildTechnicianView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: _buildRoleSelector(),
        ),
        Expanded(
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(primary: Colors.blue.shade700),
            ),
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 2) {
                  setState(() => _currentStep += 1);
                } else {
                  _registerUser();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) setState(() => _currentStep -= 1);
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _isLoading 
                          ? const Center(child: CircularProgressIndicator()) 
                          : ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Colors.blue.shade700, 
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(_currentStep == 2 ? "Finish & Register" : "Next", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: details.onStepCancel, 
                            style: OutlinedButton.styleFrom(
                               padding: const EdgeInsets.symmetric(vertical: 14),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Back"),
                          )
                        ),
                      ]
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text("Personal Info", style: TextStyle(fontWeight: FontWeight.bold)),
                  isActive: _currentStep >= 0,
                  content: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildTextField("First Name", Icons.person_outline, _firstNameController),
                      const SizedBox(height: 16),
                      _buildTextField("Last Name", Icons.person_outline, _lastNameController),
                      const SizedBox(height: 16),
                      _buildTextField("ID Number (NIC/Passport)", Icons.badge_outlined, _idController),
                      const SizedBox(height: 16),
                      _buildTextField("Mobile Number", Icons.phone_outlined, _mobileController),
                    ],
                  ),
                ),
                Step(
                  title: const Text("Account Settings", style: TextStyle(fontWeight: FontWeight.bold)),
                  isActive: _currentStep >= 1,
                  content: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildTextField("Email", Icons.email_outlined, _emailController),
                      const SizedBox(height: 16),
                      _buildTextField("Password", Icons.lock_outline, _passwordController, isPassword: true),
                      const SizedBox(height: 16),
                      _buildTextField("Confirm Password", Icons.lock_outline, _confirmPasswordController, isPassword: true),
                    ],
                  ),
                ),
                Step(
                  title: const Text("Qualifications", style: TextStyle(fontWeight: FontWeight.bold)),
                  isActive: _currentStep >= 2,
                  content: InkWell(
                    onTap: () => setState(() => _isFileUploaded = true), // Simulates file picking
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _isFileUploaded ? Colors.green : Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
                      ),
                      child: Column(
                        children: [
                          Icon(_isFileUploaded ? Icons.check_circle : Icons.cloud_upload_outlined, size: 48, color: _isFileUploaded ? Colors.green : Colors.blue.shade300),
                          const SizedBox(height: 16),
                          Text(
                            _isFileUploaded ? "certificate_uploaded.pdf" : "Tap to upload certificate\n(PDF, JPG, PNG)",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _isFileUploaded ? Colors.green.shade700 : Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'Customer', label: Text('Customer'), icon: Icon(Icons.person)),
          ButtonSegment(value: 'Technician', label: Text('Technician'), icon: Icon(Icons.handyman)),
        ],
        selected: {_selectedRole},
        onSelectionChanged: (newSelection) {
          setState(() {
            _selectedRole = newSelection.first;
            _currentStep = 0; 
          });
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.white,
          selectedForegroundColor: Colors.white,
          selectedBackgroundColor: Colors.blue.shade700,
          side: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade300),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
        ),
      ),
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
    );
  }
}