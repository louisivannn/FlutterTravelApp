import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'trip_post_model.dart';
import 'trip_carousel_screen.dart';
import 'bottom_navbar.dart';
import 'add_trip_screen.dart';
import 'profile.dart';
import 'search_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SearchPage()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AddTripScreen()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleLike(String postId, List<dynamic> currentLikes) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final postRef = FirebaseFirestore.instance.collection('trips').doc(postId);

    if (currentLikes.contains(userId)) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId])
      });
    }
  }

  void _showCommentModal(BuildContext context, String postId) {
    final TextEditingController _commentController = TextEditingController();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add Comment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Write a comment...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final commentText = _commentController.text.trim();
                  if (commentText.isNotEmpty && userId != null) {
                    await FirebaseFirestore.instance
                        .collection('trips')
                        .doc(postId)
                        .collection('comments')
                        .add({
                      'userId': userId,
                      'text': commentText,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Post Comment'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No posts yet", style: TextStyle(color: Colors.white)));
          }

          final tripsDocs = snapshot.data!.docs;

          return FutureBuilder<List<TripPost>>(
            future: Future.wait(tripsDocs.map((doc) async {
              final data = doc.data()! as Map<String, dynamic>;

              // Fetch user document by userId
              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(data['userId'])
                  .get();

              final userData = userDoc.data() ?? {};

              return TripPost(
                title: data['title'] ?? '',
                imageUrls: (data['images'] is Iterable)
                    ? List<String>.from(data['images'])
                    : [data['images'].toString()],
                descriptions: (data['description'] is Iterable)
                    ? List<String>.from(data['description'])
                    : [data['description'].toString()],
                userId: data['userId'] ?? '',
                username: userData['username'] ?? 'Unknown',
                profileImageUrl: userData['profile_image'] ?? '',
              );
            }).toList()),
            builder: (context, tripsSnapshot) {
              if (tripsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!tripsSnapshot.hasData || tripsSnapshot.data!.isEmpty) {
                return const Center(child: Text("No posts yet", style: TextStyle(color: Colors.white)));
              }
              final trips = tripsSnapshot.data!;

              return PageView.builder(
                controller: _pageController,
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  final postId = tripsDocs[index].id;
                  final data = tripsDocs[index].data() as Map<String, dynamic>;
                  final likes = List<String>.from(data['likes'] ?? []);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TripCarouselScreen(trip: trip),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      height: MediaQuery.of(context).size.height * 0.7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            trip.imageUrls.isNotEmpty
                                ? CachedNetworkImage(
                              imageUrl: trip.imageUrls[0],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                                : Container(
                              color: Colors.grey[300],
                              width: double.infinity,
                              height: double.infinity,
                              child: const Icon(Icons.image_not_supported),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 15,
                              left: 15,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: trip.profileImageUrl != null && trip.profileImageUrl!.isNotEmpty
                                        ? NetworkImage(trip.profileImageUrl ?? '')
                                        : const AssetImage("assets/logo.jpg") as ImageProvider,
                                    radius: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    trip.username ?? 'Unknown user',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 70,
                              left: 20,
                              right: 20,
                              child: Text(
                                trip.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      likes.contains(FirebaseAuth.instance.currentUser?.uid)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _toggleLike(postId, likes);
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(Icons.mode_comment_outlined, color: Colors.white),
                                    onPressed: () {
                                      _showCommentModal(context, postId);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
