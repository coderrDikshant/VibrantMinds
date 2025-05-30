import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({this.decimalRange = 2}) : assert(decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Allow empty string
    if (text.isEmpty) return newValue;

    // Reject negative values
    if (text.contains('-')) return oldValue;

    // Allow numbers with or without decimal up to specified decimal places
    final regExp = RegExp(r'^\d*\.?\d{0,' + decimalRange.toString() + r'}$');

    if (regExp.hasMatch(text)) {
      return newValue;
    } else {
      return oldValue;
    }
  }
}


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
  String? _graduationYear = 'Not Applicable';
  String? _graduationDegree = 'Not Applicable';
  String? _graduationCollege = 'Not Applicable';
  String? _graduationSpecialization = 'Not Applicable';
  String? _graduationPercentage = 'Not Applicable';
  String? _postGraduationYear = 'Not Applicable';
  String? _postGraduationDegree = 'Not Applicable';
  String? _postGraduationCollege = 'Not Applicable';
  String? _postGraduationSpecialization = 'Not Applicable';
  String? _postGraduationPercentage = 'Not Applicable';
  String? _diplomaYear = 'Not Applicable';
  String? _diplomaDegree = 'Not Applicable';
  String? _diplomaCollege = 'Not Applicable';
  String? _diplomaSpecialization = 'Not Applicable';
  String? _diplomaPercentage = 'Not Applicable';
  String? _tenthPercentage;
  String? _twelfthPercentage;
  String? _hasBacklog = 'No';
