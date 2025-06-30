import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:hive/hive.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../screens/quiz_screens/category_selection_screen.dart';
import '../../screens/job_screen/job_list_screen.dart';
import '../../widgets/success_story_cards/success_stories.dart'; // Updated import
import '../../screens/blog_screen/blog_screen.dart';
import '../../screens/courses_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(BuildContext, String) navigateTo;
  final String username;
  final String email;

  const HomeScreen({
    Key? key,
    required this.navigateTo,
    required this.username,
    required this.email,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String description =
      'Discover a world of innovation, learning, and growth with Vibrant Minds Technologies. Empower your future with cutting-edge quizzes, inspiring success stories, and insightful blogs. Join our tech-driven community and start your journey today!';

  static const String featuresDescription =
      'With Vibrant Minds Technologies, you can:\n- Test your knowledge with fun and challenging random quizzes.\n- Dive into insightful blogs to stay updated on tech trends.\n- Get inspired by real success stories from our community.';

  List<dynamic> jobs = [];
  bool isLoadingJobs = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadJobsFromHiveThenFetch();
  }

  Future<void> loadJobsFromHiveThenFetch() async {
    if (!Hive.isBoxOpen('jobsBox')) {
      await Hive.openBox('jobsBox');
    }

    final jobsBox = Hive.box('jobsBox');
    final storedJobs = jobsBox.get('jobsList');
    final lastFetched = jobsBox.get('lastFetched');

    final now = DateTime.now();
    final isFresh =
        lastFetched != null &&
        now.difference(DateTime.parse(lastFetched)).inHours < 6;

    if (storedJobs != null && storedJobs is List && isFresh) {
      setState(() {
        jobs = storedJobs.cast<dynamic>();
      });
    } else {
      await fetchJobsAndSave();
    }
  }

  Future<void> fetchJobsAndSave() async {
    setState(() {
      isLoadingJobs = true;
      error = '';
    });

    final bool isCourseEnrolled = Hive.box(
      'profileBox',
    ).get('isCourseEnrolled', defaultValue: false);

    try {
      final apiUrl = Uri.parse(
        'https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/job_type/job_type',
      );
      final nestedBody = jsonEncode({
        "email": widget.email,
        "courseEnroll": isCourseEnrolled,
      });
      final postBody = jsonEncode({"body": nestedBody});

      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: postBody,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        dynamic responseData =
            decoded['body'] is String
                ? jsonDecode(decoded['body'])
                : decoded['body'];

        if (responseData['error'] != null)
          throw Exception(responseData['error']);

        final freshJobs = responseData['jobs'] ?? [];
        final jobsBox = Hive.box('jobsBox');

        await jobsBox.put('jobsList', freshJobs);
        await jobsBox.put('lastFetched', DateTime.now().toIso8601String());

        setState(() {
          jobs = freshJobs;
          isLoadingJobs = false;
          error = '';
        });
      } else {
        throw Exception(
          'API request failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        error = 'Error: ${e.toString()}';
        isLoadingJobs = false;
      });
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Date not available';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(
        int.parse(timestamp.toString()),
      );
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }

  Widget _buildJobSlider() {
    if (isLoadingJobs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return Center(
        child: Text(error, style: const TextStyle(color: Colors.red)),
      );
    }

    if (jobs.isEmpty) {
      return const Center(child: Text('No jobs available'));
    }

    final random = Random();
    final jobCount = jobs.length < 5 ? jobs.length : (3 + random.nextInt(3));
    final randomJobs = (jobs..shuffle(random)).take(jobCount).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Featured Jobs'),
          SizedBox(
            height: 260,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              itemCount: randomJobs.length,
              itemBuilder: (context, index) {
                final job = randomJobs[index];
                final imageUrl = job['imageUrl'] ?? '';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => JobDetailsScreen(
                              job: job,
                              userEmail: widget.email,
                            ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        if (imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              imageUrl,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job['jobTitle'] ?? 'No Title',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  job['companyname'] ?? 'Unknown Company',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueAccent,
                                    fontFamily: 'Roboto',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.monetization_on,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        job['salary'] ?? 'Not disclosed',
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        job['location'] ?? 'N/A',
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.work,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        job['experience'] ?? 'N/A',
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    'Posted: ${_formatDate(job['postedAt'])}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0, bottom: 4.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => JobListScreen(userEmail: widget.email),
                    ),
                  );
                },
                child: const Text(
                  'View All Jobs →',
                  style: TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    String descriptionText,
    bool isButtonVisible, {
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF0F2F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                descriptionText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.6,
                  fontFamily: 'Roboto',
                ),
              ),
              if (isButtonVisible)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        buttonText ?? 'Learn More',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTiles() {
    final tiles = [
      {
        'title': 'Quiz',
        'icon': Icons.quiz,
        'color': Colors.blueAccent,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CategorySelectionScreen(
                    name: widget.username,
                    email: widget.email,
                  ),
            ),
          );
        },
      },
      {
        'title': 'Success Story',
        'icon': Icons.star,
        'color': Colors.orangeAccent,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SuccessStoryPage(
                    userEmail: widget.email,
                    userName: widget.username,
                  ),
            ),
          );
        },
      },
      {
        'title': 'Blogs',
        'icon': Icons.article,
        'color': Colors.green,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BlogScreen(
                    userEmail: widget.email,
                    userName: widget.username,
                  ),
            ),
          );
        },
      },
      {
        'title': 'Jobs',
        'icon': Icons.work,
        'color': Colors.purple,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobListScreen(userEmail: widget.email),
            ),
          );
        },
      },
      {
        'title': 'Courses',
        'icon': Icons.school,
        'color': Colors.redAccent,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CoursesScreen(
                    username: widget.username,
                    email: widget.email,
                  ),
            ),
          );
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Explore Services'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: List.generate(3, (index) {
            final tile = tiles[index];
            return GestureDetector(
              onTap: tile['onTap'] as VoidCallback,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tile['icon'] as IconData,
                      size: 40,
                      color: tile['color'] as Color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tile['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: List.generate(2, (index) {
            final tile = tiles[index + 3];
            return GestureDetector(
              onTap: tile['onTap'] as VoidCallback,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tile['icon'] as IconData,
                      size: 40,
                      color: tile['color'] as Color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tile['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSocialLinksSection() {
    final socialLinks = [
      {
        'title': 'Facebook',
        'icon': Icons.facebook,
        'color': Colors.blue,
        'url': 'https://www.facebook.com/VibrantMindsTech/',
      },
      {
        'title': 'Instagram',
        'icon': FontAwesomeIcons.instagram,
        'color': Colors.pink,
        'url': 'https://www.instagram.com/vibrantminds_technologies/',
      },
      {
        'title': 'Telegram',
        'icon': Icons.telegram,
        'color': Colors.blueAccent,
        'url': 'https://telegram.me/VibrantMinds',
      },
      {
        'title': 'WhatsApp Group',
        'icon': FontAwesomeIcons.whatsapp,
        'color': Colors.green,
        'url': 'https://chat.whatsapp.com/6Mp34ujaaJ22YOcFmlfll4',
      },
      {
        'title': 'Email',
        'icon': Icons.mail_outline,
        'color': Colors.deepOrange,
        'url': 'mailto:Vmttalent@gmail.com',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Connect with Us'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF0F2F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children:
                socialLinks.map((link) {
                  return ListTile(
                    leading: Icon(
                      link['icon'] as IconData,
                      color: link['color'] as Color,
                      size: 24,
                    ),
                    title: Text(
                      link['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    onTap: () async {
                      final Uri uri = Uri.parse(link['url'] as String);
                      if (!await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      )) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not launch URL')),
                        );
                      }
                    },
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${widget.username}!',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome back to Vibrant Minds!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 30),
            _buildServiceTiles(),
            const SizedBox(height: 30),
            _buildJobSlider(),
            const SizedBox(height: 40),
            _buildSection(
              'App Features',
              featuresDescription,
              true,
              buttonText: 'Take a Random Quiz',
              onButtonPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CategorySelectionScreen(
                          name: widget.username,
                          email: widget.email,
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            _buildSection('Let\'s Innovate!', description, false),
            const SizedBox(height: 40),
            _buildSection('Explore Technology', description, false),
            const SizedBox(height: 40),
            _buildSection('Stay Inspired', description, false),
            const SizedBox(height: 40),
            _buildSocialLinksSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
