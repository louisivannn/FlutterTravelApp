import 'package:flutter/material.dart';
import 'package:final_proj/login.dart';
import 'package:final_proj/editprofile.dart';
import 'package:final_proj/profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tripmatic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/profile',     // starting route
      routes: {
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }

}

