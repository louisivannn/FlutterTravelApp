import 'dart:io';
import 'package:flutter/material.dart';
import 'package:final_proj/editprofile.dart';
import 'package:final_proj/add_trip_screen.dart';
import 'package:final_proj/trip_post_model.dart';
import 'package:final_proj/trip_carousel_screen.dart';
import 'package:final_proj/home_screen.dart';
import 'package:final_proj/search_page.dart';
import 'package:final_proj/bottom_navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3; // Profile tab selected by default

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SearchPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AddTripScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tripmatic",
          style: TextStyle(
            fontFamily: 'ArchivoBlack',
            color: Colors.white,
            fontSize: 25,

          ),
        ),
        backgroundColor: const Color(0xFF353566),
      ),
      body: Column(
        children: [
          // Profile Info Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    CircleAvatar(
                      backgroundImage: AssetImage("assets/logo.jpg"),
                      radius: 45,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Miguel",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Column(
                      children: [
                        Text("56", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Trips", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("41.7k", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Followers", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("519", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Following", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddTripScreen()),
                        );
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF353566),
                        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                      ),
                      child: const Text(
                        "+ Add a trip",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
                      ),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Trip Posts Grid
          Expanded(
            child: localTripPosts.isEmpty
                ? const Center(child: Text("No trips posted yet."))
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                itemCount: localTripPosts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  final trip = localTripPosts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TripCarouselScreen(trip: trip),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(trip.images[0].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
