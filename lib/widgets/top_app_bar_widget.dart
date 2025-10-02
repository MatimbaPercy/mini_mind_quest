import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // this will be quest.title

  const TopAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        children: [
          Text(
            title, // 👈 now using quest.title here
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Sharpen your mind, one quest at a time.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0, // flat modern look
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);
}
