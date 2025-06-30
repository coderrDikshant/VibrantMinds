import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CoursesScreen extends StatelessWidget {
  final String username;
  final String email;

  const CoursesScreen({Key? key, required this.username, required this.email})
    : super(key: key);

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }

  Widget _buildCourseDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF0F2F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Course Name: Job Assured Program (Java Track)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Duration: 5 Months (Online/Offline)',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Roboto',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fees: ₹4750/-',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Roboto',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Contact: +91 8900 132 777',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Roboto',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Email: contact@vibrantmindstech.com',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Roboto',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Website: www.vibrantmindstech.com',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Roboto',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final Uri whatsappUri = Uri.parse(
                  'https://wa.me/918755334333?text=Interested%20in%20Java%20Fullstack%20Course',
                );
                if (!await launchUrl(
                  whatsappUri,
                  mode: LaunchMode.externalApplication,
                )) {
                  // Handle error (e.g., show SnackBar)
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                elevation: 4,
              ),
              child: const Text(
                'Enquire Now via WhatsApp',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule() {
    const scheduleItems = [
      '2.00 Hours - Technical Lecture (6 Days a Week, Mon-Sat)',
      '2.00 Hours - Spoken + Softskill Lecture (3 Days a Week, Thu-Sat)',
      '1.00 Hour - Daily Group Discussion',
      '3.00 Hours - Practice',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF0F2F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Schedule',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          ...scheduleItems.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${entry.key + 1}. ${entry.value}',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  color: Colors.black87,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    const terms = [
      'By enrolling, students agree to these terms and conditions.',
      'Students must provide accurate information during registration; false information may lead to cancellation without refund.',
      'Enrollment is subject to availability and granted on a first-come, first-served basis upon payment.',
      'Tuition fees are non-refundable and non-transferable, except per the refund policy.',
      'VibrantMinds reserves the right to change course schedules, content, instructors, or materials without prior notice.',
      'Students must attend all classes and complete assignments; make-up classes may be offered at VibrantMinds\' discretion.',
      'Disruptive behavior, harassment, or cheating may lead to dismissal without refund.',
      'Course materials are VibrantMinds\' intellectual property and cannot be used commercially or shared with non-enrolled individuals.',
      'Placement opportunities depend on market conditions, student effort, and job availability.',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF0F2F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terms and Conditions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          ...terms.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${entry.key + 1}. ${entry.value}',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  color: Colors.black87,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        title: const Text(
          'Courses',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $username!',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore our Job Assured Program',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Course Details'),
            _buildCourseDetails(),
            const SizedBox(height: 30),
            _buildSectionTitle('Schedule'),
            _buildSchedule(),
            const SizedBox(height: 30),
            _buildSectionTitle('Terms and Conditions'),
            _buildTermsAndConditions(),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF0F2F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Address: VibrantMinds Technologies Pvt Ltd, 2nd Floor, Near St Mary\'s Church and Vardhman Petrol Pump, Canal Road, Mumbai-Bangalore Highway, Warje, Pune, 410058.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'For queries or admission, contact Vishal C: +91 8755334333',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Visit us: www.vibrantmindstech.com',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
