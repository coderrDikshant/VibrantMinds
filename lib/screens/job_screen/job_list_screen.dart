import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:hive/hive.dart';
import 'package:animate_do/animate_do.dart'; // Added for animations

import '../profile_screens/complete_profile_screen.dart';
import 'shortlisted_job_details_screen.dart';
import 'shortlisted_jobs_list_screen.dart';

// VibrantTheme class remains unchanged
class VibrantTheme {
  static const Color primaryColor = Color(0xFFD32F2F);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Colors.redAccent;
  static const Color textColor = Color(0xFF000000);
  static const Color secondaryTextColor = Colors.black87;
  static const Color greyTextColor = Colors.grey;

  static ThemeData get themeData => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        color: secondaryTextColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        color: secondaryTextColor,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        color: greyTextColor,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ), // Updated margin
      surfaceTintColor: surfaceColor,
      color: surfaceColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      hintStyle: TextStyle(color: Colors.grey[600]),
    ),
  );
}

class JobDetailsScreen extends StatefulWidget {
  final dynamic job;
  final String userEmail;

  const JobDetailsScreen({required this.job, required this.userEmail});

  @override
  _JobDetailsScreenState createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isApplying = false;

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

  Future<bool> checkUserProfileComplete(String email) async {
    final wrappedPayload = {
      "httpMethod": "POST",
      "body": {"email": email, "action": "complete_profile"},
    };

    try {
      final response = await http.post(
        Uri.parse(
          'https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/User_exist/User_profile_exist',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(wrappedPayload),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final body = jsonDecode(decoded['body']) as Map<String, dynamic>;
        return body['profileComplete'] == true;
      } else {
        print('Profile check failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error checking profile completion: $e');
      return false;
    }
  }

  Future<void> submitApplication(
    BuildContext context,
    String email,
    String id,
    String postedAt,
  ) async {
    setState(() {
      _isApplying = true;
    });

    final url = Uri.parse(
      'https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/Apply/apply_action',
    );

    final bodyPayload = {"email": email, "id": id, "postedAt": postedAt};

    final fullBody = jsonEncode({
      "httpMethod": "POST",
      "body": jsonEncode(bodyPayload),
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: fullBody,
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseJson['statusCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        final body = jsonDecode(responseJson['body']) as Map<String, dynamic>;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${body['error'] ?? 'Unknown error'}'),
            backgroundColor: VibrantTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting application: $e'),
          backgroundColor: VibrantTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isApplying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final textTheme = Theme.of(context).textTheme;

    BorderRadiusGeometry cardBorderRadius =
        (Theme.of(context).cardTheme.shape as RoundedRectangleBorder?)
            ?.borderRadius ??
        BorderRadius.circular(8);

    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          child: Text(
            job['jobTitle'] ?? 'Job Details',
            style: TextStyle(color: VibrantTheme.backgroundColor),
          ),
        ),
        backgroundColor: VibrantTheme.primaryColor,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            if (job['imageUrl'] != null &&
                job['imageUrl'].toString().isNotEmpty)
              FadeInUp(
                duration: Duration(milliseconds: 600),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: cardBorderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: cardBorderRadius,
                    child: Image.network(
                      job['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              // mainAxisAlignment: MainAxisAlignment around,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: VibrantTheme.greyTextColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Failed to load image',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: VibrantTheme.greyTextColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                    ),
                  ),
                ),
              ),

            // Job Title and Company
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInLeft(
                    duration: Duration(milliseconds: 800),
                    child: Text(
                      job['jobTitle'] ?? 'Job Title Not Available',
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 26,
                        color: VibrantTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FadeInLeft(
                    duration: Duration(milliseconds: 900),
                    child: Text(
                      job['companyname'] ?? 'Company Not Available',
                      style: textTheme.bodyLarge?.copyWith(
                        color: VibrantTheme.secondaryTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInLeft(
                    duration: Duration(milliseconds: 1000),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: VibrantTheme.greyTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Posted: ${_formatDate(job['postedAt'])}",
                          style: textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Job Details Card
            FadeInUp(
              duration: Duration(milliseconds: 1100),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        context,
                        icon: Icons.monetization_on,
                        title: "Salary",
                        value: job['salary'] ?? 'Not disclosed',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        icon: Icons.location_on,
                        title: "Location",
                        value: job['location'] ?? 'Not specified',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        icon: Icons.work,
                        title: "Experience",
                        value: job['experience'] ?? 'Not specified',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Description Section
            FadeInUp(
              duration: Duration(milliseconds: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Description",
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: VibrantTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: VibrantTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        job['description'] ?? 'No description available',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Eligibility Section
            FadeInUp(
              duration: Duration(milliseconds: 1300),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Eligibility Criteria",
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: VibrantTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: VibrantTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        job['eligibility'] ?? 'No eligibility criteria',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            FadeInUp(
              duration: Duration(milliseconds: 1400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (job['canApply'] == true)
                      Expanded(
                        child: ZoomIn(
                          child: ElevatedButton(
                            onPressed:
                                _isApplying
                                    ? null
                                    : () async {
                                      final email = widget.userEmail;
                                      final id = job['id'] ?? '';
                                      final postedAt =
                                          job['postedAt']?.toString() ?? '';

                                      if (email.isEmpty ||
                                          id.isEmpty ||
                                          postedAt.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Missing required application data',
                                            ),
                                            backgroundColor:
                                                VibrantTheme.errorColor,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      bool completeProfile =
                                          await checkUserProfileComplete(email);

                                      if (completeProfile) {
                                        await submitApplication(
                                          context,
                                          email,
                                          id,
                                          postedAt,
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    CompleteProfileScreen(
                                                      email: email,
                                                    ),
                                          ),
                                        );
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: VibrantTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 5,
                            ),
                            child:
                                _isApplying
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                    : const Text(
                                      'Apply Now',
                                      style: TextStyle(fontSize: 16),
                                    ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Text(
                          'Only for VibrantMinds students',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: VibrantTheme.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ZoomIn(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ShortlistedJobDetailsScreen(job: job),
                              ),
                            );
                          },
                          child: const Text(
                            'View Shortlisted',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: VibrantTheme.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class JobListScreen extends StatefulWidget {
  final String userEmail;

  const JobListScreen({required this.userEmail});

  @override
  _JobListScreenState createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  List<dynamic> jobs = [];
  List<dynamic> filteredJobs = [];
  bool isLoading = true;
  String error = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterJobs);
    loadJobsFromHiveThenFetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterJobs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredJobs = List.from(jobs);
      } else {
        filteredJobs =
            jobs.where((job) {
              final company =
                  job['companyname']?.toString().toLowerCase() ?? '';
              final title = job['jobTitle']?.toString().toLowerCase() ?? '';
              return company.contains(query) || title.contains(query);
            }).toList();
      }
    });
  }

  Future<void> loadJobsFromHiveThenFetch() async {
    if (!Hive.isBoxOpen('jobsBox')) {
      await Hive.openBox('jobsBox');
    }

    final jobsBox = Hive.box('jobsBox');
    final storedJobs = jobsBox.get('jobsList');
    if (storedJobs != null && storedJobs is List) {
      setState(() {
        jobs = storedJobs.cast<dynamic>();
        filteredJobs = jobs;
        isLoading = false;
      });
    }

    await fetchJobsAndSave();
  }

  Future<void> fetchJobsAndSave() async {
    setState(() {
      if (jobs.isEmpty) isLoading = true;
      error = '';
    });

    if (!Hive.isBoxOpen('profileBox')) {
      await Hive.openBox('profileBox');
    }

    final bool isCourseEnrolled = Hive.box(
      'profileBox',
    ).get('isCourseEnrolled', defaultValue: false);

    try {
      final apiUrl = Uri.parse(
        'https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/job_type/job_type',
      );

      final nestedBody = jsonEncode({
        "email": widget.userEmail,
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

        dynamic responseData;
        if (decoded['body'] is String) {
          responseData = jsonDecode(decoded['body']) as Map<String, dynamic>;
        } else {
          responseData = decoded['body'];
        }

        if (responseData['error'] != null) {
          throw Exception(responseData['error']);
        }

        final freshJobs = responseData['jobs'] ?? [];
        final jobsBox = Hive.box('jobsBox');
        await jobsBox.put('jobsList', freshJobs);

        setState(() {
          jobs = freshJobs;
          filteredJobs = jobs;
          isLoading = false;
          error = '';
        });
      } else {
        throw Exception(
          'API request failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (jobs.isEmpty) {
        setState(() {
          error = 'Error: ${e.toString()}';
          isLoading = false;
        });
      }
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

  // Future<void> _addToShortlisted(dynamic job) async {
  //   if (!Hive.isBoxOpen('shortlistedJobsBox')) {
  //     await Hive.openBox('shortlistedJobsBox');
  //   }
  //   final shortlistedBox = Hive.box('shortlistedJobsBox');
  //   List<dynamic> currentShortlisted =
  //       shortlistedBox
  //           .get('shortlistedList', defaultValue: [])
  //           ?.cast<dynamic>() ??
  //       [];
  //
  //   bool alreadyShortlisted = currentShortlisted.any(
  //     (item) => item['id'] == job['id'],
  //   );
  //
  //   if (!alreadyShortlisted) {
  //     currentShortlisted.add(job);
  //     await shortlistedBox.put('shortlistedList', currentShortlisted);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('${job['jobTitle']} added to shortlisted!'),
  //         backgroundColor: Colors.green,
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //       ),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('${job['jobTitle']} is already shortlisted.'),
  //         backgroundColor: Colors.orange,
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    BorderRadiusGeometry cardBorderRadius =
        (Theme.of(context).cardTheme.shape as RoundedRectangleBorder?)
            ?.borderRadius ??
        BorderRadius.circular(8);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShortlistedJobsListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: Lottie.asset(
                  'assets/animations/loading_animation.json',
                  width: 200,
                  height: 200,
                ),
              )
              : error.isNotEmpty
              ? Center(
                child: Text(
                  error,
                  style: textTheme.bodyLarge?.copyWith(
                    color: VibrantTheme.errorColor,
                  ),
                ),
              )
              : jobs.isEmpty
              ? Center(
                child: Text('No jobs available', style: textTheme.bodyLarge),
              )
              : RefreshIndicator(
                onRefresh: fetchJobsAndSave,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by company or job title',
                          prefixIcon: Icon(
                            Icons.search,
                            color: VibrantTheme.greyTextColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredJobs.length,
                        itemBuilder: (context, index) {
                          final job = filteredJobs[index];
                          return FadeInUp(
                            duration: Duration(
                              milliseconds: 300 + (index * 100),
                            ),
                            child: Card(
                              margin: Theme.of(context).cardTheme.margin,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (job['imageUrl'] != null &&
                                        job['imageUrl'].toString().isNotEmpty)
                                      ClipRRect(
                                        borderRadius: cardBorderRadius.resolve(
                                          Directionality.of(context),
                                        ),
                                        child: Image.network(
                                          job['imageUrl'],
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (
                                                context,
                                                error,
                                                stackTrace,
                                              ) => Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.broken_image,
                                                    size: 48,
                                                    color:
                                                        VibrantTheme
                                                            .greyTextColor,
                                                  ),
                                                  Text(
                                                    'Failed to load image',
                                                    style:
                                                        textTheme.labelMedium,
                                                  ),
                                                ],
                                              ),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    Text(
                                      job['jobTitle'] ?? 'No Title',
                                      style: textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      job['companyname'] ?? 'No Company',
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: VibrantTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                          color: VibrantTheme.greyTextColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            _formatDate(job['postedAt']),
                                            style: textTheme.labelMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.monetization_on,
                                          size: 18,
                                          color: VibrantTheme.greyTextColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            job['salary'] ?? 'Not disclosed',
                                            style: textTheme.bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 18,
                                          color: VibrantTheme.greyTextColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            job['location'] ?? 'Not specified',
                                            style: textTheme.bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.work,
                                          size: 18,
                                          color: VibrantTheme.greyTextColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            job['experience'] ??
                                                'Not specified',
                                            style: textTheme.bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) => JobDetailsScreen(
                                                        job: job,
                                                        userEmail:
                                                            widget.userEmail,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: const Text('View Details'),
                                          ),
                                        ),
                                        // const SizedBox(width: 8),
                                        // IconButton(
                                        //   icon: Icon(
                                        //     Icons.star_border,
                                        //     color: VibrantTheme.primaryColor,
                                        //   ),
                                        //   onPressed:
                                        //       () => _addToShortlisted(job),
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
