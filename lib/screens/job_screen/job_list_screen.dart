import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// New JobDetailsScreen widget
class JobDetailsScreen extends StatelessWidget {
  final dynamic job;
  final String userEmail;
  

  const JobDetailsScreen({required this.job,required this.userEmail});

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
  final url = Uri.parse('https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/Apply/apply_action');

  final innerBody = jsonEncode({
    "email": email,
    "id": id,
    "postedAt": postedAt,
  });

  final fullBody = jsonEncode({
    "body": innerBody
  });

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: fullBody,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['statusCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application submitted successfully!')),
        );
      } else {
        final body = jsonDecode(responseJson['body']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${body['error'] ?? 'Unknown error'}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit application: ${response.statusCode}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error submitting application: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
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
              ),
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
  onPressed: () {
    final email = userEmail; 
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
  child: Text('Apply Now'),
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
    textStyle: TextStyle(fontSize: 16),
  ),
),

              ),
          ],
        ),
      ),
    );
  }
}

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
void didChangeDependencies() {
  super.didChangeDependencies();
  for (var job in jobs) {
    job['hover'] = false;
  }
}

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
              ? Center(child: Text(error, style: TextStyle(color: const Color.fromARGB(255, 245, 57, 43))))
              : jobs.isEmpty
                  ? Center(child: Text('No jobs available'))
                  : ListView.builder(
  itemCount: jobs.length,
  itemBuilder: (context, index) {
    final job = jobs[index];
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 1),
      duration: Duration(milliseconds: 200),
      builder: (context, scale, child) {
        return MouseRegion(
          onEnter: (_) => setState(() => jobs[index]['hover'] = true),
          onExit: (_) => setState(() => jobs[index]['hover'] = false),
          child: AnimatedScale(
            scale: job['hover'] == true ? 1.02 : 1.0,
            duration: Duration(milliseconds: 200),
            child: Card(
              elevation: job['hover'] == true ? 12 : 4,
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
                    SizedBox(height: 12),
                    Align(
  alignment: Alignment.centerRight,
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      splashColor: Colors.orangeAccent.withOpacity(0.3), // Visible ripple
      onTap: () async {
        await Future.delayed(Duration(milliseconds: 100)); // Delay for ripple effect
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(job: job,userEmail: widget.userEmail),
          ),
        );
      },
      child: Ink(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 57, 43), // Orange button
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          'View Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  ),
),

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  },
)
,
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