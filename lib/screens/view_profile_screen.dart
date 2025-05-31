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
        _errorMessage = 'Error loading profile: \$e';
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                            _profile!.personalInfo.firstName[0],
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
                          value: '${_profile!.personalInfo.firstName} ${_profile!.personalInfo.lastName}'),
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
                          label: 'DOB',
                          value: _profile!.personalInfo.dob),
                      _buildProfileItem(
                          icon: Icons.location_city,
                          label: 'Location',
                          value: _profile!.personalInfo.currentLocation),

                      _buildSectionTitle('Education'),
                      ..._profile!.education.map((edu) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileItem(icon: Icons.school, label: 'Graduation Degree', value: edu.graduationDegree),
                              _buildProfileItem(icon: Icons.school, label: 'Graduation College', value: edu.graduationCollege),
                              _buildProfileItem(icon: Icons.school, label: 'Graduation Year', value: edu.graduationYear),
                            ],
                          )),

                      _buildSectionTitle('Experience'),
                      ..._profile!.experience.map((exp) => Column(
                            children: [
                              _buildProfileItem(icon: Icons.work, label: 'Company', value: exp.company),
                              _buildProfileItem(icon: Icons.work_history, label: 'Years', value: exp.years),
                              _buildProfileItem(icon: Icons.assignment_ind, label: 'Role', value: exp.role),
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
      education: (json['education'] as List).map((e) => Education.fromJson(e)).toList(),
      experience: (json['experience'] as List).map((e) => Experience.fromJson(e)).toList(),
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
  final String graduationDegree;
  final String graduationCollege;
  final String graduationYear;

  Education({
    required this.graduationDegree,
    required this.graduationCollege,
    required this.graduationYear,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      graduationDegree: json['graduationDegree'] ?? '',
      graduationCollege: json['graduationCollege'] ?? '',
      graduationYear: json['graduationYear'] ?? '',
    );
  }
}

class Experience {
  final String company;
  final String years;
  final String role;

  Experience({
    required this.company,
    required this.years,
    required this.role,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      company: json['company'] ?? '',
      years: json['years'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
