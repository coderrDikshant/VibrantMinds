import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../../models/quiz_models/user_stats.dart';
import '../../services/firestore_service.dart';
import '../../theme/vibrant_theme.dart';
import 'stats_screen.dart';

class PreviousStatsScreen extends StatefulWidget {
  final String name;
  final String email;

  const PreviousStatsScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<PreviousStatsScreen> createState() => _PreviousStatsScreenState();
}

class _PreviousStatsScreenState extends State<PreviousStatsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<UserStats> _previousStats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _fetchPreviousStats();
  }

  Future<void> _fetchPreviousStats() async {
    try {
      final stats = await FirestoreService(FirebaseFirestore.instance)
          .getUserStatsByEmail(widget.email);
      if (mounted) {
        setState(() {
          _previousStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching previous stats: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Quiz Stats'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [VibrantTheme.backgroundColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? Center(
          child: Lottie.asset(
            'assets/animations/loading_animation.json',
            width: 100,
            height: 100,
          ),
        )
            : _previousStats.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/empty_state.json',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 16),
              Text(
                'No previous quiz stats found!',
                style: VibrantTheme.themeData.textTheme.titleLarge?.copyWith(
                  color: VibrantTheme.primaryColor,
                ),
              ),
            ],
          ),
        )
            : FadeTransition(
          opacity: _fadeAnimation,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _previousStats.length,
            itemBuilder: (context, index) {
              final stats = _previousStats[index];
              return _StatsCard(
                stats: stats,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StatsScreen(stats: stats),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatefulWidget {
  final UserStats stats;
  final VoidCallback onTap;

  const _StatsCard({
    required this.stats,
    required this.onTap,
  });

  @override
  State<_StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<_StatsCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.stats.category,
                  style: VibrantTheme.themeData.textTheme.titleLarge?.copyWith(
                    color: VibrantTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quiz: ${widget.stats.quizId}',
                  style: VibrantTheme.themeData.textTheme.bodyMedium,
                ),
                Text(
                  'Difficulty: ${widget.stats.difficulty}',
                  style: VibrantTheme.themeData.textTheme.bodyMedium,
                ),
                Text(
                  'Score: ${widget.stats.score} / ${widget.stats.totalQuestions}',
                  style: VibrantTheme.themeData.textTheme.bodyMedium,
                ),
                Text(
                  'Time Taken: ${widget.stats.timeTakenSeconds ~/ 60}:${(widget.stats.timeTakenSeconds % 60).toString().padLeft(2, '0')}',
                  style: VibrantTheme.themeData.textTheme.bodyMedium,
                ),
                Text(
                  'Date: ${widget.stats.timestamp.toLocal().toString().split('.')[0]}',
                  style: VibrantTheme.themeData.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}