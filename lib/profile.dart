import 'package:flutter/material.dart';
import 'package:final_proj/editprofile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Tripmatic",
            style: TextStyle(
              fontFamily: 'ArchivoBlack',
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF353566),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                child: ListView(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 420,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile row
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundImage: AssetImage("assets/logo.jpg"),
                                radius: 45, // Increased size
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Kyla Cruz",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25, // Increased font size
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Posts / Followers / Following row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: const [
                                  Text(
                                    "56",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "Trips",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: const [
                                  Text(
                                    "41.7k",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "Followers",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: const [
                                  Text(
                                    "519",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "Following",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Action for adding a trip
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF353566),
                                    padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "+ Add a trip",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF353566),
                                    padding: const EdgeInsets.all(12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white),
                                ),
                              ],
                            ),
                          ),



                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 5),
          color: const Color(0xFF353566),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.home, color: Colors.white, size: 24),
                  Text("Home", style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.search, color: Colors.white, size: 24),
                  Text("Search", style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                  Text("Add", style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.person_outlined, color: Colors.white, size: 24),
                  Text("Profile", style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
