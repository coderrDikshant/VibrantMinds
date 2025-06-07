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
import '../../screens/chatbot_screen.dart';
import '../../screens/view_profile_screen.dart'; // Added import for profile screen
import '../../main.dart';

class RoleBasedHome extends StatefulWidget {
  final String firstName;
  final String lastName;

  const RoleBasedHome({
    super.key,
    required this.firstName,
    required this.lastName,
  });

  @override
  State<RoleBasedHome> createState() => _RoleBasedHomeState();
}

class _RoleBasedHomeState extends State<RoleBasedHome> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  String _userEmail = '';
  String get _firstName => widget.firstName;
  String get _lastName => widget.lastName;

  bool _loading = true;

  bool _showChatBot = true;
  Offset _chatBotPosition = const Offset(20, 400);

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

      setState(() {
        _userEmail = email;
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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthApp()),
        (route) => false,
      );
    } catch (e) {
      safePrint("Sign out error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed')),
      );
    }
  }

  void _bookmark(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AppliedJobsScreen(userEmail: _userEmail)),
    );
  }

  void _showNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NotificationScreen()),
    );
  }

  void talkWithChatbot(BuildContext context, String userEmail, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatBotScreen(
          userEmail: userEmail,
          userName: userName,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon,
      required String title,
      required int pageIndex}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD32F2F)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      onTap: () => _navigateTo(pageIndex),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
            onPressed: () {
              Navigator.of(ctx).pop();
              _logout(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
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
                      child: Icon(
                        Icons.lightbulb,
                        size: isSmallScreen ? 36 : 60,
                        color: const Color(0xFFD32F2F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Text(
                        (_firstName.isNotEmpty && _lastName.isNotEmpty)
                            ? '$_firstName $_lastName'
                            : 'Guest User',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        _userEmail.isNotEmpty
                            ? _userEmail
                            : 'user@vibrantminds.tech',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.white70,
                          fontFamily: 'Roboto',
                        ),
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
                        _buildDrawerItem(context,
                            icon: Icons.person, title: 'View Profile', pageIndex: 7),
                        _buildDrawerItem(context,
                            icon: Icons.home, title: 'Home', pageIndex: 0),
                        _buildDrawerItem(context,
                            icon: Icons.quiz, title: 'Quizzes', pageIndex: 1),
                        _buildDrawerItem(context,
                            icon: Icons.star, title: 'Success Stories', pageIndex: 2),
                        _buildDrawerItem(context,
                            icon: Icons.book, title: 'Blogs', pageIndex: 3),
                        _buildDrawerItem(context,
                            icon: Icons.work, title: 'Jobs', pageIndex: 4),
                        _buildDrawerItem(context,
                            icon: Icons.feedback, title: 'Feedback', pageIndex: 5),
                        _buildDrawerItem(context,
                            icon: Icons.contact_support, title: 'Contact Us', pageIndex: 6),
                        SwitchListTile(
                          title: const Text('Show ChatBot'),
                          value: _showChatBot,
                          onChanged: (value) {
                            setState(() {
                              _showChatBot = value;
                            });
                          },
                          secondary: const Icon(Icons.smart_toy),
                        ),
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
                  onPressed: () => _showLogoutConfirmationDialog(context),
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
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFD32F2F),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              HomeScreen(
                navigateTo: (context, route) => _navigateTo(_getPageIndex(route)),
                username: _firstName, // only first name here
                email: _userEmail,
              ),
              QuizEntryScreen(name: _firstName, email: _userEmail),
              SuccessStoryPage(userEmail: _userEmail, userName: _firstName),
              BlogScreen(userEmail: _userEmail, userName: _firstName),
              JobListScreen(userEmail: _userEmail),
              FeedbackScreen(userEmail: _userEmail),
              ContactUsScreen(userEmail: _userEmail),
              ViewProfileScreen(userEmail: _userEmail, userName: _firstName),
            ],
          ),
          if (_showChatBot)
            Positioned(
              left: _chatBotPosition.dx,
              top: _chatBotPosition.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _chatBotPosition += details.delta;
                  });
                },
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFFD32F2F),
                  onPressed: () {
                    talkWithChatbot(context, _userEmail, _firstName);
                  },
                  child: const Icon(Icons.chat, color: Colors.white),
                  tooltip: 'Chat with us',
                ),
              ),
            ),
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
            _buildNavItem(1, Icons.quiz, Icons.quiz_outlined, "Quiz"),
            _buildNavItem(2, Icons.star, Icons.star_outline, "Stories"),
            _buildNavItem(3, Icons.article, Icons.article_outlined, "Blog"),
            _buildNavItem(4, Icons.work, Icons.work_outline, "Jobs"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label) {
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
              fontSize: 12,
              color: isActive ? const Color(0xFFD32F2F) : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  int _getPageIndex(String routeName) {
    switch (routeName) {
      case 'home':
        return 0;
      case 'quiz':
        return 1;
      case 'success':
        return 2;
      case 'blog':
        return 3;
      case 'job':
        return 4;
      case 'feedback':
        return 5;
      case 'contact':
        return 6;
      case 'profile':
        return 7;
      default:
        return 0;
    }
  }
}
