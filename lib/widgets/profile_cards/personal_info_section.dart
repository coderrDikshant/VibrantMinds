import 'package:flutter/material.dart';

class PersonalInfoSection extends StatefulWidget {
  final String email;
  final Function(Map<String, dynamic>) onSaved;

  const PersonalInfoSection({
    super.key,
    required this.email,
    required this.onSaved,
  });

  @override
  PersonalInfoSectionState createState() => PersonalInfoSectionState();
}

class PersonalInfoSectionState extends State<PersonalInfoSection> {
  final _localFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentLocationController = TextEditingController();
  final _hometownCityController = TextEditingController();

  String? _gender;
  DateTime? _dob;
  String? _currentState;
  String? _hometownState;
  String? _errorMessage;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _indianStates = [
    'Andaman and Nicobar Islands', 'Andhra Pradesh', 'Arunachal Pradesh', 'Assam',
    'Bihar', 'Chandigarh', 'Chhattisgarh', 'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jammu and Kashmir',
    'Jharkhand', 'Karnataka', 'Kerala', 'Ladakh', 'Lakshadweep', 'Madhya Pradesh',
    'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha',
    'Puducherry', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana',
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  ];

  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() => _dob = picked);
    }
  }

  void save() {
    setState(() => _errorMessage = null);
    if (_localFormKey.currentState!.validate()) {
      if (_gender == null) {
        setState(() => _errorMessage = 'Please select a gender');
        return;
      }
      if (_dob == null) {
        setState(() => _errorMessage = 'Date of birth is required');
        return;
      }
      if (_currentState == null) {
        setState(() => _errorMessage = 'Current state is required');
        return;
      }
      if (_hometownState == null) {
        setState(() => _errorMessage = 'Hometown state is required');
        return;
      }

      widget.onSaved({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'gender': _gender,
        'dob': _dob?.toIso8601String(),
        'phone': _phoneController.text.trim(),
        'currentCity': _currentLocationController.text.trim(),
        'hometownCity': _hometownCityController.text.trim(),
        'currentState': _currentState,
        'hometownState': _hometownState,
        'email': widget.email,
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _currentLocationController.dispose();
    _hometownCityController.dispose();
    super.dispose();
  }

  String? _validateTextField(String? value, String fieldName) {
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _localFormKey,
      child: SafeArea(
        child: SingleChildScrollView(
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => _validateTextField(val, "First name"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => _validateTextField(val, "Last name"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: _genders
                    .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
                    .toList(),
                onChanged: (val) => setState(() => _gender = val),
                value: _gender,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _dob == null
                      ? 'Select Date of Birth'
                      : 'DOB: ${_dob!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
                shape: const OutlineInputBorder(),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(val.trim())) {
                    return 'Enter valid 10-digit Indian phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _currentLocationController,
                decoration: const InputDecoration(
                  labelText: 'Current Location',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => _validateTextField(val, "Current location"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hometownCityController,
                decoration: const InputDecoration(
                  labelText: 'Hometown City',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => _validateTextField(val, "Hometown city"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Current State',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: _indianStates
                    .map((state) => DropdownMenuItem(
                  value: state,
                  child: Text(state),
                ))
                    .toList(),
                onChanged: (val) => setState(() => _currentState = val),
                value: _currentState,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Hometown State',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: _indianStates
                    .map((state) => DropdownMenuItem(
                  value: state,
                  child: Text(state),
                ))
                    .toList(),
                onChanged: (val) => setState(() => _hometownState = val),
                value: _hometownState,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
