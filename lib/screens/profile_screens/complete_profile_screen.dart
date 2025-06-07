import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../../widgets/profile_cards/education_section.dart';
import '../../widgets/profile_cards/experience_section.dart';
import '../../widgets/profile_cards/profile_redirector.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String email;

  const CompleteProfileScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<EducationSectionState> _educationKey = GlobalKey<EducationSectionState>();
  final GlobalKey<ExperienceSectionState> _experienceKey = GlobalKey<ExperienceSectionState>();

  bool _isSubmitting = false;
  int _currentStep = 0;
  String? _errorMessage;
  late Box _profileBox;
  Map<String, dynamic> _collectedData = {};

  @override
  void initState() {
    super.initState();
    _profileBox = Hive.box('profileBox');
    // Safely retrieve and cast data from Hive
    final educationData = _profileBox.get('education');
    final experienceData = _profileBox.get('experience');
    
    // Ensure educationData is in the correct format: {'education': [Map<String, dynamic>]}
    if (educationData != null && educationData is Map) {
      _collectedData['education'] = {
        'education': educationData['education'] is List
            ? List<Map<String, dynamic>>.from(
                educationData['education'].map((e) => Map<String, dynamic>.from(e)))
            : [Map<String, dynamic>.from(educationData)]
      };
    }
    
    // Ensure experienceData is in the correct format (assuming similar structure)
    if (experienceData != null && experienceData is Map) {
      _collectedData['experience'] = {
        'experience': experienceData['experience'] is List
            ? List<Map<String, dynamic>>.from(
                experienceData['experience'].map((e) => Map<String, dynamic>.from(e)))
            : [Map<String, dynamic>.from(experienceData)]
      };
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _errorMessage = null;
      });
    }
  }

  Future<bool> _submitSection(String section, Map<String, dynamic> data) async {
    final innerBody = {
      "email": widget.email,
      "action": 'update_$section',
      section: data[section], // Send the list directly
    };

    print('Inner body: ${jsonEncode(innerBody)}');

    final wrappedPayload = {
      "httpMethod": "POST",
      "body": jsonEncode(innerBody),
    };

    print('Wrapped Payload: ${jsonEncode(wrappedPayload)}');

    try {
      final response = await http.post(
        Uri.parse('https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/User_exist/User_profile_exist'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(wrappedPayload),
      );

      print('Response Status: ${response.statusCode}');
      print('Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> outer = jsonDecode(response.body);
        final dynamic bodyData = outer['body'];
        
        final Map<String, dynamic> body = bodyData is String
            ? jsonDecode(bodyData) as Map<String, dynamic>
            : Map<String, dynamic>.from(bodyData);
            
        print('Decoded body: $body');
        // Return true if the submission was successful, regardless of profileComplete
        return body['message'] == 'Profile updated successfully';
      }
      return false;
    } catch (e) {
      debugPrint('Error submitting $section: $e');
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
        final Map<String, dynamic> outer = jsonDecode(response.body);
        final dynamic bodyData = outer['body'];
        
        final Map<String, dynamic> body = bodyData is String
            ? jsonDecode(bodyData) as Map<String, dynamic>
            : Map<String, dynamic>.from(bodyData);
            
        return body['profileComplete'] == true;
      }
      return false;
    } catch (e) {
      print('Profile completion error: $e');
      return false;
    }
  }

  void _onNext() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = 'Please fill all required fields.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    if (_currentStep == 0) {
      _educationKey.currentState?.save();
    } else if (_currentStep == 1) {
      _experienceKey.currentState?.save();
    }

    final List<String> sectionKeys = ['education', 'experience'];

    if (_currentStep >= sectionKeys.length) {
      setState(() {
        _errorMessage = 'Invalid step.';
        _isSubmitting = false;
      });
      return;
    }

    final currentSection = sectionKeys[_currentStep];
    final sectionData = _collectedData[currentSection];

    if (sectionData == null) {
      setState(() {
        _errorMessage = 'Please complete $currentSection.';
        _isSubmitting = false;
      });
      return;
    }

    _profileBox.put(currentSection, sectionData);

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
        MaterialPageRoute(
          builder: (_) => ProfileRedirector(),
        ),
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
    final List<Widget> steps = [
      EducationSection(
        key: _educationKey,
        initialData: _collectedData['education'],
        onSaved: (data) {
          _collectedData['education'] = data;
        },
      ),
      ExperienceSection(
        key: _experienceKey,
        initialData: _collectedData['experience'],
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