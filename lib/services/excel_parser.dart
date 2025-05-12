import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/question.dart';

class ExcelParser {
  static Future<List<Question>> parseExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null || result.files.isEmpty) {
      throw Exception('No file selected');
    }

    final fileBytes = result.files.first.bytes;
    if (fileBytes == null) {
      throw Exception('Failed to read file');
    }

    final excel = Excel.decodeBytes(fileBytes);
    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) {
      throw Exception('No sheet found in Excel file');
    }

    List<Question> questions = [];
    // Skip header row
    for (var row in sheet.rows.skip(1)) {
      if (row.length < 10) continue; // Ensure all columns exist
      final category = row[0]?.value?.toString().toLowerCase() ?? '';
      final questionText = row[1]?.value?.toString() ?? '';
      final options = [
        row[2]?.value?.toString() ?? '',
        row[3]?.value?.toString() ?? '',
        row[4]?.value?.toString() ?? '',
        row[5]?.value?.toString() ?? '',
      ];
      final correctAnswer = row[6]?.value?.toString() ?? '';
      final explanation = row[7]?.value?.toString() ?? '';
      final set = row[8]?.value?.toString() ?? '';
      final difficulty = row[9]?.value?.toString().toLowerCase() ?? '';

      if (category.isNotEmpty &&
          questionText.isNotEmpty &&
          options.every((opt) => opt.isNotEmpty) &&
          correctAnswer.isNotEmpty &&
          set.isNotEmpty &&
          difficulty.isNotEmpty) {
        questions.add(Question(
          category: category,
          question: questionText,
          options: options,
          correctAnswer: correctAnswer,
          explanation: explanation,
          set: set,
          difficulty: difficulty,
        ));
      }
    }

    return questions;
  }
}