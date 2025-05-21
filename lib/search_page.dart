import 'package:flutter/material.dart';
import 'profile.dart';
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  // Dummy data simulating profiles or posts to search from
  final List<String> _allPosts = [
    "Ivan Virgo - Japan Trip",
    "Mark Reyes - Baguio",
    "Anna Lim - Palawan",
    "Carlos Miguel - Ilocos",
  ];

  // Results filtered based on search query
  List<String> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    // Initialize filtered results with all posts initially
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
    _searchController.dispose(); // Dispose controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Search",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF353566),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search profiles or posts",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
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
                    // Placeholder action on tap
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
    );
  }
}
