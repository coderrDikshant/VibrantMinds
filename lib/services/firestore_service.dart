import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_models/category.dart';
import '../models/quiz_models/question.dart';
import '../models/quiz_models/quiz.dart';
import '../models/quiz_models/user_stats.dart';
import '../models/blog_models/blog.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  // Fetch categories
  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _firestore.collection(AppConstants.categoriesCollection).get();
      return snapshot.docs.map((doc) => Category.fromFirestore(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  // Fetch quizzes by category and difficulty
  Future<List<Quiz>> getQuizzes(String categoryId, String difficultyId, String difficulty) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .collection(AppConstants.difficultyCollection)
          .doc(difficultyId)
          .collection(AppConstants.quizzesCollection)
          .where('difficulty', isEqualTo: difficulty)
          .get();

      return snapshot.docs.map((doc) => Quiz.fromFirestore(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error fetching quizzes: $e");
      return [];
    }
  }

  // Fetch questions for a quiz
  Future<List<Question>> getQuestions(String categoryId, String difficultyId, String quizId) async {
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

      return snapshot.docs.map((doc) => Question.fromFirestore(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error fetching questions: $e");
      return [];
    }
  }

  // Save user quiz statistics
  Future<void> saveUserStats(UserStats stats) async {
    try {
      if (stats.userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }
      final userDocRef = _firestore.collection(AppConstants.userStatsCollection).doc(stats.userId);

      // Save basic user info (merged so we don't overwrite)
      await userDocRef.set({
        'name': stats.name,
        'email': stats.email,
      }, SetOptions(merge: true));

      // Remove name/email before saving quiz attempt (already saved above)
      final attemptData = Map<String, dynamic>.from(stats.toFirestore())
        ..remove('name')
        ..remove('email');

      await userDocRef
          .collection(AppConstants.quizAttemptsCollection)
          .add(attemptData);
    } catch (e) {
      print("Error saving user stats: $e");
      rethrow;
    }
  }

  // Fetch blogs
  Future<List<Blog>> getBlogs() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.blogsCollection)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Blog.fromFirestore(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error fetching blogs: $e");
      return [];
    }
  }

  // Increment like count
  Future<void> likeBlog(String blogId) async {
    try {
      final blogRef = _firestore.collection(AppConstants.blogsCollection).doc(blogId);
      await blogRef.update({'likes': FieldValue.increment(1)});
    } catch (e) {
      print("Error liking blog: $e");
    }
  }

  // Increment dislike count
  Future<void> dislikeBlog(String blogId) async {
    try {
      final blogRef = _firestore.collection(AppConstants.blogsCollection).doc(blogId);
      await blogRef.update({'dislikes': FieldValue.increment(1)});
    } catch (e) {
      print("Error disliking blog: $e");
    }
  }
}