import 'package:flutter/material.dart';

class EducationSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onSaved;

  const EducationSection({super.key, required this.onSaved});

  @override
  EducationSectionState createState() => EducationSectionState();
}

class EducationSectionState extends State<EducationSection> {
  final _localFormKey = GlobalKey<FormState>();

  String? _tenthYear;
  String? _twelfthYear;
  String? _graduationDegree;

  void save() {
    if (_localFormKey.currentState?.validate() ?? false) {
      _localFormKey.currentState?.save();
      widget.onSaved({
        'education': [
          {
            'tenthPassingYear': _tenthYear,
            'twelfthPassingYear': _twelfthYear,
            'graduationDegree': _graduationDegree,
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
        padding: const EdgeInsets.all(8.0),
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: '10th Passing Year'),
            keyboardType: TextInputType.number,
            validator: (val) =>
                val == null || val.isEmpty ? '10th passing year is required' : null,
            onSaved: (val) => _tenthYear = val,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: '12th Passing Year'),
            keyboardType: TextInputType.number,
            validator: (val) =>
                val == null || val.isEmpty ? '12th passing year is required' : null,
            onSaved: (val) => _twelfthYear = val,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Graduation Degree'),
            validator: (val) =>
                val == null || val.isEmpty ? 'Graduation degree is required' : null,
            onSaved: (val) => _graduationDegree = val,
          ),
        ],
      ),
    );
  }
}
