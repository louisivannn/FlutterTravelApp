import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_proj/editprofile.dart';
import 'package:final_proj/add_trip_screen.dart';
import 'package:final_proj/trip_post_model.dart';
import 'package:final_proj/trip_carousel_screen.dart';
import 'package:final_proj/home_screen.dart';
import 'package:final_proj/search_page.dart';
import 'package:final_proj/bottom_navbar.dart';
import 'package:final_proj/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;
  String? firstName;

  @override
  void initState() {
    super.initState();
    _fetchUserFirstName();
  }

  Future<void> _fetchUserFirstName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        setState(() {
          firstName = userDoc.data()?['first_name'] ?? 'User';
        });
      }
    } catch (e) {
      print('Error fetching name: $e');
      setState(() {
        firstName = 'User';
      });
    }
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SearchPage()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AddTripScreen()));
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white,),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Profile Info Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: const Color(0xFFF8F8F8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage("assets/logo.jpg"),
                      radius: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        firstName ?? "Loading...",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF353566)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Column(
                      children: [
                        Text("56", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Trips", style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("41.7k", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Followers", style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("519", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Following", style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddTripScreen()),
                      );
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF353566),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Add a Trip",
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Trip Posts Grid (replaced with StreamBuilder)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('trips').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No trips posted yet."));
                }

                // Map Firestore documents to TripPost objects
                final tripPosts = snapshot.data!.docs
                    .map((doc) => TripPost.fromFirestore(doc.data()! as Map<String, dynamic>))
                    .where((trip) => trip.imageUrls.isNotEmpty)
                    .toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    itemCount: tripPosts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                      itemBuilder: (context, index) {
                        final trip = tripPosts[index];

                        if (trip.imageUrls.isEmpty) {
                          return const Icon(Icons.broken_image);
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => TripCarouselScreen(trip: trip)),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              trip.imageUrls[0],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                            ),
                          ),
                        );
                      }
                  ),
                );
              },
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
