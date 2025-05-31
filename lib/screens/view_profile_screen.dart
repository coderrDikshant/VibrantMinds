import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final response = await http.post(
        Uri.parse('https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/User_exist/User_profile_exist'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "httpMethod": "GET",
          "queryStringParameters": {"email": widget.userEmail}
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final body = jsonDecode(responseBody['body']);
        final profileJson = body['profile'];

        setState(() {
          _profile = Profile.fromJson(profileJson);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
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
                Text(label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                Text(value),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
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
                      _buildSectionTitle('Personal Info'),
                      _buildProfileItem(
                          icon: Icons.person,
                          label: 'Name',
                          value:
                              '${_profile!.personalInfo.firstName} ${_profile!.personalInfo.lastName}'),
                      _buildProfileItem(
                          icon: Icons.email,
                          label: 'Email',
                          value: _profile!.personalInfo.email),
                      _buildProfileItem(
                          icon: Icons.phone,
                          label: 'Phone',
                          value: _profile!.personalInfo.phone),
                      _buildProfileItem(
                          icon: Icons.calendar_today,
                          label: 'Date of Birth',
                          value: _profile!.personalInfo.dob),
                      _buildProfileItem(
                          icon: Icons.location_city,
                          label: 'Hometown City',
                          value: _profile!.personalInfo.hometownCity),
                      _buildProfileItem(
                          icon: Icons.location_on,
                          label: 'Hometown State',
                          value: _profile!.personalInfo.hometownState),
                      _buildProfileItem(
                          icon: Icons.location_on,
                          label: 'Current State',
                          value: _profile!.personalInfo.currentState),
                      _buildProfileItem(
                          icon: Icons.location_on,
                          label: 'Current Location',
                          value: _profile!.personalInfo.currentLocation),

                      _buildSectionTitle('Education'),
                      ..._profile!.education.map((edu) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileItem(
                                  icon: Icons.school,
                                  label: 'Post Graduation Degree',
                                  value: edu.postGraduationDegree),
                              _buildProfileItem(
                                  icon: Icons.school,
                                  label: 'Post Graduation Specialization',
                                  value: edu.postGraduationSpecialization),
                              _buildProfileItem(
                                  icon: Icons.percent,
                                  label: 'Post Graduation Percentage',
                                  value: edu.postGraduationPercentage),
                              _buildProfileItem(
                                  icon: Icons.school,
                                  label: 'Post Graduation College',
                                  value: edu.postGraduationCollege),
                              _buildProfileItem(
                                  icon: Icons.school,
                                  label: 'Post Graduation Year',
                                  value: edu.postGraduationYear),
                              _buildProfileItem(
                                  icon: Icons.check_circle,
                                  label: 'Post Graduation Completed',
                                  value: edu.postGraduationCompleted ? 'Yes' : 'No'),
                              const Divider(),
                              _buildProfileItem(
                                  icon: Icons.school,
                                  label: 'Diploma Degree',
                                  value: edu.diplomaDegree),
                              _buildProfileItem(
                                  icon: Icons.school,
                                  label: 'Diploma Specialization',
                                  value: edu.diplomaSpecialization),
                              _buildProfileItem(
                                  icon: Icons.school,
                                  label: 'Diploma College',
                                  value: edu.diplomaCollege),
                              _buildProfileItem(
                                  icon: Icons.percent,
                                  label: 'Diploma Percentage',
                                  value: edu.diplomaPercentage),
                              _buildProfileItem(
                                  icon: Icons.calendar_today,
                                  label: 'Diploma Year',
                                  value: edu.diplomaYear),
                              _buildProfileItem(
                                  icon: Icons.check_circle,
                                  label: 'Diploma Completed',
                                  value: edu.diplomaCompleted ? 'Yes' : 'No'),
                              const Divider(),
                              _buildProfileItem(
                                  icon: Icons.percent,
                                  label: '10th Percentage',
                                  value: edu.tenthPercentage),
                              _buildProfileItem(
                                  icon: Icons.calendar_today,
                                  label: '10th Passing Year',
                                  value: edu.tenthPassingYear),
                              _buildProfileItem(
                                  icon: Icons.percent,
                                  label: '12th Percentage',
                                  value: edu.twelfthPercentage),
                              _buildProfileItem(
                                  icon: Icons.calendar_today,
                                  label: '12th Passing Year',
                                  value: edu.twelfthPassingYear),
                              const Divider(),
                              _buildProfileItem(
                                  icon: Icons.school,
                                  label: 'Graduation Degree',
                                  value: edu.graduationDegree),
                              _buildProfileItem(
                                  icon: Icons.school,
                                  label: 'Graduation Specialization',
                                  value: edu.graduationSpecialization),
                              _buildProfileItem(
                                  icon: Icons.school,
                                  label: 'Graduation College',
                                  value: edu.graduationCollege),
                              _buildProfileItem(
                                  icon: Icons.percent,
                                  label: 'Graduation Percentage',
                                  value: edu.graduationPercentage),
                              _buildProfileItem(
                                  icon: Icons.calendar_today,
                                  label: 'Graduation Year',
                                  value: edu.graduationYear),
                              _buildProfileItem(
                                  icon: Icons.check_circle,
                                  label: 'Graduation Completed',
                                  value: edu.graduationCompleted ? 'Yes' : 'No'),
                              const Divider(),
                              _buildProfileItem(
                                  icon: Icons.check_circle,
                                  label: 'Has Educational Gap',
                                  value: edu.hasEducationalGap ? 'Yes' : 'No'),
                              _buildProfileItem(
                                  icon: Icons.check_circle,
                                  label: 'Has Backlog',
                                  value: edu.hasBacklog ? 'Yes' : 'No'),
                            ],
                          )),

                      _buildSectionTitle('Experience'),
                      ..._profile!.experience.map((exp) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileItem(
                                  icon: Icons.work,
                                  label: 'Company',
                                  value: exp.company),
                              _buildProfileItem(
                                  icon: Icons.timelapse,
                                  label: 'Years',
                                  value: exp.years),
                              _buildProfileItem(
                                  icon: Icons.assignment_ind,
                                  label: 'Role',
                                  value: exp.role),
                              _buildProfileItem(
                                  icon: Icons.star,
                                  label: 'Experience Level',
                                  value: exp.experienceLevel),
                              _buildProfileItem(
                                  icon: Icons.work_outline,
                                  label: 'Internship Details',
                                  value: exp.internshipDetails),
                              _buildProfileItem(
                                  icon: Icons.business,
                                  label: 'Previous Company',
                                  value: exp.previousCompany),
                              _buildProfileItem(
                                  icon: Icons.attach_file,
                                  label: 'Certification',
                                  value: exp.certification),
                              _buildProfileItem(
                                  icon: Icons.money,
                                  label: 'Last CTC',
                                  value: exp.lastCTC),
                            ],
                          )),
                    ],
                  ),
                ),
    );
  }
}

