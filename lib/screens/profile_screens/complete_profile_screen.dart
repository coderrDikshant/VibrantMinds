import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../widgets/profile_cards/personal_info_section.dart';
import '../../widgets/profile_cards/education_section.dart';
import '../../widgets/profile_cards/experience_section.dart';
import 'role_based_home.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String email;
  const CompleteProfileScreen({super.key, required this.email});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}
class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _personalInfoKey = GlobalKey<PersonalInfoSectionState>();
  final _educationKey = GlobalKey<EducationSectionState>();
  final _experienceKey = GlobalKey<ExperienceSectionState>();

  int _currentStep = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  final Map<String, dynamic> _collectedData = {};

  Future<bool> _submitSection(String section, Map<String, dynamic> data) async {
  // Prepare the inner payload (the body)
 final innerBody = {
  "email": widget.email,
  "action": 'update_$section',
  section: (section == 'education' || section == 'experience') ? data[section] : data,
};


  // 🔍 Print debug payloads
  print('Inner body: ${jsonEncode(innerBody)}');

  // Wrap it in the outer structure
  final wrappedPayload = {
    "httpMethod": "POST",
    "body": jsonEncode(innerBody),
  };

  print('Final wrapped payload: ${jsonEncode(wrappedPayload)}');

  try {
    final response = await http.post(
      Uri.parse('https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/User_exist/User_profile_exist'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(wrappedPayload),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response.statusCode == 200;
  } catch (e) {
    print('Error submitting $section: $e');
    return false;
  }
}


Future<bool> _submitProfileCompletion() async {
  try {
    final innerBody = {
      "email": widget.email,
      "action": "complete_profile",
    };

    final wrappedPayload = {
      "httpMethod": "POST",
      "body": jsonEncode(innerBody),
    };

    final response = await http.post(
      Uri.parse('https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/User_exist/User_profile_exist'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(wrappedPayload),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final body = jsonDecode(decoded['body']);
      return body['profileComplete'] == true;
    }

    return false;
  } catch (e) {
    print('Profile completion error: $e');
    return false;
  }
}


  void _onNext() async {
    setState(() => _errorMessage = null);

    // Validate the current form
    if (!_formKey.currentState!.validate()) {
      setState(() => _errorMessage = 'Please fill all required fields.');
      return;
    }

    setState(() => _isSubmitting = true);

    switch (_currentStep) {
      case 0:
        _personalInfoKey.currentState?.save();
        if (_collectedData['personalInfo'] == null) {
          setState(() {
            _errorMessage = 'Please complete personal info.';
            _isSubmitting = false;
          });
          return;
        }
        break;
      case 1:
        _educationKey.currentState?.save();
        if (_collectedData['education'] == null) {
          setState(() {
            _errorMessage = 'Please complete education info.';
            _isSubmitting = false;
          });
          return;
        }
        break;
      case 2:
        _experienceKey.currentState?.save();
        if (_collectedData['experience'] == null) {
          setState(() {
            _errorMessage = 'Please complete experience info.';
            _isSubmitting = false;
          });
          return;
        }
        break;
    }

    final sectionKeys = ['personalInfo', 'education', 'experience'];
    final currentSection = sectionKeys[_currentStep];
    final sectionData = _collectedData[currentSection]!;

    final success = await _submitSection(currentSection, sectionData);

    if (!mounted) return;

    if (success) {
      setState(() {
        _currentStep++;
        _isSubmitting = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Failed to save $currentSection. Please try again.';
        _isSubmitting = false;
      });
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _onFinish() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final success = await _submitProfileCompletion();

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleBasedHome()),
      );
    } else {
      setState(() {
        _errorMessage = 'Failed to complete profile. Please try again.';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> steps = [
      PersonalInfoSection(
        key: _personalInfoKey,
        email: widget.email,
        onSaved: (data) {
          _collectedData['personalInfo'] = data;
        },
      ),
      EducationSection(
        key: _educationKey,
        onSaved: (data) {
          _collectedData['education'] = data;
        },
      ),
      ExperienceSection(
        key: _experienceKey,
        onSaved: (data) {
          _collectedData['experience'] = data;
        },
      ),
      _buildCompletionStep(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _isSubmitting ? null : _onBack,
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentStep + 1) / steps.length,
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: Form(
                key: _formKey,
                child: IndexedStack(
                  index: _currentStep,
                  children: steps,
                ),
              ),
            ),
            if (_currentStep < steps.length - 1)
              ElevatedButton(
                onPressed: _isSubmitting ? null : _onNext,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Next'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          const Text(
            'Profile Completed!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _isSubmitting
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _onFinish,
                  child: const Text('Continue to App'),
                ),
        ],
      ),
    );
  }
}
