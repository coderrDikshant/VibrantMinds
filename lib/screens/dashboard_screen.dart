import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_stats.dart';
import '../services/firestore_service.dart';
import '../widgets/stats_summary_card.dart';
import 'excel_upload_screen.dart';
import 'user_stats_screen.dart';
import 'quiz_stats_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: FutureBuilder<List<UserStats>>(
        future: firestoreService.getAllUserStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading stats'));
          }
          final stats = snapshot.data ?? [];
          final totalUsers = stats.map((s) => s.userId).toSet().length;
          final totalQuizzes = stats.length;
          final averageScore = stats.isEmpty
              ? 0.0
              : stats
              .map((s) => s.score / s.totalQuestions * 100)
              .reduce((a, b) => a + b) /
              stats.length;

          return SingleChildScrollView(
            child: Column(
              children: [
                StatsSummaryCard(
                  totalUsers: totalUsers,
                  totalQuizzes: totalQuizzes,
                  averageScore: averageScore,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExcelUploadScreen(),
                      ),
                    );
                  },
                  child: const Text('Upload Questions'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserStatsScreen(stats: stats),
                      ),
                    );
                  },
                  child: const Text('View User Stats'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizStatsScreen(stats: stats),
                      ),
                    );
                  },
                  child: const Text('View Quiz Stats'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}