import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' hide PdfDocument;
import 'dart:convert';
import 'profile_screens/complete_profile_screen.dart';

class ViewProfileScreen extends StatefulWidget {
  final String userEmail;
  final String userName;

  const ViewProfileScreen({
    super.key,
    required this.userEmail,
    required this.userName,
  });
 
  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Profile? _profile;
  int? _expandedSectionIndex;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/User_exist/User_profile_exist',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "httpMethod": "GET",
          "queryStringParameters": {"email": widget.userEmail},
        }),
      );

      print('Response Status: ${response.statusCode}');
      print('Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final body = jsonDecode(responseBody['body']);

        print('Decoded Body: $body');

        final profileComplete =
            body['profileComplete'] == true ||
            body['profileComplete'] == 'true';
        final profileData = body['profile'];

        if (!profileComplete ||
            profileData == null ||
            profileData is! Map<String, dynamic>) {
          print('Profile incomplete or missing. Redirecting...');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CompleteProfileScreen(email: widget.userEmail),
            ),
          );
          return;
        }

        final profile = Profile.fromJson(profileData);

        setState(() {
          _profile = profile;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        throw Exception(
          'Failed to load profile. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      setState(() {
        _errorMessage = 'Error loading profile: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFD32F2F),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFD32F2F)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(value.isNotEmpty ? value : '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFD32F2F),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _profile == null
              ? const Center(child: Text('No profile data available.'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFD32F2F),
                        child: Text(
                          _profile!.personalInfo.firstName.isNotEmpty
                              ? _profile!.personalInfo.firstName[0]
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ExpansionTile(
   key: PageStorageKey('personal_info'), // <- ensure unique keys
  initiallyExpanded: _expandedSectionIndex == 0,
  onExpansionChanged: (expanded) {
    setState(() {
      _expandedSectionIndex = expanded ? 0 : null;
    });
  },
  title: _buildSectionTitle('Personal Info'),
  children: [
    _buildProfileItem(
      icon: Icons.person,
      label: 'Name',
      value: '${_profile!.personalInfo.firstName} ${_profile!.personalInfo.lastName}',
    ),
    _buildProfileItem(
      icon: Icons.email,
      label: 'Email',
      value: _profile!.personalInfo.email,
    ),
    _buildProfileItem(
      icon: Icons.phone,
      label: 'Phone',
      value: _profile!.personalInfo.phone,
    ),
    _buildProfileItem(
      icon: Icons.calendar_today,
      label: 'Date of Birth',
      value: _profile!.personalInfo.dob,
    ),
    _buildProfileItem(
      icon: Icons.location_city,
      label: 'Hometown City',
      value: _profile!.personalInfo.hometownCity,
    ),
    _buildProfileItem(
      icon: Icons.location_on,
      label: 'Hometown State',
      value: _profile!.personalInfo.hometownState,
    ),
    _buildProfileItem(
      icon: Icons.location_on,
      label: 'Current State',
      value: _profile!.personalInfo.currentState,
    ),
    _buildProfileItem(
      icon: Icons.location_on,
      label: 'Current Location',
      value: _profile!.personalInfo.currentLocation,
    ),
  ],
),
const SizedBox(height: 8),

ExpansionTile(
   key: PageStorageKey('education'),
  initiallyExpanded: _expandedSectionIndex == 1,
  onExpansionChanged: (expanded) {
    setState(() {
      _expandedSectionIndex = expanded ? 1 : null;
    });
  },
  title: _buildSectionTitle('Education'),
  children: _profile!.education.map((edu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileItem(icon: Icons.school, label: 'Post Graduation Degree', value: edu.postGraduationDegree),
        _buildProfileItem(icon: Icons.school, label: 'Post Graduation Specialization', value: edu.postGraduationSpecialization),
        _buildProfileItem(icon: Icons.percent, label: 'Post Graduation Percentage', value: edu.postGraduationPercentage),
        _buildProfileItem(icon: Icons.school, label: 'Post Graduation College', value: edu.postGraduationCollege),
        _buildProfileItem(icon: Icons.calendar_today, label: 'Post Graduation Year', value: edu.postGraduationYear),
        _buildProfileItem(icon: Icons.check_circle, label: 'Post Graduation Completed', value: edu.postGraduationCompleted ? 'Yes' : 'No'),
        const Divider(),
        _buildProfileItem(icon: Icons.school, label: 'Diploma Degree', value: edu.diplomaDegree),
        _buildProfileItem(icon: Icons.school, label: 'Diploma Specialization', value: edu.diplomaSpecialization),
        _buildProfileItem(icon: Icons.school, label: 'Diploma College', value: edu.diplomaCollege),
        _buildProfileItem(icon: Icons.percent, label: 'Diploma Percentage', value: edu.diplomaPercentage),
        _buildProfileItem(icon: Icons.calendar_today, label: 'Diploma Year', value: edu.diplomaYear),
        _buildProfileItem(icon: Icons.check_circle, label: 'Diploma Completed', value: edu.diplomaCompleted ? 'Yes' : 'No'),
        const Divider(),
        _buildProfileItem(icon: Icons.percent, label: '10th Percentage', value: edu.tenthPercentage),
        _buildProfileItem(icon: Icons.calendar_today, label: '10th Passing Year', value: edu.tenthPassingYear),
        _buildProfileItem(icon: Icons.percent, label: '12th Percentage', value: edu.twelfthPercentage),
        _buildProfileItem(icon: Icons.calendar_today, label: '12th Passing Year', value: edu.twelfthPassingYear),
        const Divider(),
        _buildProfileItem(icon: Icons.school, label: 'Graduation Degree', value: edu.graduationDegree),
        _buildProfileItem(icon: Icons.school, label: 'Graduation Specialization', value: edu.graduationSpecialization),
        _buildProfileItem(icon: Icons.school, label: 'Graduation College', value: edu.graduationCollege),
        _buildProfileItem(icon: Icons.percent, label: 'Graduation Percentage', value: edu.graduationPercentage),
        _buildProfileItem(icon: Icons.calendar_today, label: 'Graduation Year', value: edu.graduationYear),
        _buildProfileItem(icon: Icons.check_circle, label: 'Graduation Completed', value: edu.graduationCompleted ? 'Yes' : 'No'),
        const Divider(),
        _buildProfileItem(icon: Icons.check_circle, label: 'Has Educational Gap', value: edu.hasEducationalGap ? 'Yes' : 'No'),
        _buildProfileItem(icon: Icons.check_circle, label: 'Has Backlog', value: edu.hasBacklog ? 'Yes' : 'No'),
      ],
    );
  }).toList(),
),
const SizedBox(height: 8),

ExpansionTile(
  key: PageStorageKey('experience'),
  initiallyExpanded: _expandedSectionIndex == 2,
  onExpansionChanged: (expanded) {
    setState(() {
      _expandedSectionIndex = expanded ? 2 : null;
    });
  },
  title: _buildSectionTitle('Experience'),
  children: _profile!.experience.map((exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileItem(icon: Icons.work, label: 'Company', value: exp.company),
        _buildProfileItem(icon: Icons.timelapse, label: 'Years', value: exp.years),
        _buildProfileItem(icon: Icons.assignment_ind, label: 'Role', value: exp.role),
        _buildProfileItem(icon: Icons.star, label: 'Experience Level', value: exp.experienceLevel),
        _buildProfileItem(icon: Icons.work_outline, label: 'Internship Details', value: exp.internshipDetails),
        _buildProfileItem(icon: Icons.business, label: 'Previous Company', value: exp.previousCompany),
        _buildProfileItem(icon: Icons.attach_file, label: 'Certification', value: exp.certification),
        _buildProfileItem(icon: Icons.money, label: 'Last CTC', value: exp.lastCtc),
        _buildProfileItem(icon: Icons.business_center, label: 'Industry', value: exp.industry),
        const Divider(),
      ],
    );
  }).toList(),
),

                  ],
                ),
              ),
    );
  }
}

