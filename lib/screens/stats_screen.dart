import 'package:flutter/material.dart';
import '../../models/user_stats.dart';
import '../../widgets/stats_card.dart';
import 'category_selection_screen.dart';

class StatsScreen extends StatelessWidget {
  final UserStats stats;

  const StatsScreen({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Stats')),
      body: Column(
        children: [
          StatsCard(stats: stats),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CategorySelectionScreen(
                    userId: stats.userId,
                    name: stats.name,
                    email: stats.email,
                  ),
                ),
              );
            },
            child: const Text('Back to Categories'),
          ),
        ],
      ),
    );
  }
}