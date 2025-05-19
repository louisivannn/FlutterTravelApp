import 'package:flutter/material.dart';

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
                    color: Color(0xFF353566), fontFamily: 'ArchivoBlack'),
              ),
              const SizedBox(height: 20),
              Image.asset('assets/logo.jpg', height: 200),
              const SizedBox(height: 40),
              const Text(
                'HI! WELCOME TO TRIPMATIC',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF353566), fontFamily: 'ArchivoBlack'),
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
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                        validator: (value) =>
                        value!.isEmpty ? 'Enter first name' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                        validator: (value) =>
                        value!.isEmpty ? 'Enter last name' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                        validator: (value) =>
                        value!.isEmpty ? 'Enter username' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                        validator: (value) =>
                        value!.isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                        validator: (value) =>
                        value!.isEmpty ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                        validator: (value) =>
                        value != passwordController.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Perform sign up
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('SIGN UP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                      ),
                      const SizedBox(height: 20),
                     Column(
                       children: [
                         const Text("Have an account?", style: TextStyle(color: Colors.white)
                         ),
                         TextButton(onPressed: (){
                           Navigator
                         .pop(context);
                           },
                             child: const Text("LOG IN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),))
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
}
