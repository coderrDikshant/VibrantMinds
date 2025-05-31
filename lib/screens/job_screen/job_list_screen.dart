import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

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
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp.toString()));
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> submitApplication(BuildContext context, String email, String id, String postedAt) async {
    setState(() {
      _isApplying = true;
    });

    final url = Uri.parse('https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/Apply/apply_action');

    final innerBody = jsonEncode({
      "email": email,
      "id": id,
      "postedAt": postedAt,
    });

    final fullBody = jsonEncode({"body": innerBody});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: fullBody,
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200 && responseJson['statusCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application submitted successfully!')),
        );
      } else {
        final body = jsonDecode(responseJson['body']);
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
            if (job['imageUrl'] != null && job['imageUrl'].toString().isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: Image.network(
                  job['imageUrl'],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image, size: 48),
                          Text('Failed to load image'),
                        ],
                      ),
                    );
                  },
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
            Text("Description:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(job['description'] ?? 'No description available'),
            SizedBox(height: 16),
            Text("Eligibility Criteria:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(job['eligibility'] ?? 'No eligibility criteria'),
            SizedBox(height: 24),
            if (job['canApply'] == true)
              Center(
                child: ElevatedButton(
                  onPressed: _isApplying
                      ? null
                      : () {
                          final email = widget.userEmail;
                          final id = job['id'] ?? '';
                          final postedAt = job['postedAt']?.toString() ?? '';

                          if (email.isEmpty || id.isEmpty || postedAt.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Missing required application data')),
                            );
                            return;
                          }

                          submitApplication(context, email, id, postedAt);
                        },
                  child: _isApplying
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
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
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
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
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    if (widget.userEmail.isEmpty) {
      setState(() {
        error = 'No email provided';
        isLoading = false;
      });
      return;
    }

    try {
      final apiUrl = Uri.parse(
        'https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/job_type/job_type',
      );

      final nestedBody = jsonEncode({"email": widget.userEmail});
      final postBody = jsonEncode({"body": nestedBody});

      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: postBody,
      );

      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);

        if (responseData is String) {
          responseData = jsonDecode(responseData);
        } else if (responseData['body'] != null) {
          responseData = jsonDecode(responseData['body']);
        }

        if (responseData['error'] != null) {
          throw Exception(responseData['error']);
        }

        setState(() {
          jobs = responseData['jobs'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('API request failed with status ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Date not available';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp.toString()));
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
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
                  : ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (job['imageUrl'] != null && job['imageUrl'].toString().isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      job['imageUrl'],
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.broken_image, size: 48),
                                            Text('Failed to load image'),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                SizedBox(height: 12),
                                Text(
                                  job['jobTitle'] ?? 'No Title',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _formatDate(job['postedAt']),
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  job['companyname'] ?? 'No Company',
                                  style: TextStyle(fontSize: 16, color: Colors.blue),
                                ),
                                SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromARGB(255, 245, 57, 43),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => JobDetailsScreen(
                                            job: job,
                                            userEmail: widget.userEmail,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text('View Details', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