class Profile {
  final PersonalInfo personalInfo;
  final List<Education> education;
  final List<Experience> experience;
  final String completedAt;
  final String email;
  final bool profileComplete;

  Profile({
    required this.personalInfo,
    required this.education,
    required this.experience,
    required this.completedAt,
    required this.email,
    required this.profileComplete,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      personalInfo: PersonalInfo.fromJson(json['personalInfo']),
      education:
          (json['education'] as List).map((e) => Education.fromJson(e)).toList(),
      experience: (json['experience'] as List)
          .map((e) => Experience.fromJson(e))
          .toList(),
      completedAt: json['completedAt'] ?? '',
      email: json['email'] ?? '',
      profileComplete: json['profileComplete'] ?? false,
    );
  }
}

class PersonalInfo {
  final String firstName;
  final String lastName;
  final String hometownState;
  final String gender;
  final String phone;
  final String dob;
  final String hometownCity;
  final String currentState;
  final String email;
  final String currentLocation;

  PersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.hometownState,
    required this.gender,
    required this.phone,
    required this.dob,
    required this.hometownCity,
    required this.currentState,
    required this.email,
    required this.currentLocation,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      hometownState: json['hometownState'] ?? '',
      gender: json['gender'] ?? '',
      phone: json['phone'] ?? '',
      dob: json['dob'] ?? '',
      hometownCity: json['hometownCity'] ?? '',
      currentState: json['currentState'] ?? '',
      email: json['email'] ?? '',
      currentLocation: json['currentLocation'] ?? '',
    );
  }
}
class Education {
  final String postGraduationDegree;
  final String postGraduationSpecialization;
  final String postGraduationPercentage;
  final String postGraduationYear;
  final String postGraduationCollege;  // <-- Add this
  final String diplomaCollege;
  final String diplomaPercentage;
  final String diplomaYear;
  final String diplomaDegree;
  final String diplomaSpecialization;
  final bool diplomaCompleted;
  final String tenthPercentage;
  final String twelfthPercentage;
  final String graduationCollege;
  final String graduationDegree;
  final String graduationYear;
  final String graduationSpecialization;
  final String graduationPercentage;
  final bool graduationCompleted;
  final bool postGraduationCompleted;
  final String tenthPassingYear;
  final String twelfthPassingYear;
  final bool hasEducationalGap;
  final bool hasBacklog;

