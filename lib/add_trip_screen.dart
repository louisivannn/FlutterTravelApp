import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:final_proj/profile.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  int _currentIndex = 0;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser?.uid;
  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles);
        _currentIndex = 0;
      });
    }
  }

  Future<void> _postTrip() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select images first.")),
      );
      return;
    }

    try {
      List<String> imageUrls = [];
      for (XFile image in _selectedImages) {
        File file = File(image.path);
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref('trip_images/$fileName.jpg')
            .putFile(file);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      await FirebaseFirestore.instance.collection('trips').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'images': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trip posted to Firebase!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  int _validIndex(int index) {
    if (_selectedImages.isEmpty) return 0;
    return index.clamp(0, _selectedImages.length - 1);
  }

  Widget _buildImageCarousel(double height) {
    if (_selectedImages.isEmpty) {
      return GestureDetector(
        onTap: _pickImages,
        child: Container(
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
          ),
        ),
      );
    } else {
      final validIndex = _validIndex(_currentIndex);
      if (validIndex >= _selectedImages.length) {
        return Container(
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.error, size: 50, color: Colors.red),
          ),
        );
      }
      return Stack(
        children: [
          Image.file(
            File(_selectedImages[validIndex].path),
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
          ),
          if (_selectedImages.length > 1)
            Positioned(
              left: 8,
              top: height / 2 - 24,
              child: _navButton(Icons.arrow_back, () {
                setState(() {
                  _currentIndex =
                      (_currentIndex - 1 + _selectedImages.length) %
                          _selectedImages.length;
                });
              }),
            ),
          if (_selectedImages.length > 1)
            Positioned(
              right: 8,
              top: height / 2 - 24,
              child: _navButton(Icons.arrow_forward, () {
                setState(() {
                  _currentIndex = (_currentIndex + 1) % _selectedImages.length;
                });
              }),
            ),
        ],
      );
    }
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: Colors.black45,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
        title: const Text(
          "Add Trip",
          style: TextStyle(color: Colors.white, fontFamily: 'ArchivoBlack'),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF353566),
      ),
      body: Column(
        children: [
          _buildImageCarousel(screenHeight * 0.45),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _pickImages,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: "Where is this?",
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration.collapsed(
                          hintText: "Description.."),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _postTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF353566),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Text(
                          "Post Trip",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
