import 'package:flutter/material.dart';

class ExperienceSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onSaved;
    final Map<String, dynamic>? initialData;

   const ExperienceSection({
    Key? key,
    required this.onSaved,
    this.initialData,
  }) : super(key: key);

  
  @override
  ExperienceSectionState createState() => ExperienceSectionState();
}

class ExperienceSectionState extends State<ExperienceSection> {
  final _localFormKey = GlobalKey<FormState>();

  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _yearsController = TextEditingController();
  final _ctcController = TextEditingController();
  final _internshipController = TextEditingController();
  final _previousCompanyController = TextEditingController();

  String? _experienceLevel;
  String? _certification;

  final List<String> _experienceOptions = [
    'Fresher',
    '0–3 months',
    '3–6 months',
    '6 months – 1 year',
    'More than 1 year',
  ];

  void _autoFillFresherFields(bool isFresher) {
    if (isFresher) {
      _companyController.text = 'NA';
      _previousCompanyController.text = 'NA';
      _yearsController.text = '0';
      _ctcController.text = 'NA';
    } else {
      _companyController.clear();
      _previousCompanyController.clear();
      _yearsController.clear();
      _ctcController.clear();
    }
  }

  void save() {
    if (_localFormKey.currentState?.validate() ?? false) {
      _localFormKey.currentState?.save();
      widget.onSaved({
        'experience': [
          {
            'experienceLevel': _experienceLevel,
            'company': _companyController.text.trim(),
            'role': _roleController.text.trim(),
            'years': _yearsController.text.trim(),
            'previousCompany': _previousCompanyController.text.trim(),
            'lastCTC': _ctcController.text.trim(),
            'internshipDetails': _internshipController.text.trim(),
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
      validator: (val) => val == null ? 'Please select an experience level' : null,
      onChanged: (val) {
        setState(() {
          _experienceLevel = val;
          _autoFillFresherFields(isFresher);
        });
      },
      onSaved: (val) => _experienceLevel = val,
    ),
    const SizedBox(height: 12),
    TextFormField(
    controller: _companyController,
    decoration: const InputDecoration(labelText: 'Company'),
    validator: (val) {
    if (isFresher && val?.trim().toUpperCase() != 'NA') {
    return 'Fresher must have NA for company';
    }
    if (!isFresher) {
    if (val == null || val.trim().isEmpty) return 'Company is required';
    if (val.trim().length < 2) return 'Minimum 2 characters required';
    if (!RegExp(r'^[a-zA-Z0-9\s\-\.]+$').hasMatch(val.trim())) {
    return 'Only letters, numbers, spaces, hyphens, or periods allowed';
    }
    }
    return null;
    },
    ),
    const SizedBox(height: 12),
    TextFormField(
    controller: _roleController,
    decoration: const InputDecoration(labelText: 'Role'),
    validator: (val) {
    if (val == null || val.trim().isEmpty) return 'Role is required';
    if (val.trim().length < 3) return 'Minimum 3 characters required';
    if (!RegExp(r'^[a-zA-Z0-9\s\-\.]+$').hasMatch(val.trim())) {
    return 'Only letters, numbers, spaces, hyphens, or periods allowed';
    }
    return null;
    },
    ),
    const SizedBox(height: 12),
    TextFormField(
    controller: _yearsController,
    decoration: const InputDecoration(labelText: 'Years of Experience'),
    keyboardType: TextInputType.number,
    validator: (val) {
    if (val == null || val.trim().isEmpty) return 'Years of experience is required';
    final numValue = double.tryParse(val.trim());
    if (numValue == null) return 'Enter a valid number';
    if (isFresher && numValue != 0) return 'Fresher must enter 0 for years';

    if (!isFresher) {
    if (_experienceLevel == '0–3 months' && (numValue < 0 || numValue > 0.25)) {
    return 'Must be between 0 and 0.25';
    }
    if (_experienceLevel == '3–6 months' && (numValue < 0.25 || numValue > 0.5)) {
    return 'Must be between 0.25 and 0.5';
    }
    if (_experienceLevel == '6 months – 1 year' && (numValue < 0.5 || numValue > 1)) {
    return 'Must be between 0.5 and 1';
    }
    if (_experienceLevel == 'More than 1 year' && numValue <= 1) {
    return 'Must be greater than 1';
    }
    }
    return null;
    },
    ),
    const SizedBox(height: 12),
    TextFormField(
    controller: _previousCompanyController,
    decoration: const InputDecoration(labelText: 'Previous Company'),
    validator: (val) {
    if (isFresher && val?.trim().toUpperCase() != 'NA') {
    return 'Fresher must have NA for previous company';
    }
    if (!isFresher) {
    if (val == null || val.trim().isEmpty) return 'Previous company is required';
    if (val.trim().length < 2) return 'Minimum 2 characters required';
    if (!RegExp(r'^[a-zA-Z0-9\s\-\.]+$').hasMatch(val.trim())) {
    return 'Only letters, numbers, spaces, hyphens, or periods allowed';
    }
    }
    return null;
    },
    ),
    const SizedBox(height: 12),
    TextFormField(
    controller: _ctcController,
    decoration: const InputDecoration(labelText: 'Last CTC (Per Annum)'),
    validator: (val) {
    if (val == null || val.trim().isEmpty) return 'CTC is required';
    if (isFresher && val.trim().toUpperCase() != 'NA') {
    return 'Fresher must enter NA';
    }
    if (!isFresher) {
    final cleaned = val.trim().replaceAll(RegExp(r'[^\d.]'), '');
    final numValue = double.tryParse(cleaned);
    if (numValue == null && cleaned.isNotEmpty) return 'Enter valid number or 0';
    if (numValue != null && numValue < 0) return 'CTC cannot be negative';
    }
    return null;
    },
    ),
    const SizedBox(height: 12),
    TextFormField(
    controller: _internshipController,
    decoration: const InputDecoration(
    labelText: 'Live Projects or Internships (Fresher enter NA)',
    ),
    validator: (val) {
    if (val == null || val.trim().isEmpty) return 'This field is required';
    if (isFresher && val.trim().toUpperCase() != 'NA') {
    return 'Fresher must enter NA';
    }
    if (!isFresher) {
    if (val.trim().length < 5) {
    return 'Minimum 5 characters required';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s\-\.,]+$').hasMatch(val.trim())) {
    return 'Only letters, numbers, spaces, hyphens, periods, or commas allowed';
    }
    }
    return null;
    },
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

            // Hidden validator for certification
            TextFormField(
              controller: TextEditingController(text: _certification),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                constraints: BoxConstraints(maxHeight: 0),
              ),
              validator: (val) {
                if (_certification == null) {
                  return 'Please select Yes or No for certification';
                }
                return null;
              },
              onSaved: (val) => null, // already handled via _certification
            ),

            const SizedBox(height: 20),

            // Submit button (Optional: remove if saving is triggered externally)
            ElevatedButton(
              onPressed: save,
              child: const Text('Save Experience'),
            ),
          ],
      ),
    );
  }
}

