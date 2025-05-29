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
  String? currentUserId;
  List<TripPost> _trips = [];
  List<Map<String, dynamic>> _tripData = [];

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: 0,
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('trips')
        .orderBy('timestamp', descending: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _tripData = snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'postId': doc.id,
                })
            .toList();
        _trips = snapshot.docs.map((doc) {
          final data = doc.data();

          List<String> images = [];
          if (data['images'] != null) {
            if (data['images'] is List) {
              images = List<String>.from(data['images']);
            } else if (data['images'] is String) {
              images = [data['images']];
            }
          }

          List<String> descriptions = [];
          if (data['description'] != null) {
            if (data['description'] is List) {
              descriptions = List<String>.from(data['description']);
            } else if (data['description'] is String) {
              descriptions = [data['description']];
            }
          }

          if (descriptions.length < images.length) {
            descriptions = List.generate(
              images.length,
              (index) => index < descriptions.length ? descriptions[index] : '',
            );
          }

          return TripPost(
            postId: doc.id,
            title: data['title'] ?? '',
            imageUrls: images,
            descriptions: descriptions,
            userId: data['userId'] ?? '',
            username: data['username'] ?? '',
            profileImageUrl: data['profileImageUrl'] ?? '',
          );
        }).toList();
      });
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page.toDouble();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      // For simplicity, just show date for older comments
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const SearchPage()));
    } else if (index == 2) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AddTripScreen()));
    } else if (index == 3) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleLike(String postId, List<dynamic> currentLikes) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final postRef = FirebaseFirestore.instance.collection('trips').doc(postId);

    try {
      if (currentLikes.contains(userId)) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([userId])
        });
      }

      await _loadTrips();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error toggling like: $e')),
        );
      }
    }
  }

  void _showCommentModal(BuildContext context, String postId) {
    if (postId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Post ID is missing')),
      );
      return;
    }

    final TextEditingController _commentController = TextEditingController();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                children: [
                  const Text("Comments",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(modalContext);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('tbl_comments')
                      .where('postId', isEqualTo: postId)
                      .snapshots(),
                  builder: (context, commentSnapshot) {
                    if (commentSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!commentSnapshot.hasData ||
                        commentSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No comments yet."));
                    }

                    final comments = commentSnapshot.data!.docs;

                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final commentData =
                            comments[index].data() as Map<String, dynamic>;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                commentData['profile_image'] ?? ''),
                          ),
                          title: Row(
                            children: [
                              Text(commentData['username'] ?? 'Anonymous'),
                              const SizedBox(width: 8),
                              Text(
                                commentData['timestamp'] != null
                                    ? formatTimeAgo(
                                        (commentData['timestamp'] as Timestamp)
                                            .toDate())
                                    : '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(commentData['content'] ?? ''),
                          trailing: (commentData['userId'] == currentUserId)
                              ? IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  color: Colors.redAccent,
                                  onPressed: () =>
                                      _deleteComment(comments[index].id),
                                )
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
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
                  final user = FirebaseAuth.instance.currentUser;

                  if (commentText.isNotEmpty && user != null) {
                    // Fetch user info from Firestore
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();
                    final userData = userDoc.data();

                    if (userData != null) {
                      await FirebaseFirestore.instance
                          .collection('tbl_comments')
                          .add({
                        'postId': postId,
                        'userId': user.uid,
                        'username': userData['username'] ?? '',
                        'profile_image': userData['profile_image'] ?? '',
                        'content': commentText,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      _commentController.clear();
                    }
                  }
                },
                child: const Text('Post Comment'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('tbl_comments')
          .doc(commentId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment deleted!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error deleting comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete comment: $e'),
            duration: Duration(seconds: 2),
          ),
        );
      }
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
      body: _trips.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _trips.length,
                    onPageChanged: _onPageChanged,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final scale = 1.0 -
                          (_currentPage - index).abs().clamp(0.0, 1.0) * 0.15;
                      final trip = _trips[index];
                      final data = _tripData[index];
                      final likes = List<String>.from(data['likes'] ?? []);

                      return Center(
                        child: Transform.scale(
                          scale: scale,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TripCarouselScreen(trip: trip),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
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
                                            placeholder: (context, url) =>
                                                const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              color: Colors.grey[300],
                                              width: double.infinity,
                                              height: double.infinity,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.broken_image,
                                                      size: 48,
                                                      color: Colors.grey),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Failed to load image',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey[300],
                                            width: double.infinity,
                                            height: double.infinity,
                                            child: const Icon(
                                                Icons.image_not_supported),
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
                                            backgroundImage:
                                                data['profile_image'] != null &&
                                                        data['profile_image']
                                                            .isNotEmpty
                                                    ? NetworkImage(
                                                        data['profile_image'])
                                                    : const AssetImage(
                                                            "assets/logo.jpg")
                                                        as ImageProvider,
                                            radius: 18,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            data['username'] ?? 'Anonymous',
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
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  likes.contains(FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          ?.uid)
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  _toggleLike(
                                                      data['postId'], likes);
                                                },
                                              ),
                                              Text(
                                                likes.length.toString(),
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 16),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.mode_comment_outlined,
                                                color: Colors.white),
                                            onPressed: () {
                                              _showCommentModal(
                                                  context, data['postId']);
                                            },
                                          ),
                                          const SizedBox(height: 4),
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
                  children: List.generate(_trips.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      height: 8,
                      width: _currentPage.round() == index ? 16 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage.round() == index
                            ? Colors.white
                            : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
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
