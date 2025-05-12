import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question.dart';
import '../models/user_stats.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  Future<void> uploadQuestion(Question question) async {
    try {
      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(question.category)
          .set({'name': question.category.toUpperCase()}, SetOptions(merge: true));

      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(question.category)
          .collection(AppConstants.quizzesCollection)
          .doc('quiz${question.set}')
          .set({
        'set': question.set,
        'difficulty': question.difficulty,
      }, SetOptions(merge: true));

      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(question.category)
          .collection(AppConstants.quizzesCollection)
          .doc('quiz${question.set}')
          .collection(AppConstants.questionsCollection)
          .add(question.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.code} - ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<UserStats>> getAllUserStats() async {
    try {
      final usersSnapshot =
      await _firestore.collection(AppConstants.userStatsCollection).get();
      List<UserStats> allStats = [];

      for (var userDoc in usersSnapshot.docs) {
        final attemptsSnapshot = await userDoc.reference
            .collection(AppConstants.quizAttemptsCollection)
            .get();
        allStats.addAll(attemptsSnapshot.docs
            .map((doc) => UserStats.fromFirestore(doc.data(), userDoc.id)));
      }

      return allStats;
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.code} - ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}