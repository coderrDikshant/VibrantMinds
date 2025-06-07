import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../screens/profile_screens/role_based_home.dart';  // Adjust the import path as needed

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
  final TextEditingController _currentLocationController = TextEditingController();
  final TextEditingController _hometownCityController = TextEditingController();
  final TextEditingController _currentStateController = TextEditingController();
  final TextEditingController _hometownStateController = TextEditingController();

  String? _gender;
  DateTime? _dob;

  String? _backendMessage;

  final List<String> _genders = ['Male', 'Female', 'Other'];

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
    _currentStateController.dispose();
    _hometownStateController.dispose();
    super.dispose();
  }

 Future<void> _checkIfCompleted() async {
  final requestPayload = {
    "httpMethod": "GET",
    "queryStringParameters": {
      "email": widget.email,
    },
  };

  try {
    final response = await http.post(
      Uri.parse('https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/User_exist/User_profile_exist'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestPayload),
    );

    print('GET Response status: ${response.statusCode}');
    print('GET Response body: ${response.body}');

  if (response.statusCode == 200) {
  final responseBody = jsonDecode(response.body);
  final innerBody = jsonDecode(responseBody['body']);

  final profile = innerBody['profile'] ?? {};
  final personalInfo = profile['personalInfo'] ?? {};

  final isCompleted = innerBody['completedPersonalInfo'] == true;
  final firstName = personalInfo['firstName'] ?? '';
  final lastName = personalInfo['lastName'] ?? '';

  print('Extracted firstName: $firstName, lastName: $lastName');

  if (isCompleted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RoleBasedHome(
          firstName: firstName,
          lastName: lastName,
        ),
      ),
    );
    return;
  }
}

  } catch (e) {
    debugPrint('Error checking personal info completion: $e');
  }

  setState(() {
    _isLoading = false;
  });
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
    if (!_formKey.currentState!.validate() || _gender == null || _dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields, including DOB and gender.")),
      );
      return;
    }
     print('Submitting firstName: ${_firstNameController.text.trim()}, lastName: ${_lastNameController.text.trim()}');
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
      "email": widget.email,
      "currentLocation": _currentLocationController.text.trim(),
      "hometownCity": _hometownCityController.text.trim(),
      "currentState": _currentStateController.text.trim(),
      "hometownState": _hometownStateController.text.trim(),
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
        Uri.parse('https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/User_exist/User_profile_exist'),
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

      if (innerBody['completedPersonalInfo'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personal info submitted successfully.')),
        );

      

        // Navigate directly to RoleBased page widget
      Navigator.pushReplacement(
  context,
  
  MaterialPageRoute(
    
    builder: (_) => RoleBasedHome(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    ),
  ),
);

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all personal information fields.')),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _backendMessage = 'Error submitting personal info: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_backendMessage!)),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Information')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_firstNameController, 'First Name'),
              _buildTextField(_lastNameController, 'Last Name'),
              DropdownButtonFormField<String>(
                value: _gender,
                items: _genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _gender = val),
                decoration: const InputDecoration(labelText: 'Gender'),
                validator: (val) => val == null ? 'Select gender' : null,
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
              if (_dob == null)
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
              _buildTextField(_phoneController, 'Phone Number', keyboardType: TextInputType.phone),
              _buildTextField(_currentLocationController, 'Current Location'),
              _buildTextField(_hometownCityController, 'Hometown City'),
              _buildTextField(_currentStateController, 'Current State'),
              _buildTextField(_hometownStateController, 'Hometown State'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPersonalInfo,
                child: _isSubmitting
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
                      style: const TextStyle(color: Colors.black87, fontSize: 12),
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
