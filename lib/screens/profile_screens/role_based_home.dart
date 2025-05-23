import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../../widgets/success_story_cards/success_stories.dart';
import '../../screens/quiz_screens/category_selection_screen.dart';
import '../../screens/blog_screen/blog_screen.dart';
import '../../screens/home_screen/home_screen.dart';
import '../../theme/vibrant_theme.dart'; // Adjust path if needed

class RoleBasedHome extends StatefulWidget {
  const RoleBasedHome({super.key});

  @override
  State<RoleBasedHome> createState() => _RoleBasedHomeState();
}

class _RoleBasedHomeState extends State<RoleBasedHome> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(); // ✅ FIXED

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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Vibrant Minds"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await Amplify.Auth.signOut();
              } catch (e) {
                safePrint("Sign out error: $e");
              }
            },
          )
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          const HomeScreen(),
          CategorySelectionScreen(name: _userName, email: _userEmail),
          const SuccessStoryPage(),
          const BlogScreen(),
          const Center(
            child: Text("Jobs Content", style: VibrantTheme.headlineText),
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
            color: isActive ? VibrantTheme.primaryColor : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? VibrantTheme.primaryColor : Colors.grey,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