String? _hasEducationalGap = 'No';




  bool _completedGraduation = false;
  bool _completedPostGraduation = false;
  bool _completedDiploma = false;

  List<String> _tenthYearOptions = [];
  List<String> _twelfthYearOptions = [];
  List<String> _graduationYearOptions = ['Not Applicable'];
  List<String> _postGraduationYearOptions = ['Not Applicable'];
  List<String> _diplomaYearOptions = ['Not Applicable'];
  
  // Degree options
  List<String> _graduationDegreeOptions = ['Not Applicable'];
  List<String> _postGraduationDegreeOptions = ['Not Applicable'];
  List<String> _diplomaDegreeOptions = ['Not Applicable'];
  
  // Specialization options
  List<String> _graduationSpecializationOptions = ['Not Applicable'];
  List<String> _postGraduationSpecializationOptions = ['Not Applicable'];
  List<String> _diplomaSpecializationOptions = ['Not Applicable'];
  List<String> _yesNoOptions = ['Yes', 'No'];
  
  bool _isLoading = true;

  final TextEditingController _tenthPercentageController = TextEditingController();
  final TextEditingController _twelfthPercentageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchYearOptions();
    fetchCourseOptions();
    fetchSpecializationOptions();
  }

  Future<void> fetchYearOptions() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('YearOptions')
          .doc('PassingYears')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();

        final List<dynamic> tenthYears = data?['year10'] ?? [];
        final List<dynamic> twelfthYears = data?['year12'] ?? [];
        final List<dynamic> graduationYears = data?['graduationYear'] ?? [];
        final List<dynamic> postGraduationYears = data?['postGraduationYear'] ?? [];
        final List<dynamic> diplomaYears = data?['diplomaYear'] ?? [];

        setState(() {
          _tenthYearOptions = tenthYears.map((y) => y.toString()).toList()..sort();
          _twelfthYearOptions = twelfthYears.map((y) => y.toString()).toList()..sort();
          _graduationYearOptions = ['Not Applicable']..addAll(graduationYears.map((y) => y.toString()).toList()..sort());
          _postGraduationYearOptions = ['Not Applicable']..addAll(postGraduationYears.map((y) => y.toString()).toList()..sort());
          _diplomaYearOptions = ['Not Applicable']..addAll(diplomaYears.map((y) => y.toString()).toList()..sort());
        });
      } else {
        print('Year options document does not exist');
      }
    } catch (e, stackTrace) {
      print('Error fetching years: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> fetchCourseOptions() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('CourseOptions')
          .doc('Degrees')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();

        final List<dynamic> graduationDegrees = data?['graduationDegrees'] ?? [];
        final List<dynamic> postGraduationDegrees = data?['postGraduationDegrees'] ?? [];
        final List<dynamic> diplomaDegrees = data?['diplomaDegrees'] ?? [];

        setState(() {
          _graduationDegreeOptions = ['Not Applicable']..addAll(graduationDegrees.map((d) => d.toString()).toList());
          _postGraduationDegreeOptions = ['Not Applicable']..addAll(postGraduationDegrees.map((d) => d.toString()).toList());
          _diplomaDegreeOptions = ['Not Applicable']..addAll(diplomaDegrees.map((d) => d.toString()).toList());
        });
      } else {
        print('Degree options document does not exist');
      }
    } catch (e, stackTrace) {
      print('Error fetching degree options: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> fetchSpecializationOptions() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('CourseOptions')
          .doc('Specializations')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();

        final List<dynamic> graduationSpecializations = data?['graduationSpecializations'] ?? [];
        final List<dynamic> postGraduationSpecializations = data?['postGraduationSpecializations'] ?? [];
        final List<dynamic> diplomaSpecializations = data?['diplomaSpecializations'] ?? [];

        setState(() {
          _graduationSpecializationOptions = ['Not Applicable']..addAll(graduationSpecializations.map((s) => s.toString()).toList());
          _postGraduationSpecializationOptions = ['Not Applicable']..addAll(postGraduationSpecializations.map((s) => s.toString()).toList());
          _diplomaSpecializationOptions = ['Not Applicable']..addAll(diplomaSpecializations.map((s) => s.toString()).toList());
          _isLoading = false;
        });
      } else {
        print('Specialization options document does not exist');
        setState(() => _isLoading = false);
      }
    } catch (e, stackTrace) {
      print('Error fetching specialization options: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  String? validatePercentage(String? val) {
    if (val == null || val.isEmpty) {
      return 'Percentage is required';
    }
    if (val == 'Not Applicable') return null;
    
    final number = double.tryParse(val);
    if (number == null) {
      return 'Invalid number';
    }
    if (number < 0 || number > 100) {
      return 'Percentage must be between 0 and 100';
    }
    return null;
  }

  void save() {
    if (_localFormKey.currentState?.validate() ?? false) {
      _localFormKey.currentState?.save();
      widget.onSaved({
        'education': [
          {
            'tenthPassingYear': _tenthYear,
            'tenthPercentage': _tenthPercentage,
            'twelfthPassingYear': _twelfthYear,
            'twelfthPercentage': _twelfthPercentage,
            'diplomaCompleted': _completedDiploma,
            'diplomaYear': _completedDiploma ? _diplomaYear : 'Not Applicable',
            'diplomaDegree': _completedDiploma ? _diplomaDegree : 'Not Applicable',
            'diplomaCollege': _completedDiploma ? _diplomaCollege : 'Not Applicable',
            'diplomaSpecialization': _completedDiploma ? _diplomaSpecialization : 'Not Applicable',
            'diplomaPercentage': _completedDiploma ? _diplomaPercentage : 'Not Applicable',
            'graduationCompleted': _completedGraduation,
            'graduationYear': _completedGraduation ? _graduationYear : 'Not Applicable',
            'graduationDegree': _completedGraduation ? _graduationDegree : 'Not Applicable',
            'graduationCollege': _completedGraduation ? _graduationCollege : 'Not Applicable',
            'graduationSpecialization': _completedGraduation ? _graduationSpecialization : 'Not Applicable',
            'graduationPercentage': _completedGraduation ? _graduationPercentage : 'Not Applicable',
            'postGraduationCompleted': _completedPostGraduation,
            'postGraduationYear': _completedPostGraduation ? _postGraduationYear : 'Not Applicable',
            'postGraduationDegree': _completedPostGraduation ? _postGraduationDegree : 'Not Applicable',
            'postGraduationCollege': _completedPostGraduation ? _postGraduationCollege : 'Not Applicable',
            'postGraduationSpecialization': _completedPostGraduation ? _postGraduationSpecialization : 'Not Applicable',
            'postGraduationPercentage': _completedPostGraduation ? _postGraduationPercentage : 'Not Applicable',
            'hasBacklog': _hasBacklog,
            'hasEducationalGap': _hasEducationalGap,

          }
        ]
      });
    }
  }

  @override
  void dispose() {
    _tenthPercentageController.dispose();
    _twelfthPercentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _localFormKey,
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _isLoading ? const Center(child: CircularProgressIndicator()) : Column(
            children: [
              // 10th Section
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: '10th Passing Year'),
                items: _tenthYearOptions.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                validator: (val) => val == null ? '10th passing year is required' : null,
                onChanged: (val) => setState(() => _tenthYear = val),
                onSaved: (val) => _tenthYear = val,
              ),
              TextFormField(
                controller: _tenthPercentageController,
                decoration: const InputDecoration(labelText: '10th Percentage'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                 
                  DecimalTextInputFormatter(decimalRange: 2),
                ],
                validator: validatePercentage,
                onSaved: (val) => _tenthPercentage = val?.trim(),
              ),
              
              // 12th Section
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: '12th Passing Year'),
                items: _twelfthYearOptions.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                validator: (val) => val == null ? '12th passing year is required' : null,
                onChanged: (val) => setState(() => _twelfthYear = val),
                onSaved: (val) => _twelfthYear = val,
              ),
              TextFormField(
                controller: _twelfthPercentageController,
                decoration: const InputDecoration(labelText: '12th Percentage'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  
                  DecimalTextInputFormatter(decimalRange: 2),
                ],
                validator: validatePercentage,
                onSaved: (val) => _twelfthPercentage = val?.trim(),
              ),
              
              // Diploma Section
              CheckboxListTile(
                title: const Text('Did you complete Diploma?'),
                value: _completedDiploma,
                onChanged: (val) {
                  setState(() {
                    _completedDiploma = val ?? false;
                    if (!_completedDiploma) {
                      _diplomaYear = 'Not Applicable';
                      _diplomaDegree = 'Not Applicable';
                      _diplomaCollege = 'Not Applicable';
                      _diplomaSpecialization = 'Not Applicable';
                      _diplomaPercentage = 'Not Applicable';
                    }
                  });
                },
              ),
              if (_completedDiploma) ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Diploma Passing Year'),
                  items: _diplomaYearOptions.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                  onChanged: (val) => setState(() => _diplomaYear = val),
                  onSaved: (val) => _diplomaYear = val,
                  value: _diplomaYear,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Diploma Degree'),
                  items: _diplomaDegreeOptions.map((degree) => DropdownMenuItem(value: degree, child: Text(degree))).toList(),
                  onChanged: (val) => setState(() => _diplomaDegree = val),
                  onSaved: (val) => _diplomaDegree = val,
                  value: _diplomaDegree,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Diploma College'),
                  onSaved: (val) => _diplomaCollege = val,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Diploma Specialization'),
                  items: _diplomaSpecializationOptions.map((spec) => DropdownMenuItem(value: spec, child: Text(spec))).toList(),
                  onChanged: (val) => setState(() => _diplomaSpecialization = val),
                  onSaved: (val) => _diplomaSpecialization = val,
                  value: _diplomaSpecialization,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Diploma Percentage'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    
                    DecimalTextInputFormatter(decimalRange: 2),
                  ],
                  validator: validatePercentage,
                  onSaved: (val) => _diplomaPercentage = val?.trim(),
                ),
              ],
              
              // Graduation Section
              CheckboxListTile(
                title: const Text('Did you complete Graduation?'),
                value: _completedGraduation,
                onChanged: (val) {
                  setState(() {
                    _completedGraduation = val ?? false;
                    if (!_completedGraduation) {
                      _graduationYear = 'Not Applicable';
                      _graduationDegree = 'Not Applicable';
                      _graduationCollege = 'Not Applicable';
                      _graduationSpecialization = 'Not Applicable';
                      _graduationPercentage = 'Not Applicable';
                    }
                  });
                },
              ),
              if (_completedGraduation) ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Graduation Passing Year'),
                  items: _graduationYearOptions.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                  onChanged: (val) => setState(() => _graduationYear = val),
                  onSaved: (val) => _graduationYear = val,
                  value: _graduationYear,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Graduation Degree'),
                  items: _graduationDegreeOptions.map((degree) => DropdownMenuItem(value: degree, child: Text(degree))).toList(),
                  onChanged: (val) => setState(() => _graduationDegree = val),
                  onSaved: (val) => _graduationDegree = val,
                  value: _graduationDegree,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Graduation College'),
                  onSaved: (val) => _graduationCollege = val,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Graduation Specialization'),
                  items: _graduationSpecializationOptions.map((spec) => DropdownMenuItem(value: spec, child: Text(spec))).toList(),
                  onChanged: (val) => setState(() => _graduationSpecialization = val),
                  onSaved: (val) => _graduationSpecialization = val,
                  value: _graduationSpecialization,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Graduation Percentage'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                  
                    DecimalTextInputFormatter(decimalRange: 2),
                  ],
                  validator: validatePercentage,
                  onSaved: (val) => _graduationPercentage = val?.trim(),
                ),
              ],
              
              // Post Graduation Section
              CheckboxListTile(
                title: const Text('Did you complete Post Graduation?'),
                value: _completedPostGraduation,
                onChanged: (val) {
                  setState(() {
                    _completedPostGraduation = val ?? false;
                    if (!_completedPostGraduation) {
                      _postGraduationYear = 'Not Applicable';
                      _postGraduationDegree = 'Not Applicable';
                      _postGraduationCollege = 'Not Applicable';
                      _postGraduationSpecialization = 'Not Applicable';
                      _postGraduationPercentage = 'Not Applicable';
                    }
                  });
                },
              ),
              if (_completedPostGraduation) ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Post Graduation Passing Year'),
                  items: _postGraduationYearOptions.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                  onChanged: (val) => setState(() => _postGraduationYear = val),
                  onSaved: (val) => _postGraduationYear = val,
                  value: _postGraduationYear,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Post Graduation Degree'),
                  items: _postGraduationDegreeOptions.map((degree) => DropdownMenuItem(value: degree, child: Text(degree))).toList(),
                  onChanged: (val) => setState(() => _postGraduationDegree = val),
                  onSaved: (val) => _postGraduationDegree = val,
                  value: _postGraduationDegree,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Post Graduation College'),
                  onSaved: (val) => _postGraduationCollege = val,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Post Graduation Specialization'),
                  items: _postGraduationSpecializationOptions.map((spec) => DropdownMenuItem(value: spec, child: Text(spec))).toList(),
                  onChanged: (val) => setState(() => _postGraduationSpecialization = val),
                  onSaved: (val) => _postGraduationSpecialization = val,
                  value: _postGraduationSpecialization,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Post Graduation Percentage'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                  
                    DecimalTextInputFormatter(decimalRange: 2),
                  ],
                  validator: validatePercentage,
                  onSaved: (val) => _postGraduationPercentage = val?.trim(),
                ),


 


              ],
 const SizedBox(height: 16),

// Backlog Section
Row(
  children: [
    const Text("Do you have any backlog?"),
    const Spacer(),
    DropdownButton<String>(
      value: _hasBacklog,
      items: _yesNoOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _hasBacklog = newValue;
        });
      },
    ),
  ],
),

const SizedBox(height: 16),

// Educational Gap Section
Row(
  children: [
    const Text("Do you have any educational gap?"),
    const Spacer(),
    DropdownButton<String>(
      value: _hasEducationalGap,
      items: _yesNoOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _hasEducationalGap = newValue;
        });
      },
    ),
  ],
),

            ],
          ),
        ],
      ),
    );
  }
}