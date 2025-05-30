import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/vibrant_theme.dart';
import '../../screens/job_screen/job_list_screen.dart';

class BookmarkScreen extends StatefulWidget {
  final String userEmail;

  const BookmarkScreen({required this.userEmail, super.key});

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<dynamic> appliedJobs = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchAppliedJobs();
  }

  Future<void> fetchAppliedJobs() async {
    if (widget.userEmail.isEmpty) {
      setState(() {
        error = 'No email provided';
        isLoading = false;
      });
      return;
    }

    try {
      final apiUrl = Uri.parse(
        'https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/Apply/get_applied_jobs',
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
          appliedJobs = responseData['jobs'] ?? [];
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

  Future<void> withdrawApplication(String jobId, String postedAt) async {
    try {
      final url = Uri.parse(
        'https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/Apply/withdraw_application',
      );

      final innerBody = jsonEncode({
        "email": widget.userEmail,
        "id": jobId,
        "postedAt": postedAt,
      });

      final fullBody = jsonEncode({
        "body": innerBody,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: fullBody,
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['statusCode'] == 200) {
          setState(() {
            appliedJobs.removeWhere((job) => job['id'] == jobId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application withdrawn successfully!')),
          );
        } else {
          final body = jsonDecode(responseJson['body']);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${body['error'] ?? 'Unknown error'}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to withdraw application: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error withdrawing application: $e')),
      );
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
      appBar: AppBar(
        title: const Text('Applied Jobs'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF000000),
          fontFamily: 'Poppins',
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD32F2F)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error, style: const TextStyle(color: Color(0xFFD32F2F))))
          : appliedJobs.isEmpty
          ? const Center(
        child: Text(
          'No applied jobs yet!',
          style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appliedJobs.length,
        itemBuilder: (context, index) {
          final job = appliedJobs[index];
          return MouseRegion(
            onEnter: (_) => setState(() => job['hover'] = true),
            onExit: (_) => setState(() => job['hover'] = false),
            child: AnimatedScale(
              scale: job['hover'] == true ? 1.02 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Card(
                elevation: job['hover'] == true ? 12 : 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                              return const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image, size: 48),
                                  Text('Failed to load image'),
                                ],
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        job['jobTitle'] ?? 'No Title',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (job['postedAt'] != null)
                        Text(
                          _formatDate(job['postedAt']),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        job['companyname'] ?? 'No Company',
                        style: const TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              splashColor: Colors.orangeAccent.withOpacity(0.3),
                              onTap: () async {
                                await Future.delayed(const Duration(milliseconds: 100));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JobDetailsScreen(
                                      job: job,
                                      userEmail: widget.userEmail,
                                    ),
                                  ),
                                );
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD32F2F),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: const Text(
                                  'View Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFD32F2F)),
                            onPressed: () {
                              withdrawApplication(job['id'] ?? '', job['postedAt']?.toString() ?? '');
                            },
                            tooltip: 'Withdraw Application',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}