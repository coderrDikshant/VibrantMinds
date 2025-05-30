import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

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
  Map<String, String> _userAttributes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserAttributes();
  }

  Future<void> _fetchUserAttributes() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      final attributeMap = {
        for (var attr in attributes) attr.userAttributeKey.key: attr.value
      };
      setState(() {
        _userAttributes = attributeMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'User Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000000),
            fontFamily: 'Poppins',
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD32F2F)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFD32F2F),
                child: Text(
                  widget.userName.isNotEmpty
                      ? widget.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProfileItem(
                      icon: Icons.person,
                      label: 'Name',
                      value: widget.userName.isNotEmpty
                          ? widget.userName
                          : 'Not provided',
                    ),
                    _buildProfileItem(
                      icon: Icons.email,
                      label: 'Email',
                      value: widget.userEmail.isNotEmpty
                          ? widget.userEmail
                          : 'Not provided',
                    ),
                    _buildProfileItem(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: _userAttributes['phone_number'] ?? 'Not provided',
                    ),
                    _buildProfileItem(
                      icon: Icons.calendar_today,
                      label: 'Date of Birth',
                      value: _userAttributes['birthdate'] ?? 'Not provided',
                    ),
                    _buildProfileItem(
                      icon: Icons.location_city,
                      label: 'Address',
                      value: _userAttributes['address'] ?? 'Not provided',
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFFD32F2F),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}