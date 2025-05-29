import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'trip_post_model.dart';

class TripCarouselScreen extends StatefulWidget {
  final TripPost trip;

  const TripCarouselScreen({super.key, required this.trip});

  @override
  State<TripCarouselScreen> createState() => _TripCarouselScreenState();
}

class _TripCarouselScreenState extends State<TripCarouselScreen> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.trip.imageUrls.isNotEmpty) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.trip.imageUrls.isEmpty) return;
    
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentIndex < widget.trip.imageUrls.length - 1) {
        setState(() => _currentIndex++);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _onTap(bool next) {
    if (widget.trip.imageUrls.isEmpty) return;
    
    _timer?.cancel();
    setState(() {
      if (next && _currentIndex < widget.trip.imageUrls.length - 1) {
        _currentIndex++;
      } else if (!next && _currentIndex > 0) {
        _currentIndex--;
      }
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    
    if (trip.imageUrls.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image_not_supported, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                'No images available',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 24),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }

    // Ensure current index is valid
    if (_currentIndex >= trip.imageUrls.length) {
      _currentIndex = 0;
    }

    final imageUrl = trip.imageUrls[_currentIndex];
    final description = trip.descriptions.isNotEmpty && _currentIndex < trip.descriptions.length
        ? trip.descriptions[_currentIndex]
        : '';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (details) {
              final width = MediaQuery.of(context).size.width;
              _onTap(details.localPosition.dx > width / 2);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, color: Colors.white, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(color: Colors.black.withOpacity(0.3)),
              ],
            ),
          ),
          if (trip.imageUrls.length > 1) ...[
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Row(
                children: trip.imageUrls.asMap().entries.map((entry) {
                  final isActive = entry.key == _currentIndex;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (description.isNotEmpty)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (trip.imageUrls.length > 1)
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${trip.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