// ---------- Helper ----------
bool parseBool(dynamic value) => value == true || value == 'true';

// ---------- Models ----------

class Profile {
  final PersonalInfo personalInfo;
  final List<Education> education;
  final List<Experience> experience;

  Profile({
    required this.personalInfo,
    required this.education,
    required this.experience,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      personalInfo: PersonalInfo.fromJson(json['personalInfo'] ?? {}),
      education:
          (json['education'] as List<dynamic>? ?? [])
              .map((e) => Education.fromJson(e))
              .toList(),
      experience:
          (json['experience'] as List<dynamic>? ?? [])
              .map((e) => Experience.fromJson(e))
              .toList(),
    );
  }
}

class PersonalInfo {
  final String firstName,
      lastName,
      email,
      phone,
      dob,
      hometownCity,
      hometownState,
      currentState,
      currentLocation;

  PersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.hometownCity,
    required this.hometownState,
    required this.currentState,
    required this.currentLocation,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dob: json['dob'] ?? '',
      hometownCity: json['hometownCity'] ?? '',
      hometownState: json['hometownState'] ?? '',
      currentState: json['currentState'] ?? '',
      currentLocation: json['currentLocation'] ?? '',
    );
  }
}

class Education {
  final String postGraduationDegree,
      postGraduationSpecialization,
      postGraduationPercentage,
      postGraduationCollege,
      postGraduationYear;
  final bool postGraduationCompleted;
  final String diplomaDegree,
      diplomaSpecialization,
      diplomaCollege,
      diplomaPercentage,
      diplomaYear;
  final bool diplomaCompleted;
  final String tenthPercentage,
      tenthPassingYear,
      twelfthPercentage,
      twelfthPassingYear;
  final String graduationDegree,
      graduationSpecialization,
      graduationCollege,
      graduationPercentage,
      graduationYear;
  final bool graduationCompleted, hasEducationalGap, hasBacklog;

