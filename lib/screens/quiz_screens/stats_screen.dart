import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../models/quiz_models/question.dart';
import '../../models/quiz_models/user_stats.dart';
import '../../theme/vibrant_theme.dart';

class StatsScreen extends StatefulWidget {
  final UserStats stats;

  const StatsScreen({super.key, required this.stats});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: widget.stats.score.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [VibrantTheme.backgroundColor, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView(
                children: [
                  _buildHeaderInfo(),
                  const SizedBox(height: 16),
                  _buildScoreSummary(),
                  const Divider(height: 32, thickness: 1.5),
                  Text(
                    'Questions Overview:',
                    style: VibrantTheme.themeData.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  ...widget.stats.questions.map((q) => _buildQuestionCard(q)).toList(),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Lottie.asset(
                'assets/animations/particle_animation.json',

                // 'https://assets.lottiefiles.com/packages/lf20_jbdmfj13.json',
                fit: BoxFit.cover,
                // width: 150,
                // height: MediaQuery.of(context).size.height,
              ),
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildHeaderInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF9F9F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('User', '${widget.stats.name} (${widget.stats.email})'),
            _buildInfoRow('Category', widget.stats.category),
            _buildInfoRow('Quiz ID', widget.stats.quizId),
            _buildInfoRow('Difficulty', widget.stats.difficulty),
            _buildInfoRow('Time Taken', '${widget.stats.timeTakenSeconds} seconds'),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSummary() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              VibrantTheme.primaryColor.withOpacity(0.1),
              VibrantTheme.primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                return Text(
                  'Score: ${(_scoreAnimation.value).round()} / ${widget.stats.totalQuestions}',
                  style: VibrantTheme.themeData.textTheme.headlineLarge?.copyWith(
                    color: VibrantTheme.primaryColor,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreChip('Correct', widget.stats.correctAnswers, Colors.green),
                _buildScoreChip('Wrong', widget.stats.wrongAnswers, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: VibrantTheme.themeData.textTheme.bodyLarge,
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold, color: VibrantTheme.primaryColor),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChip(String label, int count, Color chipColor) {
    return Chip(
      backgroundColor: chipColor.withOpacity(0.2),
      label: Text(
        '$label: $count',
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF9F9F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: VibrantTheme.themeData.textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Your Answer: ${question.selectedOption ?? "Not Answered"}',
              style: TextStyle(
                color: question.selectedOption == question.correctAnswer ? Colors.green : Colors.red,
              ),
            ),
            Text(
              'Correct Answer: ${question.correctAnswer}',
              style: VibrantTheme.themeData.textTheme.bodyLarge,
            ),
            if (question.explanation.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Explanation: ${question.explanation}',
                  style: VibrantTheme.themeData.textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}