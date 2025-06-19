// 🛠 Your imports
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:hive/hive.dart';
import '../../screens/quiz_screens/category_selection_screen.dart';
import '../../screens/job_screen/job_list_screen.dart';

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
  final isFresh = lastFetched != null &&
      now.difference(DateTime.parse(lastFetched)).inHours < 6;

  if (storedJobs != null && storedJobs is List && isFresh) {
    // Use cached jobs
    setState(() {
      jobs = storedJobs.cast<dynamic>();
    });
  } else {
    // Fetch fresh jobs and update cache
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

  // ✅ Job Slider with "Featured Jobs" heading
Widget _buildJobSlider() {
  if (isLoadingJobs) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  if (error.isNotEmpty) {
    return Center(child: Text(error, style: const TextStyle(color: Colors.red)));
  }

  if (jobs.isEmpty) {
    return const Center(child: Text('No jobs available'));
  }

  final random = Random();
  final jobCount = jobs.length < 5 ? jobs.length : (3 + random.nextInt(3)); // 3 to 5 jobs
  final randomJobs = (jobs..shuffle(random)).take(jobCount).toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
        child: Text(
          'Featured Jobs',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      SizedBox(
        height: 260, // Entire card height including image + text
        child: PageView.builder(
          itemCount: randomJobs.length,
          controller: PageController(viewportFraction: 0.85),
          itemBuilder: (context, index) {
            final job = randomJobs[index];
            final imageUrl = job['imageUrl'] ?? '';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JobDetailsScreen(
                      job: job,
                      userEmail: widget.email,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          imageUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
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
                                const Icon(Icons.monetization_on, size: 14, color: Colors.grey),
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
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
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
                                const Icon(Icons.work, size: 14, color: Colors.grey),
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
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
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
    ],
  );
}



  Widget _buildSection(String title, String route) {
    final bool isFeatureSection = title == 'App Features';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF9F9F9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFeatureSection ? featuresDescription : description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                  fontFamily: 'Roboto',
                ),
              ),
              if (isFeatureSection)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    onPressed: () {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Take a Random Quiz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Roboto',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${widget.username}!',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const Text(
              'Welcome to VibrantMinds Technologies!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Lottie.asset(
                'assets/animations/quiz_animation.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'Failed to load animation',
                    style: TextStyle(color: Colors.redAccent),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildJobSlider(),
            const SizedBox(height: 32),
            _buildSection('App Features', 'Features'),
            _buildSection('Let\'s Innovate!', 'Innovate'),
            _buildSection('Explore Technology', 'Technology'),
            _buildSection('Stay Inspired', 'Inspiration'),
          ],
        ),
      ),
    );
  }
}