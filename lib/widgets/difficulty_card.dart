import 'package:flutter/material.dart';

class DifficultyCard extends StatelessWidget {
  final String difficulty;
  final VoidCallback onTap;

  const DifficultyCard({super.key, required this.difficulty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          difficulty.toUpperCase(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
      ),
    );
  }
}