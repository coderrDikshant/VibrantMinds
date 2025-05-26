import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:user_end/screens/job_screen/job_list_screen.dart';
import '../../widgets/success_story_cards/success_stories.dart';
import '../../screens/quiz_screens/quiz_entry_screen.dart';
import '../../screens/blog_screen/blog_screen.dart';
import '../../screens/home_screen/home_screen.dart';
import '../../screens/feedback_screen.dart';
import '../../screens/contact_us_screen.dart';
import '../../theme/vibrant_theme.dart';
import '../../screens/bookmark_screen.dart';
import '../../screens/notificaion_screen.dart';

class RoleBasedHome extends StatefulWidget {
  const RoleBasedHome({super.key});

  @override
  State<RoleBasedHome> createState() => _RoleBasedHomeState();
}

class _RoleBasedHomeState extends State<RoleBasedHome> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  String _userEmail = '';
  String _userName = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserAttributes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserAttributes() async {
    try {
      final result = await Amplify.Auth.fetchUserAttributes();
      final email = result.firstWhere(
            (attr) => attr.userAttributeKey.key == 'email',
        orElse: () => const AuthUserAttribute(
          userAttributeKey: CognitoUserAttributeKey.email,
          value: '',
        ),
      ).value;

      final name = result.firstWhere(
            (attr) => attr.userAttributeKey.key == 'name',
        orElse: () => const AuthUserAttribute(
          userAttributeKey: CognitoUserAttributeKey.name,
          value: '',
        ),
      ).value;

      setState(() {
        _userEmail = email;
        _userName = name;
        _loading = false;
      });
    } catch (e) {
      safePrint("Failed to fetch user attributes: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  void _navigateTo(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      _currentIndex = index;
    });
    Navigator.of(context).pop();
  }

  void _logout(BuildContext context) async {
    try {
      await Amplify.Auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out')),
      );
    } catch (e) {
      safePrint("Sign out error: $e");
    }
  }

  void _bookmark(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookmarkScreen()),
    );
  }

  void _showNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NotificationScreen()),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String title, required int pageIndex}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD32F2F)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
          color: Colors.black,
        ),
      ),
      onTap: () => _navigateTo(pageIndex),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.transparent,
      hoverColor: Colors.grey[100],
    );
  }

  Widget _buildDrawer() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Drawer(
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD32F2F), Color(0xFFE57373)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Container(
                height: screenHeight * 0.25,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 8 : 16,
                  horizontal: isSmallScreen ? 12 : 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: isSmallScreen ? 36 : 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.lightbulb,
                          size: isSmallScreen ? 36 : 60,
                          color: const Color(0xFFD32F2F)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'VibrantMinds Technologies',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail.isNotEmpty
                          ? _userEmail
                          : 'user@vibrantminds.tech',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.white70,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        _buildDrawerItem(context, icon: Icons.home, title: 'Home', pageIndex: 0),
                        _buildDrawerItem(context, icon: Icons.quiz, title: 'Quizzes', pageIndex: 1),
                        _buildDrawerItem(context, icon: Icons.star, title: 'Success Stories', pageIndex: 2),
                        _buildDrawerItem(context, icon: Icons.book, title: 'Blogs', pageIndex: 3),
                        _buildDrawerItem(context, icon: Icons.work, title: 'Jobs', pageIndex: 4),
                        _buildDrawerItem(context, icon: Icons.feedback, title: 'Feedback', pageIndex: 5),
                        _buildDrawerItem(context, icon: Icons.contact_support, title: 'Contact Us', pageIndex: 6),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 8 : 16,
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: Size(double.infinity, isSmallScreen ? 45 : 50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'VibrantMinds Tech',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000000),
            fontFamily: 'Poppins',
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD32F2F)),
        actions: [
          IconButton(
            icon: const Icon(Icons.task_alt, color: Color(0xFFD32F2F)),
            onPressed: () => _bookmark(context),
            tooltip: 'Applied Jobs',
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Color(0xFFD32F2F)),
                onPressed: () => _showNotifications(context),
                tooltip: 'Notifications',
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          HomeScreen(navigateTo: (context, route) => _navigateTo(_getPageIndex(route))),
          QuizEntryScreen(name: _userName, email: _userEmail),
          SuccessStoryPage(userEmail: _userEmail, userName: _userName),
          BlogScreen(userEmail: _userEmail, userName: _userName),
          JobListScreen(userEmail: _userEmail),
          FeedbackScreen(userEmail: _userEmail),
          ContactUsScreen(userEmail: _userEmail),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: VibrantTheme.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, Icons.home_outlined, "Home"),
            _buildNavItem(1, Icons.quiz, Icons.help_outline, "Quiz"),
            _buildNavItem(2, Icons.star, Icons.star_outline, "Stories"),
            _buildNavItem(3, Icons.article, Icons.article_outlined, "Blog"),
            _buildNavItem(4, Icons.work, Icons.work_outline, "Jobs"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : inactiveIcon,
            color: isActive ? const Color(0xFFD32F2F) : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFD32F2F) : Colors.grey,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  int _getPageIndex(String route) {
    switch (route) {
      case 'Home':
        return 0;
      case 'Quizzes':
        return 1;
      case 'Success Stories':
        return 2;
      case 'Blogs':
        return 3;
      case 'Jobs':
        return 4;
      case 'Feedback':
        return 5;
      case 'Contact Us':
        return 6;
      default:
        return _currentIndex;
    }
  }
}
