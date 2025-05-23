import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'TRIPMATIC',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF353566),
                    fontFamily: 'ArchivoBlack'),
              ),
              const SizedBox(height: 20),
              Image.asset('assets/logo.jpg', height: 200),
              const SizedBox(height: 40),
              const Text(
                'HI! WELCOME TO TRIPMATIC',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF353566),
                    fontFamily: 'ArchivoBlack'),
              ),
              const SizedBox(height: 20),
              Container(
                width: 400,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Color(0xFF353566),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                          controller: firstNameController, label: 'First Name'),
                      const SizedBox(height: 15),
                      _buildTextField(
                          controller: lastNameController, label: 'Last Name'),
                      const SizedBox(height: 15),
                      _buildTextField(
                          controller: usernameController, label: 'Username'),
                      const SizedBox(height: 15),
                      _buildTextField(
                          controller: emailController, label: 'Email'),
                      const SizedBox(height: 15),
                      _buildTextField(
                          controller: passwordController,
                          label: 'Password',
                          obscure: true),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: _inputDecoration('Confirm Password'),
                        validator: (value) => value != passwordController.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text(
                          'SIGN UP',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          const Text("Have an account?",
                              style: TextStyle(color: Colors.white)),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "LOG IN",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create user in Firebase Auth
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim());

        User? user = userCredential.user;
        if (user != null) {
          // Save user info in Firestore using UID
          await _firestore.collection('users').doc(user.uid).set({
            'first_name': firstNameController.text.trim(),
            'last_name': lastNameController.text.trim(),
            'username': usernameController.text.trim(),
            'email': emailController.text.trim(),
            'created_at': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign up successful!')),
          );

          Navigator.pop(context); // Go back to login screen
        }
      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred';
        if (e.code == 'email-already-in-use') {
          message = 'This email is already registered.';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email format.';
        } else if (e.code == 'weak-password') {
          message = 'Password is too weak.';
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildTextField(
      {required TextEditingController controller,
        required String label,
        bool obscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: _inputDecoration(label),
      validator: (value) =>
      value == null || value.isEmpty ? 'Enter $label' : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border:
      OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }
}
