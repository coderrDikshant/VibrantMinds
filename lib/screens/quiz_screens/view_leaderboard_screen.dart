import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import "package:get/get.dart";
import '../../theme/vibrant_theme.dart';
import '../../utils/constants.dart';
import '../../services/firestore_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final String name;
  final String email;

  const LeaderboardScreen({super.key, required this.name, required this.email});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}


class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  List<Map<String, dynamic>> _leaderboard = [];
  Map<String, Map<String, dynamic>> _userQuizRanks = {};
  double? _userOverallRank;
  int _totalParticipants = 0;

  final FirestoreService _firestoreService = FirestoreService(FirebaseFirestore.instance);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _fetchLeaderboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.email.isEmpty) {
        print('Error: widget.email is empty');
        setState(() {
          _isLoading = false;
          _leaderboard = [];
          _userQuizRanks = {};
          _userOverallRank = null;
          _totalParticipants = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid user email', style: VibrantTheme.themeData.textTheme.bodyMedium),
            backgroundColor: VibrantTheme.errorColor,
          ),
        );
        return;
      }

      List<Map<String, dynamic>> leaderboard = [];
      Map<String, Map<String, dynamic>> userQuizRanks = {};
      int? userOverallRank;
      Set<String> uniqueUsers = {};

      final quizResults = await _firestoreService.getQuizResults();
      if (quizResults.isEmpty) {
        print('No quiz results found');
        setState(() {
          _isLoading = false;
          _leaderboard = [];
          _userQuizRanks = {};
          _userOverallRank = null;
          _totalParticipants = 0;
        });
        return;
      }

      Map<String, List<Map<String, dynamic>>> quizResultsByQuiz = {};
      for (var result in quizResults) {
        final quizId = result['quizId'] as String? ?? '';
        if (quizId.isEmpty) {
          print('Skipping result with empty quizId: $result');
          continue;
        }
        if (!quizResultsByQuiz.containsKey(quizId)) {
          quizResultsByQuiz[quizId] = [];
        }
        quizResultsByQuiz[quizId]!.add(result);
      }

      Map<String, double> userAverageScores = {};
      for (var quizId in quizResultsByQuiz.keys) {
        quizResultsByQuiz[quizId]!.sort((a, b) {
          final scoreA = a['score'] as num? ?? 0;
          final scoreB = b['score'] as num? ?? 0;
          final scoreCompare = scoreB.compareTo(scoreA);
          if (scoreCompare == 0) {
            final timestampA = a['timestamp'] as Timestamp? ?? Timestamp.now();
            final timestampB = b['timestamp'] as Timestamp? ?? Timestamp.now();
            return timestampA.compareTo(timestampB);
          }
          return scoreCompare;
        });

        int rank = 1;
        for (int i = 0; i < quizResultsByQuiz[quizId]!.length; i++) {
          final result = quizResultsByQuiz[quizId]![i];
          final userEmail = result['userEmail'] as String? ?? '';
          if (userEmail.isEmpty) {
            print('Skipping result with empty userEmail: $result');
            continue;
          }
          uniqueUsers.add(userEmail);

          if (!userQuizRanks.containsKey(userEmail)) {
            userQuizRanks[userEmail] = {};
          }
          userQuizRanks[userEmail]![quizId] = {
            'rank': rank,
            'score': result['score'] as num? ?? 0,
            'totalParticipants': quizResultsByQuiz[quizId]!.length,
            'userName': result['userName'] as String? ?? 'Unknown',
          };

          userAverageScores[userEmail] =
              (userAverageScores[userEmail] ?? 0) + (result['score'] as num? ?? 0);
          if (i < quizResultsByQuiz[quizId]!.length - 1 &&
              quizResultsByQuiz[quizId]![i]['score'] != quizResultsByQuiz[quizId]![i + 1]['score']) {
            rank = i + 2;
          }
        }
      }

      final sortedUsers = userAverageScores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (int i = 0; i < sortedUsers.length; i++) {
        if (sortedUsers[i].key == widget.email) {
          userOverallRank = i + 1;
          break;
        }
      }

      for (int i = 0; i < sortedUsers.length && i < 10; i++) {
        final userEmail = sortedUsers[i].key;
        final quizCount = userQuizRanks[userEmail]?.length ?? 1;
        leaderboard.add({
          'userEmail': userEmail,
          'userName': userQuizRanks[userEmail]?.values.first['userName'] as String? ?? 'Unknown',
          'averageScore': userAverageScores[userEmail]! / quizCount,
          'rank': i + 1,
        });
      }

      print('widget.email: ${widget.email}');
      print('userQuizRanks[widget.email]: ${userQuizRanks[widget.email]}');

      setState(() {
        _leaderboard = leaderboard;
        // _userQuizRanks = userQuizRanks[widget.email] ?? <String, Map<String, dynamic>>{};
        _userOverallRank = userOverallRank?.toDouble();
        _totalParticipants = uniqueUsers.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching leaderboard: $e');
      setState(() {
        _isLoading = false;
        _leaderboard = [];
        _userQuizRanks = {};
        _userOverallRank = null;
        _totalParticipants = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching leaderboard: $e',
              style: VibrantTheme.themeData.textTheme.bodyMedium),
          backgroundColor: VibrantTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: VibrantTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Leaderboard', style: VibrantTheme.themeData.appBarTheme.titleTextStyle),
        backgroundColor: VibrantTheme.surfaceColor,
        foregroundColor: VibrantTheme.primaryColor,
        elevation: VibrantTheme.themeData.appBarTheme.elevation,
      ),
      // ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchLeaderboard,
          color: VibrantTheme.primaryColor,
          backgroundColor: VibrantTheme.surfaceColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User's Overall Rank
                  if (!_isLoading && _userOverallRank != null)
                    _buildUserRankCard(isSmallScreen),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  // Leaderboard Title
                  Text(
                    'Top Champions',
                    style: VibrantTheme.themeData.textTheme.headlineLarge,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  // Leaderboard List
                  if (_isLoading)
                    Center(
                      child: Lottie.asset(
                        'assets/animations/loading_trophy.json',
                        width: isSmallScreen ? 120 : 150,
                        height: isSmallScreen ? 120 : 150,
                        fit: BoxFit.contain,
                      ),
                    )
                  else if (_leaderboard.isEmpty)
                    _buildEmptyState(isSmallScreen)
                  else
                    _buildLeaderboardList(isSmallScreen),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  // User's Individual Quiz Ranks
                  if (_userQuizRanks.isNotEmpty)
                    Text(
                      'Your Quiz Ranks',
                      style: VibrantTheme.themeData.textTheme.headlineLarge,
                    ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  if (_userQuizRanks.isNotEmpty)
                    _buildUserQuizRanks(isSmallScreen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserRankCard(bool isSmallScreen) {
    return Card(
      color: VibrantTheme.surfaceColor,
      elevation: VibrantTheme.themeData.cardTheme.elevation,
      shape: VibrantTheme.themeData.cardTheme.shape,
      margin: VibrantTheme.themeData.cardTheme.margin,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              VibrantTheme.primaryColor.withOpacity(0.1),
              VibrantTheme.surfaceColor
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: VibrantTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Row(
          children: [
            SizedBox(
              width: isSmallScreen ? 50 : 60,
              height: isSmallScreen ? 50 : 60,
              child: Lottie.asset(
                _userOverallRank! <= 3
                    ? 'assets/animations/${_userOverallRank!.toInt() == 1 ? 'gold' : _userOverallRank!.toInt() == 2 ? 'silver' : 'silver'}_medal.json'
                    : 'assets/animations/gold_medal.json', // Fallback
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Rank',
                    style: VibrantTheme.themeData.textTheme.headlineMedium,
                  ),
                  Text(
                    '#${_userOverallRank!.toInt()} of $_totalParticipants',
                    style: VibrantTheme.themeData.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/empty_trophy.json',
            width: isSmallScreen ? 120 : 150,
            height: isSmallScreen ? 120 : 150,
            fit: BoxFit.contain,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'No Champions Yet!',
            style: VibrantTheme.themeData.textTheme.bodyLarge,
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          ElevatedButton(
            onPressed: _fetchLeaderboard,
            style: VibrantTheme.themeData.elevatedButtonTheme.style,
            child: Text(
              'Refresh',
              style: VibrantTheme.themeData.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(bool isSmallScreen) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _leaderboard.length,
      itemBuilder: (context, index) {
        final entry = _leaderboard[index];
        final isCurrentUser = entry['userEmail'] == widget.email;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final animation = CurvedAnimation(
              parent: _controller,
              curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
            );
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: Card(
            color: VibrantTheme.surfaceColor,
            elevation: VibrantTheme.themeData.cardTheme.elevation,
            shape: VibrantTheme.themeData.cardTheme.shape,
            margin: VibrantTheme.themeData.cardTheme.margin,
            child: Container(
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? VibrantTheme.primaryColor.withOpacity(0.05)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrentUser
                      ? VibrantTheme.primaryColor
                      : VibrantTheme.greyTextColor.withOpacity(0.3),
                  width: isCurrentUser ? 2 : 1,
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 8 : 12,
                ),
                leading: SizedBox(
                  width: isSmallScreen ? 40 : 50,
                  height: isSmallScreen ? 40 : 50,
                  child: Lottie.asset(
                    index == 0
                        ? 'assets/animations/gold_medal.json'
                        : index == 1
                        ? 'assets/animations/silver_medal.json'
                        : index == 2
                        ? 'assets/animations/silver_medal.json'
                        : 'assets/animations/gold_medal.json', // Fallback
                    fit: BoxFit.contain,
                  ),
                ),
                title: Text(
                  entry['userName'],
                  style: VibrantTheme.themeData.textTheme.bodyLarge?.copyWith(
                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    color: isCurrentUser
                        ? VibrantTheme.primaryColor
                        : VibrantTheme.textColor,
                  ),
                ),
                subtitle: Text(
                  'Avg Score: ${entry['averageScore'].toStringAsFixed(2)}',
                  style: VibrantTheme.themeData.textTheme.labelMedium,
                ),
                trailing: Text(
                  '#${entry['rank']}',
                  style: VibrantTheme.themeData.textTheme.headlineMedium?.copyWith(
                    color: index == 0
                        ? Colors.yellow[700]
                        : index == 1
                        ? Colors.grey[400]
                        : index == 2
                        ? Colors.brown[400]
                        : VibrantTheme.textColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserQuizRanks(bool isSmallScreen) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _userQuizRanks.length,
      itemBuilder: (context, index) {
        final quizId = _userQuizRanks.keys.elementAt(index);
        final rankData = _userQuizRanks[quizId]!;
        return Card(
          color: VibrantTheme.surfaceColor,
          elevation: VibrantTheme.themeData.cardTheme.elevation,
          shape: VibrantTheme.themeData.cardTheme.shape,
          margin: VibrantTheme.themeData.cardTheme.margin,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  VibrantTheme.primaryColor.withOpacity(0.1),
                  VibrantTheme.surfaceColor
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiz: $quizId',
                  style: VibrantTheme.themeData.textTheme.headlineMedium,
                ),
                SizedBox(height: isSmallScreen ? 4 : 8),
                Text(
                  'Rank ${rankData['rank']} of ${rankData['totalParticipants']}',
                  style: VibrantTheme.themeData.textTheme.bodyMedium,
                ),
                Text(
                  'Score: ${rankData['score']}',
                  style: VibrantTheme.themeData.textTheme.labelMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}