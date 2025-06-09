import 'package:flutter/material.dart';

class ShortlistedJobDetailsScreen extends StatelessWidget {
  final dynamic job;

  const ShortlistedJobDetailsScreen({Key? key, required this.job})
    : super(key: key);

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
    // Dummy shortlisted candidates for demonstration
    final List<Map<String, String>> dummyCandidates = [
      {
        'name': 'Alice Smith',
        'email': 'alice.s@example.com',
        'status': 'Interview Scheduled',
      },
      {
        'name': 'Bob Johnson',
        'email': 'bob.j@example.com',
        'status': 'Resume Reviewed',
      },
      {
        'name': 'Charlie Brown',
        'email': 'charlie.b@example.com',
        'status': 'Pending Review',
      },
      {
        'name': 'Diana Prince',
        'email': 'diana.p@example.com',
        'status': 'Rejected',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(job['jobTitle'] ?? 'Shortlisted Job Details'),
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
                            SizedBox(
                              height: 8,
                            ), // Add spacing between icon and text
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.grey),
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
            Text(
              "Shortlisted Candidates:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            // Display dummy candidates
            if (dummyCandidates.isEmpty)
              Text('No candidates shortlisted for this job yet.')
            else
              ListView.builder(
                shrinkWrap: true, // Important for nested ListViews
                physics:
                    NeverScrollableScrollPhysics(), // Important for nested ListViews
                itemCount: dummyCandidates.length,
                itemBuilder: (context, index) {
                  final candidate = dummyCandidates[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            candidate['name']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('Email: ${candidate['email']}'),
                          Text('Status: ${candidate['status']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
