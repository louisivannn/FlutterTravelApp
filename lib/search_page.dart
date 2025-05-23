import 'package:flutter/material.dart';
import 'profile.dart'; // Import your ProfilePage here

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _allPosts = [
    "Ivan Virgo - Japan Trip",
    "Mark Reyes - Baguio",
    "Anna Lim - Palawan",
    "Carlos Miguel - Ilocos",
  ];

  List<String> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    _filteredResults = _allPosts;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredResults = _allPosts
          .where((post) => post.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar with cancel button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Search profiles or posts",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Separator line
            const Divider(
              height: 1,
              thickness: 1,
              color: Colors.white10,
            ),

            // Search results
            Expanded(
              child: _filteredResults.isEmpty
                  ? const Center(child: Text("No results found"))
                  : ListView.builder(
                itemCount: _filteredResults.length,
                itemBuilder: (context, index) {
                  final result = _filteredResults[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage("assets/logo.jpg"),
                    ),
                    title: Text(result),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Tapped on $result")),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
