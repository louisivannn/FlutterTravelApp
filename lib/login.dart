import 'package:flutter/material.dart';
import 'package:final_proj/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF353566), fontFamily: 'ArchivoBlack'),
              ),
              const SizedBox(height: 20),
              Image.asset('assets/logo.jpg', height: 200),
              const SizedBox(height: 40),
              const Text(
                'HI! WELCOME TO TRIPMATIC',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF353566), fontFamily: 'ArchivoBlack'),
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
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? 'Enter username' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Perform login
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('LOGIN', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                      ),
                      const SizedBox(height: 20),
                      const Text("Don't have an account?", style: TextStyle(color: Colors.white)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        child: const Text("Create an account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
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
}
