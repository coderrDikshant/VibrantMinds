import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:hive/hive.dart';

import 'shortlisted_job_details_screen.dart'; // Import the details screen

class ShortlistedJobsListScreen extends StatefulWidget {
  const ShortlistedJobsListScreen({Key? key}) : super(key: key);

  @override
  _ShortlistedJobsListScreenState createState() =>
      _ShortlistedJobsListScreenState();
}

class _ShortlistedJobsListScreenState extends State<ShortlistedJobsListScreen> {
  List<dynamic> _shortlistedJobs = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchShortlistedJobs();
  }

  Future<void> _fetchShortlistedJobs() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      if (!Hive.isBoxOpen('jobsBox')) {
        await Hive.openBox('jobsBox');
      }
      final jobsBox = Hive.box('jobsBox');
      final allJobs = jobsBox.get('jobsList');

      if (allJobs != null && allJobs is List) {
        // --- CHANGE STARTS HERE ---
        setState(() {
          _shortlistedJobs =
              allJobs
                  .cast<
                    dynamic
                  >(); // Cast to dynamic if needed, or specify the type if known
          _isLoading = false;
        });
        // --- CHANGE ENDS HERE ---
      } else {
        setState(() {
          _error = 'No jobs found in cache.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading shortlisted jobs: ${e.toString()}';
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shortlisted Candidates'), centerTitle: true),
      body:
          _isLoading
              ? Center(
                child: Lottie.asset(
                  'assets/animations/loading_animation.json',
                  width: 200,
                  height: 200,
                ),
              )
              : _error.isNotEmpty
              ? Center(child: Text(_error, style: TextStyle(color: Colors.red)))
              : _shortlistedJobs.isEmpty
              ? Center(child: Text('No shortlisted jobs available.'))
              : RefreshIndicator(
                onRefresh: _fetchShortlistedJobs,
                child: ListView.builder(
                  itemCount: _shortlistedJobs.length,
                  itemBuilder: (context, index) {
                    final job = _shortlistedJobs[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                            SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ShortlistedJobDetailsScreen(
                                            job: job,
                                          ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'View Details & Candidates',
                                  style: TextStyle(color: Colors.white),
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
    );
  }
}
