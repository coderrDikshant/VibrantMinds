import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'job_list_screen.dart'; // Assuming VibrantTheme is defined here

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
    final textTheme = Theme.of(context).textTheme;
    BorderRadiusGeometry cardBorderRadius =
        (Theme.of(context).cardTheme.shape as RoundedRectangleBorder?)
            ?.borderRadius ??
        BorderRadius.circular(16);

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
        title: FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Text(job['jobTitle'] ?? 'Shortlisted Job Details'),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            color: VibrantTheme.primaryColor,
            // begin: Alignment.topLeft,
            // end: Alignment.bottomRight,
            // ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            if (job['imageUrl'] != null &&
                job['imageUrl'].toString().isNotEmpty)
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
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
                              mainAxisAlignment: MainAxisAlignment.center,
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
            FadeInLeft(
              duration: const Duration(milliseconds: 800),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  job['jobTitle'] ?? 'Job Title Not Available',
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 26,
                    color: VibrantTheme.primaryColor,
                  ),
                ),
              ),
            ),
            FadeInLeft(
              duration: const Duration(milliseconds: 900),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  job['companyname'] ?? 'Company Not Available',
                  style: textTheme.bodyLarge?.copyWith(
                    color: VibrantTheme.secondaryTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            FadeInLeft(
              duration: const Duration(milliseconds: 1000),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            ),

            const SizedBox(height: 16),

            // Description Section
            FadeInUp(
              duration: const Duration(milliseconds: 1100),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              duration: const Duration(milliseconds: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

            // Shortlisted Candidates Section
            FadeInUp(
              duration: const Duration(milliseconds: 1300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Shortlisted Candidates",
                      style: textTheme.headlineMedium?.copyWith(
                        color: VibrantTheme.primaryColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (dummyCandidates.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'No candidates shortlisted for this job yet.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: VibrantTheme.greyTextColor,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dummyCandidates.length,
                      itemBuilder: (context, index) {
                        final candidate = dummyCandidates[index];
                        Color statusColor;
                        switch (candidate['status']) {
                          case 'Interview Scheduled':
                            statusColor = Colors.green;
                            break;
                          case 'Resume Reviewed':
                            statusColor = Colors.blue;
                            break;
                          case 'Pending Review':
                            statusColor = Colors.orange;
                            break;
                          case 'Rejected':
                            statusColor = VibrantTheme.errorColor;
                            break;
                          default:
                            statusColor = VibrantTheme.greyTextColor;
                        }

                        return FadeInUp(
                          duration: Duration(
                            milliseconds: 1400 + (index * 100),
                          ),
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: VibrantTheme.primaryColor,
                                    child: Text(
                                      candidate['name']![0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          candidate['name']!,
                                          style: textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Email: ${candidate['email']}',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: VibrantTheme.greyTextColor,
                                          ),
                                        ),
                                        Text(
                                          'Status: ${candidate['status']}',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: VibrantTheme.greyTextColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
