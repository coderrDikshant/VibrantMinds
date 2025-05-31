import 'package:flutter/material.dart';

class ExperienceSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onSaved;

  const ExperienceSection({super.key, required this.onSaved});

  @override
  ExperienceSectionState createState() => ExperienceSectionState();
}

class ExperienceSectionState extends State<ExperienceSection> {
  final _localFormKey = GlobalKey<FormState>();

  String? _experienceLevel;
  String? _company;
  String? _role;
  String? _years;
  String? _lastCTC;
  String? _internshipDetails;
  String? _previousCompany;
  String? _certification;

  final List<String> _experienceOptions = [
    'Fresher',
    '0–3 months',
    '3–6 months',
    '6 months – 1 year',
    'More than 1 year',
  ];

  void save() {
    if (_localFormKey.currentState?.validate() ?? false) {
      _localFormKey.currentState?.save();
      widget.onSaved({
        'experience': [
          {
            'experienceLevel': _experienceLevel,
            'company': _company,
            'role': _role,
            'years': _years,
            'previousCompany': _previousCompany,
            'lastCTC': _lastCTC,
            'internshipDetails': _internshipDetails,
            'certification': _certification,
          }
        ]
      });
    }
  }

  bool get isFresher => _experienceLevel == 'Fresher';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _localFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Experience Level'),
            value: _experienceLevel,
            items: _experienceOptions
                .map((exp) => DropdownMenuItem(
              value: exp,
              child: Text(exp),
            ))
                .toList(),
            validator: (val) =>
            val == null ? 'Please select experience level' : null,
            onChanged: (val) {
              setState(() {
                _experienceLevel = val;
              });
            },
            onSaved: (val) => _experienceLevel = val,
          ),
          const SizedBox(height: 12),
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
            decoration:
            const InputDecoration(labelText: 'Years of Experience'),
            keyboardType: TextInputType.number,
            validator: (val) =>
            val == null || val.isEmpty ? 'Years is required' : null,
            onSaved: (val) => _years = val,
          ),
          TextFormField(
            enabled: !isFresher,
            decoration: const InputDecoration(
                labelText: 'Previous Company Name (if applicable)'),
            validator: (val) {
              if (!isFresher && (val == null || val.isEmpty)) {
                return 'Previous company is required';
              }
              return null;
            },
            onSaved: (val) => _previousCompany = isFresher ? 'NA' : val,
          ),
          TextFormField(
            decoration:
            const InputDecoration(labelText: 'Last CTC (Per Annum)'),
            validator: (val) {
              if (val == null || val.isEmpty) return 'CTC is required';
              if (isFresher && val.trim().toUpperCase() != 'NA') {
                return 'Fresher must enter NA';
              }
              return null;
            },
            onSaved: (val) => _lastCTC = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText:
              'Live Projects or Internships (Fresher enter NA)',
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'This field is required';
              if (isFresher && val.trim().toUpperCase() != 'NA') {
                return 'Fresher must enter NA';
              }
              return null;
            },
            onSaved: (val) => _internshipDetails = val,
          ),
          const SizedBox(height: 16),
          const Text(
            'Have you completed any Certification?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Yes'),
                  value: 'Yes',
                  groupValue: _certification,
                  onChanged: (val) => setState(() {
                    _certification = val;
                  }),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('No'),
                  value: 'No',
                  groupValue: _certification,
                  onChanged: (val) => setState(() {
                    _certification = val;
                  }),
                ),
              ),
            ],
          ),
          if (_certification == null)
            const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(
                '* Please select an option',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
