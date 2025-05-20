import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const FirebaseTestScreen(),
    );
  }
}

class FirebaseTestScreen extends StatelessWidget {
  const FirebaseTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase Firestore Test")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await FirebaseFirestore.instance.collection('test').add({
                'message': 'Hello Firebase!',
                'timestamp': FieldValue.serverTimestamp(),
              });
              print("✅ Data sent to Firestore!");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Data sent to Firestore!")),
              );
            } catch (e) {
              print("❌ Error: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          },
          child: Text('Send Test Data'),
        ),
      ),
    );
  }
}
