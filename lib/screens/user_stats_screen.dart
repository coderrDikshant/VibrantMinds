import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/user_stats.dart';
import '../widgets/user_stats_card.dart';

class UserStatsScreen extends StatelessWidget {
  final List<UserStats> stats;

  const UserStatsScreen({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    debugPrint('UserStatsScreen: Displaying ${stats.length} stats');
    return Scaffold(
      appBar: AppBar(title: const Text('User Stats')),
      body: stats.isEmpty
          ? const Center(child: Text('No user stats available'))
          : ListView.builder(
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          debugPrint(
              'Rendering stat: ${stat.name}, ${stat.email}, ${stat.category}, ${stat.quizId}');
          return UserStatsCard(stats: stat);
        },
      ),
    );
  }
}