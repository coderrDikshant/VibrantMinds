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

  String? _firstName;
  String? _lastName;
  String? _gender;
  DateTime? _dob;
  String? _phone;
  String? _currentLocation;
  String? _hometownCity;
  String? _currentState;
  String? _hometownState;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  void save() {
    if (_localFormKey.currentState?.validate() ?? false) {
      _localFormKey.currentState?.save();
      widget.onSaved({
        'firstName': _firstName,
        'lastName': _lastName,
        'gender': _gender,
        'dob': _dob?.toIso8601String(),
        'phone': _phone,
        'email': widget.email,
        'currentLocation': _currentLocation,
        'hometownCity': _hometownCity,
        'currentState': _currentState,
        'hometownState': _hometownState,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _localFormKey,
      child: ListView(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'First Name'),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            onSaved: (val) => _firstName = val,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Last Name'),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            onSaved: (val) => _lastName = val,
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Gender'),
            items: _genders
                .map((gender) => DropdownMenuItem(
              value: gender,
              child: Text(gender),
            ))
                .toList(),
            onChanged: (val) => setState(() => _gender = val),
            onSaved: (val) => _gender = val,
            validator: (val) => val == null ? 'Select gender' : null,
          ),
          ListTile(
            title: Text(
              _dob == null
                  ? 'Select Date of Birth'
                  : 'DOB: ${_dob!.toLocal().toString().split(' ')[0]}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context),
          ),
          if (_dob == null)
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                'Date of birth is required',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Phone Number'),
            keyboardType: TextInputType.phone,
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            onSaved: (val) => _phone = val,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Current Location'),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            onSaved: (val) => _currentLocation = val,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Hometown City'),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            onSaved: (val) => _hometownCity = val,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Current State'),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            onSaved: (val) => _currentState = val,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Hometown State'),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            onSaved: (val) => _hometownState = val,
          ),
        ],
      ),
    );
  }
}
