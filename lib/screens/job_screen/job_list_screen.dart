import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JobListScreen extends StatefulWidget {
  final String userEmail;

  JobListScreen({required this.userEmail});

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

      final nestedBody = jsonEncode({
        "email": widget.userEmail,
      });

      final postBody = jsonEncode({
        "body": nestedBody,
      });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Job Posts'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
            child: InkWell(
              onTap: () {
                _showJobDetails(context, job);
              },
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (job['imageUrl'] != null &&
                        job['imageUrl'].toString().isNotEmpty)
                      Container(
                          height: 150,
                          width: double.infinity,
                          child: Image.network(
                            job['imageUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Image load failed: $error');  // See logs in debug console
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image, size: 48),
                                  Text('Failed to load image'),
                                  Text(job['imageUrl'].toString(), style: TextStyle(fontSize: 10)),
                                ],
                              );
                            },
                          )

                      ),
                    SizedBox(height: 12),
                    Text(
                      job['jobTitle'] ?? 'No Title',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (job['postedAt'] != null)
                      Text(
                        _formatDate(job['postedAt']),
                        style: TextStyle(color: Colors.grey),
                      ),
                    SizedBox(height: 8),
                    Text(
                      job['companyname'] ?? 'No Company',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    SizedBox(height: 8),
                    Text(
                      job['eligibility'] ?? 'No eligibility criteria',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showJobDetails(BuildContext context, dynamic job) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(job['jobTitle'] ?? 'Job Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job['companyname'] ?? '',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "Posted: ${_formatDate(job['postedAt'])}",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(job['description'] ?? 'No description available'),
              SizedBox(height: 12),
              Text("Eligibility Criteria:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(job['eligibility'] ?? 'No eligibility criteria'),
              SizedBox(height: 16),
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
                )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
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
}