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
  double _currentPage = 0;
  int _selectedIndex = 0;


  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
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
            return const Center(child: Text("No posts yet", style: TextStyle(color: Colors.black)));
          }


          final trips = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;


            return TripPost(
              title: data['title'] ?? '',
              imageUrls: (data['images'] is Iterable)
                  ? List<String>.from(data['images'])
                  : [data['images'].toString()],
              descriptions: (data['description'] is Iterable)
                  ? List<String>.from(data['description'])
                  : [data['description'].toString()],
              userId: data['userId'] ?? '',
            );
          }).toList();


          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final scale = (1 - (_currentPage - index).abs()).clamp(0.85, 1.0);
                    final trip = trips[index];
                    final postId = snapshot.data!.docs[index].id;
                    final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final likes = List<String>.from(data['likes'] ?? []);




                    return Center(
                      child: Transform.scale(
                        scale: scale,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TripCarouselScreen(trip: trip),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
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
                                  const Positioned(
                                    top: 15,
                                    left: 15,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: AssetImage("assets/logo.jpg"),
                                          radius: 18,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Miguel",
                                          style: TextStyle(
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
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(trips.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    height: 8,
                    width: _currentPage.round() == index ? 16 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage.round() == index ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
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
