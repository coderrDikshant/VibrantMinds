import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

import '../../screens/profile_screens/role_based_home.dart'; // Adjust the import path as needed

class PersonalInfoScreen extends StatefulWidget {
  final String email;

  const PersonalInfoScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isLoading = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentLocationController =
      TextEditingController();
  final TextEditingController _hometownCityController = TextEditingController();
  // Removed currentStateController and hometownStateController as they will be dropdowns
  // String? _currentStateController; // Will hold selected current state
  // String? _hometownStateController; // Will hold selected hometown state

  String? _gender;
  DateTime? _dob;
  String? _currentState; // Use a String to hold the selected state
  String? _hometownState; // Use a String to hold the selected state

  String? _backendMessage;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _indianStates = [
    'Andaman and Nicobar Islands',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chandigarh',
    'Chhattisgarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jammu and Kashmir',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Ladakh',
    'Lakshadweep',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Puducherry',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.email.trim().isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email is missing! Cannot submit.')),
        );
      });
      setState(() => _isLoading = false);
    } else {
      _checkIfCompleted();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _currentLocationController.dispose();
    _hometownCityController.dispose();
    // No need to dispose controllers for dropdowns
    super.dispose();
  }

  Future<void> _checkIfCompleted() async {
    final requestPayload = {
      "httpMethod": "GET",
      "queryStringParameters": {"email": widget.email},
    };

    try {
      final response = await http.post(
        Uri.parse(
          'https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/User_exist/User_profile_exist',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestPayload),
      );

      debugPrint('GET Response status: ${response.statusCode}');
      debugPrint('GET Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final innerBody = jsonDecode(responseBody['body']);

        final profile = innerBody['profile'] ?? {};
        final personalInfo = profile['personalInfo'] ?? {};

        final isCompleted = innerBody['completedPersonalInfo'] == true;
        final firstName = personalInfo['firstName'] ?? '';
        final lastName = personalInfo['lastName'] ?? '';

        debugPrint('Extracted firstName: $firstName, lastName: $lastName');

        if (isCompleted) {
          // Store personal info in Hive before navigating
          final profileBox = Hive.box('profileBox');
          await profileBox.put(
            'personalInfo',
            personalInfo,
          ); // Store the entire personalInfo map

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      RoleBasedHome(firstName: firstName, lastName: lastName),
            ),
          );
          return; // Stop execution after navigation
        }
      }
    } catch (e) {
      debugPrint('Error checking personal info completion: $e');
      // If there's an error, assume not completed and proceed to form
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
      });
    }
  }

  Future<void> _submitPersonalInfo() async {
    if (!_formKey.currentState!.validate() ||
        _gender == null ||
        _dob == null ||
        _currentState == null ||
        _hometownState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all required fields.")),
      );
      return;
    }

    debugPrint(
      'Submitting firstName: ${_firstNameController.text.trim()}, lastName: ${_lastNameController.text.trim()}',
    );

    setState(() {
      _isSubmitting = true;
      _backendMessage = null;
    });

    final personalInfoData = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "gender": _gender,
      "dob": _dob!.toIso8601String(),
      "phone": _phoneController.text.trim(),
      "email": widget.email, // Email should come from widget.email
      "currentLocation": _currentLocationController.text.trim(),
      "hometownCity": _hometownCityController.text.trim(),
      "currentState": _currentState, // Use selected value
      "hometownState": _hometownState, // Use selected value
    };

    final requestPayload = {
      "httpMethod": "POST",
      "body": jsonEncode({
        "email": widget.email,
        "action": "update_personalInfo",
        "personalInfo": personalInfoData,
      }),
    };

    try {
      final response = await http.post(
        Uri.parse(
          'https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/User_exist/User_profile_exist',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestPayload),
      );

      setState(() {
        _isSubmitting = false;
      });

      final outerResponse = jsonDecode(response.body);
      final innerBody = jsonDecode(outerResponse['body']);

      setState(() {
        _backendMessage = const JsonEncoder.withIndent('  ').convert(innerBody);
      });

      if (innerBody['statusCode'] == 200 &&
          innerBody['completedPersonalInfo'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal info submitted successfully.'),
          ),
        );

        // Store personal info in Hive upon successful submission
        final profileBox = Hive.box('profileBox');
        await profileBox.put('personalInfo', personalInfoData);

        // Navigate directly to RoleBased page widget
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => RoleBasedHome(
                  firstName: _firstNameController.text.trim(),
                  lastName: _lastNameController.text.trim(),
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${innerBody['message'] ?? 'Please complete all personal information fields.'}',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _backendMessage = 'Error submitting personal info: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_backendMessage!)));
    }
  }

  String? _validateNameField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (RegExp(r'[0-9]').hasMatch(value)) {
      return '$fieldName cannot contain numbers';
    }
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return '$fieldName cannot contain special characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  // Helper method for generic text fields that just need to be non-empty
  String? _validateRequiredText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Information')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (val) => _validateNameField(val, 'First Name'),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (val) => _validateNameField(val, 'Last Name'),
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                items:
                    _genders
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                onChanged: (val) => setState(() => _gender = val),
                decoration: const InputDecoration(labelText: 'Gender'),
                validator: (val) => val == null ? 'Gender is required' : null,
              ),
              ListTile(
                title: Text(
                  _dob == null
                      ? 'Select Date of Birth'
                      : 'DOB: ${_dob!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              // Manual validation message for DOB if not selected
              if (_dob == null &&
                  _formKey.currentState?.validate() ==
                      false) // Only show if form is trying to validate
                const Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Date of Birth is required',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: _validatePhone,
              ),
              TextFormField(
                controller: _currentLocationController,
                decoration: const InputDecoration(
                  labelText: 'Current Location',
                ),
                validator:
                    (val) => _validateRequiredText(val, 'Current Location'),
              ),
              TextFormField(
                controller: _hometownCityController,
                decoration: const InputDecoration(labelText: 'Hometown City'),
                validator: (val) => _validateRequiredText(val, 'Hometown City'),
              ),
              // Dropdown for Current State
              DropdownButtonFormField<String>(
                value: _currentState,
                items:
                    _indianStates
                        .map(
                          (state) => DropdownMenuItem(
                            value: state,
                            child: Text(state),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _currentState = val),
                decoration: const InputDecoration(labelText: 'Current State'),
                validator:
                    (val) => val == null ? 'Current State is required' : null,
              ),
              // Dropdown for Hometown State
              DropdownButtonFormField<String>(
                value: _hometownState,
                items:
                    _indianStates
                        .map(
                          (state) => DropdownMenuItem(
                            value: state,
                            child: Text(state),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _hometownState = val),
                decoration: const InputDecoration(labelText: 'Hometown State'),
                validator:
                    (val) => val == null ? 'Hometown State is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPersonalInfo,
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit'),
              ),
              if (_backendMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey.shade200,
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: SingleChildScrollView(
                    child: Text(
                      'Backend response:\n$_backendMessage',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
