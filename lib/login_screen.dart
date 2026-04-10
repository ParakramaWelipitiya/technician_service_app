import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'customer_dashboard.dart';
import 'technician/technician_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      
      // Store additional user info in Firestore and link them with uid
      String uid = userCredential.user!.uid;
      // setup a batch write to ensure atomicity
      WriteBatch batch = FirebaseFirestore.instance.batch();

<<<<<<< HEAD
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
=======
      // Create a reference to the user's document in Firestore
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      batch.set(userRef, {
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });
>>>>>>> 80fa92d657238c333fc2d225fdd9dbddbdd6d4db

      // If the user is a technician, also create a document in the technicians collection
      if (_selectedRole == 'Technician') {
        DocumentReference techRef = FirebaseFirestore.instance.collection('technicians').doc(uid);
        batch.set(techRef, {
          'email': _emailController.text.trim(),
          'userName': '', // Placeholder for username, can be updated later
          'category': '', // Placeholder for category, can be updated later
          'profilePicture': '', // Placeholder for profile picture URL, can be updated later
          'price': '', // Placeholder for price, can be updated later
          'rating': '0', // Placeholder for rating, can be updated later
          'reviews': '(0)', // Placeholder for reviews count, can be updated later
          'location': '', // Placeholder for location, can be updated later
          'contactInfo': '', // Placeholder for contact info, can be updated later
          'totalBookings': 0, // Placeholder for total bookings, can be updated later
          // Add any additional technician-specific fields here
        });
      } else {
        // If the user is a customer, also create a document in the customers collection
        DocumentReference customerRef = FirebaseFirestore.instance.collection('customers').doc(uid);
        batch.set(customerRef, {
          'email': _emailController.text.trim(),
          'userName': '', // Placeholder for username, can be updated later
          'profilePicture': '', // Placeholder for profile picture URL, can be updated later
          'address': '', // Placeholder for address, can be updated later
          'location': '', // Placeholder for location, can be updated later
          'contactInfo': '', // Placeholder for contact info, can be updated later
          'totalBookings': 0, // Placeholder for total bookings, can be updated later
          // Add any additional customer-specific fields here
        });
      }

      // Commit the batch write
      await batch.commit();

      // Show success message and navigate to HomeScreen
      if (mounted) {
        if (userDoc.exists) {
          String role = userDoc['role'];
          if (role == 'Customer') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CustomerDashboard()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TechnicianDashboard()));
          }
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CustomerDashboard()));
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // These methods are for development/testing purposes to quickly log in as a technician or customer without going through the form
  Future<void> _devLoginAsTechnician() async {
    setState(() => _isLoading = true);
    try {
      // For development purposes, we can use a hardcoded technician account
      String email = "techguy@gmail.com";
      String password = "000000";
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logged in as technician!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Login failed")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  Future<void> _devLoginAsCustomer() async {
    setState(() => _isLoading = true);
    try {
      // For development purposes, we can use a hardcoded customer account
      String email = "test@gmail.com";
      String password = "123456";
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logged in as customer!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Login failed")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.white],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.build_circle, size: 80, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text(
                      "Welcome Back",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Log in to your account",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    _buildTextField("Email", Icons.email_outlined, _emailController),
                    const SizedBox(height: 16),
                    _buildTextField("Password", Icons.lock_outline, _passwordController, isPassword: true),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                        child: Text("Forgot Password?", style: TextStyle(color: Colors.blue.shade800)),
                      ),
<<<<<<< HEAD
                    ),
                    const SizedBox(height: 16),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(55),
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),

                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                      child: Text("Don't have an account? Sign Up", style: TextStyle(color: Colors.blue.shade800, fontSize: 16)),
                    ),
                  ],
=======
                      // DEV LOGIN BUTTONS (Only for development/testing purposes, can be removed in production)
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _devLoginAsTechnician,
                            child: const Text("DevLogin Technician"),
                          ),
                          ElevatedButton(
                            onPressed: _devLoginAsCustomer,
                            child: const Text("DevLogin Customer"),
                          ),
                        ],
                      ),

                    ],
                  ),
>>>>>>> 80fa92d657238c333fc2d225fdd9dbddbdd6d4db
                ),
              ),
            ),
          ),
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
      validator: (value) => value!.isEmpty ? 'Please enter your $label' : null,
    );
  }
}