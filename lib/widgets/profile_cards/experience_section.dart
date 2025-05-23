import 'package:flutter/material.dart';

class ExperienceSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onSaved;

  const ExperienceSection({super.key, required this.onSaved});

  @override
  ExperienceSectionState createState() => ExperienceSectionState();
}

class ExperienceSectionState extends State<ExperienceSection> {
  final _localFormKey = GlobalKey<FormState>();

  String? _company;
  String? _role;
  String? _years;

  void save() {
    if (_localFormKey.currentState?.validate() ?? false) {
      _localFormKey.currentState?.save();
      widget.onSaved({
        'experience': [
          {
            'company': _company,
            'role': _role,
            'years': _years,
          }
        ]
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
            decoration: const InputDecoration(labelText: 'Company'),
            validator: (val) =>
                val == null || val.isEmpty ? 'Company is required' : null,
            onSaved: (val) => _company = val,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Role'),
            validator: (val) =>
                val == null || val.isEmpty ? 'Role is required' : null,
            onSaved: (val) => _role = val,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Years of Experience'),
            keyboardType: TextInputType.number,
            validator: (val) =>
                val == null || val.isEmpty ? 'Years is required' : null,
            onSaved: (val) => _years = val,
          ),
        ],
      ),
    );
  }
}