  Education({
    required this.postGraduationDegree,
    required this.postGraduationSpecialization,
    required this.postGraduationPercentage,
    required this.postGraduationCollege,
    required this.postGraduationYear,
    required this.postGraduationCompleted,
    required this.diplomaDegree,
    required this.diplomaSpecialization,
    required this.diplomaCollege,
    required this.diplomaPercentage,
    required this.diplomaYear,
    required this.diplomaCompleted,
    required this.tenthPercentage,
    required this.tenthPassingYear,
    required this.twelfthPercentage,
    required this.twelfthPassingYear,
    required this.graduationDegree,
    required this.graduationSpecialization,
    required this.graduationCollege,
    required this.graduationPercentage,
    required this.graduationYear,
    required this.graduationCompleted,
    required this.hasEducationalGap,
    required this.hasBacklog,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      postGraduationDegree: json['postGraduationDegree'] ?? '',
      postGraduationSpecialization: json['postGraduationSpecialization'] ?? '',
      postGraduationPercentage: json['postGraduationPercentage'] ?? '',
      postGraduationCollege: json['postGraduationCollege'] ?? '',
      postGraduationYear: json['postGraduationYear'] ?? '',
      postGraduationCompleted: parseBool(json['postGraduationCompleted']),
      diplomaDegree: json['diplomaDegree'] ?? '',
      diplomaSpecialization: json['diplomaSpecialization'] ?? '',
      diplomaCollege: json['diplomaCollege'] ?? '',
      diplomaPercentage: json['diplomaPercentage'] ?? '',
      diplomaYear: json['diplomaYear'] ?? '',
      diplomaCompleted: parseBool(json['diplomaCompleted']),
      tenthPercentage: json['tenthPercentage'] ?? '',
      tenthPassingYear: json['tenthPassingYear'] ?? '',
      twelfthPercentage: json['twelfthPercentage'] ?? '',
      twelfthPassingYear: json['twelfthPassingYear'] ?? '',
      graduationDegree: json['graduationDegree'] ?? '',
      graduationSpecialization: json['graduationSpecialization'] ?? '',
      graduationCollege: json['graduationCollege'] ?? '',
      graduationPercentage: json['graduationPercentage'] ?? '',
      graduationYear: json['graduationYear'] ?? '',
      graduationCompleted: parseBool(json['graduationCompleted']),
      hasEducationalGap: parseBool(json['hasEducationalGap']),
      hasBacklog: parseBool(json['hasBacklog']),
    );
  }
}

class Experience {
  final String company,
      years,
      role,
      experienceLevel,
      internshipDetails,
      previousCompany,
      certification,
      lastCtc,
      industry;

  Experience({
    required this.company,
    required this.years,
    required this.role,
    required this.experienceLevel,
    required this.internshipDetails,
    required this.previousCompany,
    required this.certification,
    required this.lastCtc,
    required this.industry,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      company: json['company'] ?? '',
      years: json['years'] ?? '',
      role: json['role'] ?? '',
      experienceLevel: json['experienceLevel'] ?? '',
      internshipDetails: json['internshipDetails'] ?? '',
      previousCompany: json['previousCompany'] ?? '',
      certification: json['certification'] ?? '',
      lastCtc: json['lastCtc'] ?? '',
      industry: json['industry'] ?? '',
    );
  }
}
