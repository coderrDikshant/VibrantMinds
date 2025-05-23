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

  String? _name;
  String? _phone;

  void save() {
    if (_localFormKey.currentState?.validate() ?? false) {
      _localFormKey.currentState?.save();
      widget.onSaved({
        'name': _name,
        'phone': _phone,
        'email': widget.email,
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
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (val) =>
                val == null || val.isEmpty ? 'Name is required' : null,
            onSaved: (val) => _name = val,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Phone Number'),
            keyboardType: TextInputType.phone,
            validator: (val) =>
                val == null || val.isEmpty ? 'Phone is required' : null,
            onSaved: (val) => _phone = val,
          ),
        ],
      ),
    );
  }
}