  Education({
    required this.postGraduationDegree,
    required this.postGraduationSpecialization,
    required this.postGraduationPercentage,
    required this.postGraduationYear,
    required this.postGraduationCollege, // <-- Add this
    required this.diplomaCollege,
    required this.diplomaPercentage,
    required this.diplomaYear,
    required this.diplomaDegree,
    required this.diplomaSpecialization,
    required this.diplomaCompleted,
    required this.tenthPercentage,
    required this.twelfthPercentage,
    required this.graduationCollege,
    required this.graduationDegree,
    required this.graduationYear,
    required this.graduationSpecialization,
    required this.graduationPercentage,
    required this.graduationCompleted,
    required this.postGraduationCompleted,
    required this.tenthPassingYear,
    required this.twelfthPassingYear,
    required this.hasEducationalGap,
    required this.hasBacklog,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      postGraduationDegree: json['postGraduationDegree'] ?? '',
      postGraduationSpecialization: json['postGraduationSpecialization'] ?? '',
      postGraduationPercentage: json['postGraduationPercentage'] ?? '',
      postGraduationYear: json['postGraduationYear'] ?? '',
      postGraduationCollege: json['postGraduationCollege'] ?? '', // <-- Add this
      diplomaCollege: json['diplomaCollege'] ?? '',
      diplomaPercentage: json['diplomaPercentage'] ?? '',
      diplomaYear: json['diplomaYear'] ?? '',
      diplomaDegree: json['diplomaDegree'] ?? '',
      diplomaSpecialization: json['diplomaSpecialization'] ?? '',
      diplomaCompleted: json['diplomaCompleted'] ?? false,
      tenthPercentage: json['tenthPercentage'] ?? '',
      twelfthPercentage: json['twelfthPercentage'] ?? '',
      graduationCollege: json['graduationCollege'] ?? '',
      graduationDegree: json['graduationDegree'] ?? '',
      graduationYear: json['graduationYear'] ?? '',
      graduationSpecialization: json['graduationSpecialization'] ?? '',
      graduationPercentage: json['graduationPercentage'] ?? '',
      graduationCompleted: json['graduationCompleted'] ?? false,
      postGraduationCompleted: json['postGraduationCompleted'] ?? false,
      tenthPassingYear: json['tenthPassingYear'] ?? '',
      twelfthPassingYear: json['twelfthPassingYear'] ?? '',
      hasEducationalGap: json['hasEducationalGap'] == 'Yes',
      hasBacklog: json['hasBacklog'] == 'Yes',
    );
  }
}


class Experience {
  final String experienceLevel;
  final String role;
  final String internshipDetails;
  final String company;
  final String lastCTC;
  final String years;
  final String previousCompany;
  final String certification;

  Experience({
    required this.experienceLevel,
    required this.role,
    required this.internshipDetails,
    required this.company,
    required this.lastCTC,
    required this.years,
    required this.previousCompany,
    required this.certification,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      experienceLevel: json['experienceLevel'] ?? '',
      role: json['role'] ?? '',
      internshipDetails: json['internshipDetails'] ?? '',
      company: json['company'] ?? '',
      lastCTC: json['lastCTC'] ?? '',
      years: json['years'] ?? '',
      previousCompany: json['previousCompany'] ?? '',
      certification: json['certification'] ?? '',
    );
  }
}
