import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TopAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        children: [
          // 🎨 Fun title
          Text(
            title,
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              shadows: [
                Shadow(
                  color: Colors.pinkAccent.withOpacity(0.5),
                  offset: const Offset(2, 2),
                  blurRadius: 3,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          // 🧠 Subtitle for encouragement
          Text(
            'Sharpen your mind, one quest at a time!',
            style: TextStyle(
              color: Colors.orangeAccent.withOpacity(0.9),
              fontStyle: FontStyle.italic,
              fontSize: 13,
              shadows: [
                Shadow(
                  color: Colors.yellowAccent.withOpacity(0.4),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: Colors.yellow.shade100, // soft kid-friendly background
      elevation: 4,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
