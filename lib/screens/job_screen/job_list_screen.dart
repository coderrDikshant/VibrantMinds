import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:hive/hive.dart';

import '../profile_screens/complete_profile_screen.dart';
import 'shortlisted_job_details_screen.dart';
import 'shortlisted_jobs_list_screen.dart'; // Import the new screen

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
        return false;
      }
    } catch (e) {
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
          SnackBar(content: Text('Application submitted successfully!')),
        );
      } else {
        final body = jsonDecode(responseJson['body']) as Map<String, dynamic>;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${body['error'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting application: $e')),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(job['jobTitle'] ?? 'Job Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (job['imageUrl'] != null &&
                job['imageUrl'].toString().isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  job['imageUrl'],
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            SizedBox(height: 16),
            Text(
              job['companyname'] ?? '',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              "Posted: ${_formatDate(job['postedAt'])}",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              "Description:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(job['description'] ?? 'No description available'),
            SizedBox(height: 16),
            Text(
              "Eligibility Criteria:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(job['eligibility'] ?? 'No eligibility criteria'),
            SizedBox(height: 24),
            if (job['canApply'] == true)
              Center(
                child: ElevatedButton(
                  onPressed:
                      _isApplying
                          ? null
                          : () async {
                            final email = widget.userEmail;
                            final id = job['id'] ?? '';
                            final postedAt = job['postedAt']?.toString() ?? '';

                            if (email.isEmpty ||
                                id.isEmpty ||
                                postedAt.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Missing required application data',
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
                                          CompleteProfileScreen(email: email),
                                ),
                              );
                            }
                          },
                  child:
                      _isApplying
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                          : Text('Apply Now'),
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Only for VibrantMinds students',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16), // Add some space
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.teal, // A different color for distinction
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShortlistedJobDetailsScreen(job: job),
                    ),
                  );
                },
                child: Text(
                  'View Shortlisted',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- JobListScreen ------------------------

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
        filteredJobs = jobs.where((job) {
          final company = job['companyname']?.toString().toLowerCase() ?? '';
          final title = job['jobTitle']?.toString().toLowerCase() ?? '';
          return company.contains(query) || title.contains(query);
        }).toList();
      }
    });
  }


  Future<void> loadJobsFromHiveThenFetch() async {
    // Open box if not opened
    if (!Hive.isBoxOpen('jobsBox')) {
      await Hive.openBox('jobsBox');
    }

    final jobsBox = Hive.box('jobsBox');

    // Load jobs from Hive immediately if available
    final storedJobs = jobsBox.get('jobsList');
    if (storedJobs != null && storedJobs is List) {
  setState(() {
    jobs = storedJobs.cast<dynamic>();
    filteredJobs = jobs; // Add this line
    isLoading = false;
  });
}


    // Now fetch fresh jobs from network in background
    await fetchJobsAndSave();
  }

  Future<void> fetchJobsAndSave() async {
    setState(() {
      if (jobs.isEmpty) isLoading = true;
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

        // Save fresh jobs to Hive
        final jobsBox = Hive.box('jobsBox');
        await jobsBox.put('jobsList', freshJobs);

        // Update UI only if freshJobs is different or if no jobs loaded before
       setState(() {
  jobs = freshJobs;
  filteredJobs = jobs; // Add this line
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
      // else ignore error if we have stale jobs loaded already
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Listings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.star), // Icon for shortlisted jobs
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
              ? Center(child: Text(error, style: TextStyle(color: Colors.red)))
              : jobs.isEmpty
              ? Center(child: Text('No jobs available'))
              : RefreshIndicator(
                onRefresh: fetchJobsAndSave,
              child: ListView(
  physics: const AlwaysScrollableScrollPhysics(),
  children: [
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by company or job title',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
    ...filteredJobs.map((job) {
      return Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
         child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (job['imageUrl'] != null &&
                                job['imageUrl'].toString().isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  job['imageUrl'],
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.broken_image, size: 48),
                                          Text('Failed to load image'),
                                        ],
                                      ),
                                ),
                              ),
                            SizedBox(height: 12),
                            Text(
                              job['jobTitle'] ?? 'No Title',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatDate(job['postedAt']),
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              job['companyname'] ?? 'No Company',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                            // --- NEW ADDITIONS START HERE ---
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.monetization_on,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    job['salary'] ?? 'Not disclosed',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    job['location'] ?? 'Not specified',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.work,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    job['experience'] ?? 'Not specified',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // --- NEW ADDITIONS END HERE ---
                            SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    245,
                                    57,
                                    43,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => JobDetailsScreen(
                                            job: job,
                                            userEmail: widget.userEmail,
                                          ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'View Details',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
        ),
      );
    }).toList(),
  ],
),

              ),
    );
  }
}
