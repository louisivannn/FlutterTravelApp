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
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;
  String? firstName;
  String? currentUserId;
  List<dynamic> followingList = [];
  bool isFollowing = false;
  int tripCount = 0;
  int followersCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _fetchUserData();
    _fetchCounts();
  }

  Future<void> _fetchUserData() async {
    try {
      final targetUserId = widget.userId ?? currentUserId;
      if (targetUserId == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        setState(() {
          firstName = userData?['username'] ?? 'User';
        });
      }

      if (widget.userId != null &&
          currentUserId != null &&
          widget.userId != currentUserId) {
        final currentUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();
        if (currentUserDoc.exists) {
          final currentUserData = currentUserDoc.data();
          setState(() {
            followingList = currentUserData?['following'] ?? [];
            isFollowing = followingList.contains(widget.userId);
          });
        }
      }
    } catch (e) {
      print('Error fetching name: $e');
      setState(() {
        firstName = 'User';
        followingList = [];
        isFollowing = false;
      });
    }
  }

  Future<void> _fetchCounts() async {
    try {
      final targetUserId = widget.userId ?? currentUserId;
      if (targetUserId == null) return;

      final tripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('userId', isEqualTo: targetUserId)
          .count()
          .get();

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .get();

      setState(() {
        tripCount = tripsSnapshot.count!;
        if (userDoc.exists) {
          final userData = userDoc.data();
          followersCount = (userData?['followers'] as List?)?.length ?? 0;
          followingCount = (userData?['following'] as List?)?.length ?? 0;
        }
      });
    } catch (e) {
      print('Error fetching counts: $e');
      setState(() {
        tripCount = 0;
        followersCount = 0;
        followingCount = 0;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (currentUserId == null ||
        widget.userId == null ||
        currentUserId == widget.userId) return;

    final currentUserRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);
    final targetUserRef =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);

    try {
      if (isFollowing) {
        await currentUserRef.update({
          'following': FieldValue.arrayRemove([widget.userId])
        });
        await targetUserRef.update({
          'followers': FieldValue.arrayRemove([currentUserId])
        });
        setState(() {
          isFollowing = false;
          followingList.remove(widget.userId);
        });
      } else {
        await currentUserRef.update({
          'following': FieldValue.arrayUnion([widget.userId])
        });
        await targetUserRef.update({
          'followers': FieldValue.arrayUnion([currentUserId])
        });
        setState(() {
          isFollowing = true;
          followingList.add(widget.userId);
        });
      }
      _fetchCounts();
    } catch (e) {
      print('Error toggling follow status: $e');
    }
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const SearchPage()));
    } else if (index == 2) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AddTripScreen()));
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
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
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
                    if (widget.userId == null || widget.userId == currentUserId)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF353566)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(tripCount.toString(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const Text("Trips",
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(followersCount.toString(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const Text("Followers",
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(followingCount.toString(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const Text("Following",
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (widget.userId == null || widget.userId == currentUserId)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddTripScreen()),
                        );
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
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isFollowing ? Colors.grey : const Color(0xFF353566),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isFollowing ? "Following" : "Follow",
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('trips')
                  .where('userId', isEqualTo: widget.userId ?? currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No trips posted yet."));
                }

                final tripPosts = snapshot.data!.docs
                    .map((doc) => TripPost.fromFirestore(
                        doc.data()! as Map<String, dynamic>))
                    .where((trip) => trip.imageUrls.isNotEmpty)
                    .toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                      itemCount: tripPosts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                              MaterialPageRoute(
                                  builder: (_) =>
                                      TripCarouselScreen(trip: trip)),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              trip.imageUrls[0],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          ),
                        );
                      }),
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
