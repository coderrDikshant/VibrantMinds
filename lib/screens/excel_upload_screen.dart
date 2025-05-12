import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../services/excel_parser.dart';
import '../services/firestore_service.dart';

class ExcelUploadScreen extends StatefulWidget {
  const ExcelUploadScreen({super.key});

  @override
  _ExcelUploadScreenState createState() => _ExcelUploadScreenState();
}

class _ExcelUploadScreenState extends State<ExcelUploadScreen> {
  bool _isUploading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _uploadExcel() async {
    setState(() {
      _isUploading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final questions = await ExcelParser.parseExcelFile();
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);

      for (var question in questions) {
        await firestoreService.uploadQuestion(question);
      }

      setState(() {
        _successMessage = 'Successfully uploaded ${questions.length} questions';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Questions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Excel Sheet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Expected Excel format:\n'
                  'Columns: category, question, option1, option2, option3, option4, '
                  'correctAnswer, explanation, set, difficulty',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadExcel,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text('Select and Upload Excel'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (_successMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _successMessage!,
                style: const TextStyle(color: Colors.green),
              ),
            ],
          ],
        ),
      ),
    );
  }
}