import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
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
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentIndex < widget.trip.images.length - 1) {
        setState(() => _currentIndex++);
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _onTap(bool next) {
    _timer?.cancel();
    setState(() {
      if (next && _currentIndex < widget.trip.images.length - 1) {
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
    final image = trip.images[_currentIndex];
    final description = trip.descriptions[_currentIndex];

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
                Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                ),
                Container(color: Colors.black.withOpacity(0.2)),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              children: trip.images.asMap().entries.map((entry) {
                final isActive = entry.key <= _currentIndex;
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
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Text(
              description,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
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
        ],
      ),
    );
  }
}
