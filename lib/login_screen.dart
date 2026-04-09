import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart'; // ADDED: Import the HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'Customer';
  bool _isLoading = false;
  bool _isLogin = true;

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      
      // Store additional user info in Firestore and link them with uid
      String uid = userCredential.user!.uid;
      // setup a batch write to ensure atomicity
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Create a reference to the user's document in Firestore
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      batch.set(userRef, {
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account created as $_selectedRole!")),
        );
        
        // ADDED: Navigate to HomeScreen after successful sign-up
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "An error occurred")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Welcome back!")),
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
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.build_circle, size: 80, color: Colors.blue),
                      const SizedBox(height: 16),
                      const Text(
                        "Welcome to Servo",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your email';
                          if (!value.contains('@')) return 'Please enter a valid email address';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your password';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      
                      // Role Selection (Only shows if signing up)
                      if (!_isLogin) ...[
                        const SizedBox(height: 24),
                        const Text("I am joining as a:"),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'Customer',
                              label: Text('Customer'),
                              icon: Icon(Icons.person),
                            ),
                            ButtonSegment(
                              value: 'Technician',
                              label: Text('Technician'),
                              icon: Icon(Icons.handyman),
                            ),
                          ],
                          selected: {_selectedRole},
                          onSelectionChanged: (newSelection) {
                            setState(() => _selectedRole = newSelection.first);
                          },
                        ),
                      ],
                      
                      const SizedBox(height: 32),

                      // Submit Button
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _isLogin ? _login() : _signUp();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(55),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(_isLogin ? "Login" : "Create Account"),
                            ),

                      // Toggle between Login and Sign Up
                      TextButton(
                        onPressed: () {
                          setState(() => _isLogin = !_isLogin);
                        },
                        child: Text(
                          _isLogin
                              ? "Don't have an account? Sign Up"
                              : "Already have an account? Login",
                        ),
                      ),
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}