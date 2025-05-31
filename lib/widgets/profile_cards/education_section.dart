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
    if (text.isEmpty) return newValue;
    if (text.contains('-')) return oldValue;
    final regExp = RegExp(r'^\d*\.?\d{0,' + decimalRange.toString() + r'}$');
    return regExp.hasMatch(text) ? newValue : oldValue;
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
  List<String> _graduationDegreeOptions = ['Not Applicable'];
  List<String> _postGraduationDegreeOptions = ['Not Applicable'];
  List<String> _diplomaDegreeOptions = ['Not Applicable'];
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
        setState(() {
          _tenthYearOptions = (data?['year10'] ?? []).map((y) => y.toString()).toList()..sort();
          _twelfthYearOptions = (data?['year12'] ?? []).map((y) => y.toString()).toList()..sort();
          _graduationYearOptions = ['Not Applicable']..addAll((data?['graduationYear'] ?? []).map((y) => y.toString()).toList()..sort());
          _postGraduationYearOptions = ['Not Applicable']..addAll((data?['postGraduationYear'] ?? []).map((y) => y.toString()).toList()..sort());
          _diplomaYearOptions = ['Not Applicable']..addAll((data?['diplomaYear'] ?? []).map((y) => y.toString()).toList()..sort());
        });
      }
    } catch (e, stackTrace) {
      print('Error fetching years: $e\nStack trace: $stackTrace');
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
        setState(() {
          _graduationDegreeOptions = ['Not Applicable']..addAll((data?['graduationDegrees'] ?? []).map((d) => d.toString()).toList());
          _postGraduationDegreeOptions = ['Not Applicable']..addAll((data?['postGraduationDegrees'] ?? []).map((d) => d.toString()).toList());
          _diplomaDegreeOptions = ['Not Applicable']..addAll((data?['diplomaDegrees'] ?? []).map((d) => d.toString()).toList());
        });
      }
    } catch (e, stackTrace) {
      print('Error fetching degree options: $e\nStack trace: $stackTrace');
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
        setState(() {
          _graduationSpecializationOptions = ['Not Applicable']..addAll((data?['graduationSpecializations'] ?? []).map((s) => s.toString()).toList());
          _postGraduationSpecializationOptions = ['Not Applicable']..addAll((data?['postGraduationSpecializations'] ?? []).map((s) => s.toString()).toList());
          _diplomaSpecializationOptions = ['Not Applicable']..addAll((data?['diplomaSpecializations'] ?? []).map((s) => s.toString()).toList());
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e, stackTrace) {
      print('Error fetching specialization options: $e\nStack trace: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  String? validatePercentage(String? val) {
    if (val == null || val.isEmpty) return 'Percentage is required';
    if (val == 'Not Applicable') return null;
    final number = double.tryParse(val);
    if (number == null) return 'Invalid number';
    if (number < 0 || number > 100) return 'Percentage must be between 0 and 100';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Education details saved successfully!'),
          backgroundColor: Colors.orange[700],
        ),
      );
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
    return Theme(
      data: ThemeData(
        primaryColor: Colors.orange[700],
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.orange,
          accentColor: Colors.orangeAccent,
          backgroundColor: Colors.grey[100],
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange[700]!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[700]!),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[700]!, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.orange[900]),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: 16),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      child: Stack(
        children: [
          Form(
            key: _localFormKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 10th Section
                _buildSectionTile(
                  title: '10th Grade Details',
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: '10th Passing Year',
                        prefixIcon: Icon(Icons.calendar_today, color: Colors.orange[700]),
                      ),
                      items: _tenthYearOptions.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                      validator: (val) => val == null ? '10th passing year is required' : null,
                      onChanged: (val) => setState(() => _tenthYear = val),
                      onSaved: (val) => _tenthYear = val,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tenthPercentageController,
                      decoration: InputDecoration(
                        labelText: '10th Percentage',
                        prefixIcon: Icon(Icons.percent, color: Colors.orange[700]),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                      validator: validatePercentage,
                      onSaved: (val) => _tenthPercentage = val?.trim(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 12th Section
                _buildSectionTile(
                  title: '12th Grade Details',
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: '12th Passing Year',
                        prefixIcon: Icon(Icons.calendar_today, color: Colors.orange[700]),
                      ),
                      items: _twelfthYearOptions.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                      validator: (val) => val == null ? '12th passing year is required' : null,
                      onChanged: (val) => setState(() => _twelfthYear = val),
                      onSaved: (val) => _twelfthYear = val,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _twelfthPercentageController,
                      decoration: InputDecoration(
                        labelText: '12th Percentage',
                        prefixIcon: Icon(Icons.percent, color: Colors.orange[700]),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                      validator: validatePercentage,
                      onSaved: (val) => _twelfthPercentage = val?.trim(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Diploma Section
                _buildSectionTile(
                  title: 'Diploma Details',
                  leading: CheckboxListTile(
                    title: const Text('Completed Diploma?'),
                    value: _completedDiploma,
                    onChanged: (val) {
                      setState(() {
                        _completedDiploma = val ?? false;
                        if (!_completedDiploma) {
                          _diplomaYear = _diplomaDegree = _diplomaCollege = _diplomaSpecialization = _diplomaPercentage = 'Not Applicable';
                        }
                      });
                    },
                    activeColor: Colors.orange[700],
                  ),
                  children: _completedDiploma
                      ? [
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Diploma Passing Year',
                              prefixIcon: Icon(Icons.calendar_today, color: Colors.orange[700]),
                            ),
                            items: _diplomaYearOptions.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                            onChanged: (val) => setState(() => _diplomaYear = val),
                            onSaved: (val) => _diplomaYear = val,
                            value: _diplomaYear,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Diploma Degree',
                              prefixIcon: Icon(Icons.school, color: Colors.orange[700]),
                            ),
                            items: _diplomaDegreeOptions.map((degree) => DropdownMenuItem(value: degree, child: Text(degree))).toList(),
                            onChanged: (val) => setState(() => _diplomaDegree = val),
                            onSaved: (val) => _diplomaDegree = val,
                            value: _diplomaDegree,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Diploma College',
                              prefixIcon: Icon(Icons.apartment, color: Colors.orange[700]),
                            ),
                            onSaved: (val) => _diplomaCollege = val,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Diploma Specialization',
                              prefixIcon: Icon(Icons.book, color: Colors.orange[700]),
                            ),
                            items: _diplomaSpecializationOptions.map((spec) => DropdownMenuItem(value: spec, child: Text(spec))).toList(),
                            onChanged: (val) => setState(() => _diplomaSpecialization = val),
                            onSaved: (val) => _diplomaSpecialization = val,
                            value: _diplomaSpecialization,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Diploma Percentage',
                              prefixIcon: Icon(Icons.percent, color: Colors.orange[700]),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                            validator: validatePercentage,
                            onSaved: (val) => _diplomaPercentage = val?.trim(),
                          ),
                        ]
                      : [],
                ),
                const SizedBox(height: 16),

                // Graduation Section
                _buildSectionTile(
                  title: 'Graduation Details',
                  leading: CheckboxListTile(
                    title: const Text('Completed Graduation?'),
                    value: _completedGraduation,
                    onChanged: (val) {
                      setState(() {
                        _completedGraduation = val ?? false;
                        if (!_completedGraduation) {
                          _graduationYear = _graduationDegree = _graduationCollege = _graduationSpecialization = _graduationPercentage = 'Not Applicable';
                        }
                      });
                    },
                    activeColor: Colors.orange[700],
                  ),
                  children: _completedGraduation
                      ? [
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Graduation Passing Year',
                              prefixIcon: Icon(Icons.calendar_today, color: Colors.orange[700]),
                            ),
                            items: _graduationYearOptions.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                            onChanged: (val) => setState(() => _graduationYear = val),
                            onSaved: (val) => _graduationYear = val,
                            value: _graduationYear,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Graduation Degree',
                              prefixIcon: Icon(Icons.school, color: Colors.orange[700]),
                            ),
                            items: _graduationDegreeOptions.map((degree) => DropdownMenuItem(value: degree, child: Text(degree))).toList(),
                            onChanged: (val) => setState(() => _graduationDegree = val),
                            onSaved: (val) => _graduationDegree = val,
                            value: _graduationDegree,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Graduation College',
                              prefixIcon: Icon(Icons.apartment, color: Colors.orange[700]),
                            ),
                            onSaved: (val) => _graduationCollege = val,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Graduation Specialization',
                              prefixIcon: Icon(Icons.book, color: Colors.orange[700]),
                            ),
                            items: _graduationSpecializationOptions.map((spec) => DropdownMenuItem(value: spec, child: Text(spec))).toList(),
                            onChanged: (val) => setState(() => _graduationSpecialization = val),
                            onSaved: (val) => _graduationSpecialization = val,
                            value: _graduationSpecialization,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Graduation Percentage',
                              prefixIcon: Icon(Icons.percent, color: Colors.orange[700]),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                            validator: validatePercentage,
                            onSaved: (val) => _graduationPercentage = val?.trim(),
                          ),
                        ]
                      : [],
                ),
                const SizedBox(height: 16),

                // Post Graduation Section
                _buildSectionTile(
                  title: 'Post Graduation Details',
                  leading: CheckboxListTile(
                    title: const Text('Completed Post Graduation?'),
                    value: _completedPostGraduation,
                    onChanged: (val) {
                      setState(() {
                        _completedPostGraduation = val ?? false;
                        if (!_completedPostGraduation) {
                          _postGraduationYear = _postGraduationDegree = _postGraduationCollege = _postGraduationSpecialization = _postGraduationPercentage = 'Not Applicable';
                        }
                      });
                    },
                    activeColor: Colors.orange[700],
                  ),
                  children: _completedPostGraduation
                      ? [
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Post Graduation Passing Year',
                              prefixIcon: Icon(Icons.calendar_today, color: Colors.orange[700]),
                            ),
                            items: _postGraduationYearOptions.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                            onChanged: (val) => setState(() => _postGraduationYear = val),
                            onSaved: (val) => _postGraduationYear = val,
                            value: _postGraduationYear,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Post Graduation Degree',
                              prefixIcon: Icon(Icons.school, color: Colors.orange[700]),
                            ),
                            items: _postGraduationDegreeOptions.map((degree) => DropdownMenuItem(value: degree, child: Text(degree))).toList(),
                            onChanged: (val) => setState(() => _postGraduationDegree = val),
                            onSaved: (val) => _postGraduationDegree = val,
                            value: _postGraduationDegree,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Post Graduation College',
                              prefixIcon: Icon(Icons.apartment, color: Colors.orange[700]),
                            ),
                            onSaved: (val) => _postGraduationCollege = val,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Post Graduation Specialization',
                              prefixIcon: Icon(Icons.book, color: Colors.orange[700]),
                            ),
                            items: _postGraduationSpecializationOptions.map((spec) => DropdownMenuItem(value: spec, child: Text(spec))).toList(),
                            onChanged: (val) => setState(() => _postGraduationSpecialization = val),
                            onSaved: (val) => _postGraduationSpecialization = val,
                            value: _postGraduationSpecialization,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Post Graduation Percentage',
                              prefixIcon: Icon(Icons.percent, color: Colors.orange[700]),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                            validator: validatePercentage,
                            onSaved: (val) => _postGraduationPercentage = val?.trim(),
                          ),
                        ]
                      : [],
                ),
                const SizedBox(height: 16),

                // Backlog and Educational Gap
                _buildSectionTile(
                  title: 'Additional Information',
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Any Backlog?', style: TextStyle(fontSize: 16)),
                        DropdownButton<String>(
                          value: _hasBacklog,
                          items: _yesNoOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) => setState(() => _hasBacklog = newValue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Any Educational Gap?', style: TextStyle(fontSize: 16)),
                        DropdownButton<String>(
                          value: _hasEducationalGap,
                          items: _yesNoOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) => setState(() => _hasEducationalGap = newValue),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: save,
                  child: const Text('Save Education Details'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTile({
    required String title,
    Widget? leading,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[900]),
        ),
        leading: leading,
        childrenPadding: const EdgeInsets.all(16),
        children: children,
      ),
    );
  }
}