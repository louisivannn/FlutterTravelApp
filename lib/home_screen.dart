import 'dart:io';
import 'package:flutter/material.dart';
import 'package:final_proj/bottom_navbar.dart';
import 'profile.dart';
import 'search_page.dart';
import 'add_trip_screen.dart';
import 'trip_post_model.dart';
import 'trip_carousel_screen.dart';

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

    if (index == 0) {
      // Already on HomeScreen, do nothing
    } else if (index == 1) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Tripmatic",
          style: TextStyle(
            fontFamily: 'ArchivoBlack',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        backgroundColor: const Color(0xFF353566),
      ),
      body: localTripPosts.isEmpty
          ? const Center(child: Text("No posts yet", style: TextStyle(color: Colors.black)))
          : Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: localTripPosts.length,
              itemBuilder: (context, index) {
                final scale = (1 - (_currentPage - index).abs()).clamp(0.85, 1.0);
                final trip = localTripPosts[index];

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
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
                              Image.file(
                                File(trip.images[0].path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
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
                                  children: const [
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
                                  children: const [
                                    Icon(Icons.favorite_border, color: Colors.white),
                                    SizedBox(width: 16),
                                    Icon(Icons.mode_comment_outlined, color: Colors.white),
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
            children: List.generate(localTripPosts.length, (index) {
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
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
