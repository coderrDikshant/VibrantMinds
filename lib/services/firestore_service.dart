import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/question.dart';
import '../models/quiz.dart';
import '../models/user_stats.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .get();
      return snapshot.docs
          .map((doc) => Category.fromFirestore(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.code} - ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<Quiz>> getQuizzes(
      String categoryId, String difficultyId, String difficulty) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .collection(AppConstants.difficultyCollection)
          .doc(difficultyId)
          .collection(AppConstants.quizzesCollection)
          .where('difficulty', isEqualTo: difficulty)
          .get();

      return snapshot.docs
          .map((doc) => Quiz.fromFirestore(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.code} - ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<Question>> getQuestions(
      String categoryId, String difficultyId, String quizId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .collection(AppConstants.difficultyCollection)
          .doc(difficultyId)
          .collection(AppConstants.quizzesCollection)
          .doc(quizId)
          .collection(AppConstants.questionsCollection)
          .get();

      return snapshot.docs
          .map((doc) => Question.fromFirestore(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.code} - ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> saveUserStats(UserStats stats) async {
    try {
      await _firestore
          .collection(AppConstants.userStatsCollection)
          .doc(stats.userId)
          .collection(AppConstants.quizAttemptsCollection)
          .add(stats.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.code} - ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
