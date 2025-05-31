import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppliedJobsScreen extends StatefulWidget {
  final String userEmail;

  const AppliedJobsScreen({super.key, required this.userEmail});

  @override
  _AppliedJobsScreenState createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  List<Map<String, dynamic>> jobs = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadAppliedJobs();
  }

Future<void> loadAppliedJobs() async {
  try {
    final appliedUrl = Uri.parse(
      'https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/devlopment/view_applications',
    );

    final appliedResponse = await http.post(
      appliedUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "body": jsonEncode({
          "email": widget.userEmail,
        })
      }),
    );

    if (appliedResponse.statusCode != 200) {
      throw Exception('Failed to fetch applied job IDs');
    }

    final appliedDataRaw = jsonDecode(appliedResponse.body);
    final appliedData = appliedDataRaw['body'] != null
        ? jsonDecode(appliedDataRaw['body'])
        : appliedDataRaw;

    final companiesApplied = appliedData['companiesApplied'];

    // If null or empty, set empty list and stop loading
    if (companiesApplied == null || companiesApplied.isEmpty) {
      setState(() {
        jobs = [];
        isLoading = false;
      });
      return;
    }
      final jobIds = companiesApplied
          .map((item) => item['jobId']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .toList();

      if (jobIds.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final detailsUrl = Uri.parse(
        'https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/job_type/job_type',
      );

      final nestedBody = jsonEncode({"email": widget.userEmail});
      final detailsResponse = await http.post(
        detailsUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"body": nestedBody}),
      );

      if (detailsResponse.statusCode != 200) {
        throw Exception('Failed to fetch job details');
      }

      dynamic detailsData = jsonDecode(detailsResponse.body);
      if (detailsData is String) detailsData = jsonDecode(detailsData);
      if (detailsData['body'] != null) detailsData = jsonDecode(detailsData['body']);
      if (detailsData['error'] != null) throw Exception(detailsData['error']);

      final allJobs = (detailsData['jobs'] as List<dynamic>).cast<Map<String, dynamic>>();

      final matchedJobs = allJobs.where((job) => jobIds.contains(job['id'])).toList();

      for (var job in matchedJobs) {
        job['hover'] = false;
      }

      setState(() {
        jobs = matchedJobs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error occurred: $e';
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applied Jobs'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error, style: const TextStyle(color: Colors.red)))
              : jobs.isEmpty
                  ? const Center(child: Text('No jobs found.'))
                  : ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
  final job = jobs[index];
  return MouseRegion(
    onEnter: (_) => setState(() => jobs[index]['hover'] = true),
    onExit: (_) => setState(() => jobs[index]['hover'] = false),
    child: AnimatedScale(
      scale: job['hover'] == true ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: job['hover'] == true ? 12 : 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            // "Applied" label top-left
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                
                child: const Text(
                  
                  'Applied',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Main content with some padding so it doesn't overlap "Applied"
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['jobTitle']?.toString() ?? 'No Title',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['companyname']?.toString() ?? 'No Company',
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
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
}
