import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.white10, // Top black border
            width: 1.0,
          ),
        ),
      ),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabIcon(Icons.home, "Home", 0),
          _buildTabIcon(Icons.search, "Search", 1),
          _buildTabIcon(Icons.add_circle_outline, "Add", 2),
          _buildTabIcon(Icons.person, "Profile", 3),
        ],
      ),
    );
  }

  Widget _buildTabIcon(IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;
    final Color selectedColor = const Color(0xFF353566);
    final Color unselectedColor = const Color(0xFFB3B3D1);

    return GestureDetector(
      onTap: () => onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? selectedColor : unselectedColor,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? selectedColor : unselectedColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
