import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_models/category.dart';
import '../models/quiz_models/question.dart';
import '../models/quiz_models/quiz.dart';
import '../models/quiz_models/user_stats.dart';
import '../models/blog_models/blog.dart';
import '../models/success_story.dart';
import '../models/comment.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _firestore.collection(AppConstants.categoriesCollection).get();
      return snapshot.docs.map((doc) => Category.fromFirestore(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error fetching categories: $e");
      rethrow;
    }
  }

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
      rethrow;
    }
  }

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
      rethrow;
    }
  }

  Future<void> saveUserStats(UserStats stats) async {
    try {
      if (stats.userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }
      final userDocRef = _firestore.collection(AppConstants.userStatsCollection).doc(stats.userId);

      await userDocRef.set({
        'name': stats.name,
        'email': stats.email,
      }, SetOptions(merge: true));

      final attemptData = Map<String, dynamic>.from(stats.toFirestore())
        ..remove('name')
        ..remove('email');

      await userDocRef.collection(AppConstants.quizAttemptsCollection).add(attemptData);
    } catch (e) {
      print("Error saving user stats: $e");
      rethrow;
    }
  }

  Future<List<UserStats>> getUserStatsByEmail(String email) async {
    try {
      // First, find the user document by email
      final userSnapshot = await _firestore
          .collection(AppConstants.userStatsCollection)
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isEmpty) {
        return [];
      }

      // Assume the first matching user document (email should be unique)
      final userDoc = userSnapshot.docs.first;
      final userId = userDoc.id;
      final userData = userDoc.data();

      // Fetch all quiz attempts for the user
      final attemptsSnapshot = await _firestore
          .collection(AppConstants.userStatsCollection)
          .doc(userId)
          .collection(AppConstants.quizAttemptsCollection)
          .orderBy('timestamp', descending: true)
          .get();

      return attemptsSnapshot.docs.map((doc) {
        final attemptData = doc.data();
        // Merge user-level data (name, email) with attempt data
        return UserStats.fromFirestore({
          ...attemptData,
          'name': userData['name'],
          'email': userData['email'],
          'userId': userId,
          'id': doc.id, // Add attempt ID
        });
      }).toList();
    } catch (e) {
      print("Error fetching user stats by email: $e");
      rethrow;
    }
  }

  Future<List<Blog>> getBlogs(String userEmail) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.blogsCollection)
          .orderBy('timestamp', descending: true)
          .get();

      return await Future.wait(snapshot.docs.map((doc) async {
        final blog = Blog.fromFirestore(doc.data(), doc.id);
        final userInteraction = await _firestore
            .collection(AppConstants.blogsCollection)
            .doc(blog.id)
            .collection('interactions')
            .doc(userEmail)
            .get();

        if (userInteraction.exists) {
          blog.userLiked = userInteraction.data()?['liked'] ?? false;
        }

        final commentSnapshot = await _firestore
            .collection(AppConstants.blogsCollection)
            .doc(blog.id)
            .collection('comments')
            .get();
        blog.commentCount = commentSnapshot.docs.length;

        return blog;
      }).toList());
    } catch (e) {
      print("Error fetching blogs: $e");
      rethrow;
    }
  }

  Future<void> likeBlog(String blogId, String userEmail) async {
    try {
      final blogRef = _firestore.collection(AppConstants.blogsCollection).doc(blogId);
      final interactionRef = blogRef.collection('interactions').doc(userEmail);

      final snapshot = await interactionRef.get();
      final hasLiked = snapshot.exists && snapshot.data()?['liked'] == true;

      if (!hasLiked) {
        final batch = _firestore.batch();
        batch.update(blogRef, {
          'likes': FieldValue.increment(1),
        });
        batch.set(interactionRef, {'liked': true}, SetOptions(merge: true));
        await batch.commit();
      }
    } catch (e) {
      print("Error liking blog: $e");
      rethrow;
    }
  }

  Future<void> removeLike(String blogId, String userEmail) async {
    try {
      final blogRef = _firestore.collection(AppConstants.blogsCollection).doc(blogId);
      final interactionRef = blogRef.collection('interactions').doc(userEmail);

      final snapshot = await interactionRef.get();
      final hasLiked = snapshot.exists && snapshot.data()?['liked'] == true;

      if (hasLiked) {
        final batch = _firestore.batch();
        batch.update(blogRef, {
          'likes': FieldValue.increment(-1),
        });
        batch.set(interactionRef, {'liked': false}, SetOptions(merge: true));
        await batch.commit();
      }
    } catch (e) {
      print("Error removing like: $e");
      rethrow;
    }
  }

  Future<List<SuccessStory>> getSuccessStories(String userEmail) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.successStoriesCollection)
          .orderBy('timestamp', descending: true)
          .get();

      print("Fetched ${snapshot.docs.length} success stories from Firestore");

      return await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        print("Processing story ID: ${doc.id}, Data: $data");
        final story = SuccessStory.fromFirestore(data, doc.id);
        final userInteraction = await _firestore
            .collection(AppConstants.successStoriesCollection)
            .doc(story.id)
            .collection('interactions')
            .doc(userEmail)
            .get();

        if (userInteraction.exists) {
          story.userLiked = userInteraction.data()?['liked'] ?? false;
        }

        final commentSnapshot = await _firestore
            .collection(AppConstants.successStoriesCollection)
            .doc(story.id)
            .collection('comments')
            .get();
        story.commentCount = commentSnapshot.docs.length;

        return story;
      }).toList());
    } catch (e) {
      print("Error fetching success stories: $e");
      rethrow;
    }
  }

  Future<void> likeSuccessStory(String storyId, String userEmail) async {
    try {
      final storyRef = _firestore.collection(AppConstants.successStoriesCollection).doc(storyId);
      final interactionRef = storyRef.collection('interactions').doc(userEmail);

      final snapshot = await interactionRef.get();
      final hasLiked = snapshot.exists && snapshot.data()?['liked'] == true;

      if (!hasLiked) {
        final batch = _firestore.batch();
        batch.update(storyRef, {
          'likes': FieldValue.increment(1),
        });
        batch.set(interactionRef, {'liked': true}, SetOptions(merge: true));
        await batch.commit();
      }
    } catch (e) {
      print("Error liking success story: $e");
      rethrow;
    }
  }

  Future<void> removeLikeSuccessStory(String storyId, String userEmail) async {
    try {
      final storyRef = _firestore.collection(AppConstants.successStoriesCollection).doc(storyId);
      final interactionRef = storyRef.collection('interactions').doc(userEmail);

      final snapshot = await interactionRef.get();
      final hasLiked = snapshot.exists && snapshot.data()?['liked'] == true;

      if (hasLiked) {
        final batch = _firestore.batch();
        batch.update(storyRef, {
          'likes': FieldValue.increment(-1),
        });
        batch.set(interactionRef, {'liked': false}, SetOptions(merge: true));
        await batch.commit();
      }
    } catch (e) {
      print("Error removing like: $e");
      rethrow;
    }
  }

  Future<void> postComment({
    required String collection,
    required String itemId,
    required String content,
    required String userEmail,
    required String userName,
  }) async {
    try {
      final itemRef = _firestore.collection(collection).doc(itemId);
      final commentRef = itemRef.collection('comments').doc();

      final batch = _firestore.batch();
      batch.set(commentRef, {
        'content': content,
        'authorEmail': userEmail,
        'authorName': userName,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
      });
      batch.update(itemRef, {
        'commentCount': FieldValue.increment(1),
      });
      await batch.commit();
    } catch (e) {
      print("Error posting comment: $e");
      rethrow;
    }
  }

  Future<List<Comment>> getComments({
    required String collection,
    required String itemId,
    required String userEmail,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .doc(itemId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      return await Future.wait(snapshot.docs.map((doc) async {
        final comment = Comment.fromFirestore(doc.data(), doc.id);
        final userInteraction = await _firestore
            .collection(collection)
            .doc(itemId)
            .collection('comments')
            .doc(doc.id)
            .collection('interactions')
            .doc(userEmail)
            .get();

        if (userInteraction.exists) {
          comment.userLiked = userInteraction.data()?['liked'] ?? false;
        }

        return comment;
      }).toList());
    } catch (e) {
      print("Error fetching comments: $e");
      rethrow;
    }
  }

  Future<void> likeComment({
    required String collection,
    required String itemId,
    required String commentId,
    required String userEmail,
  }) async {
    try {
      final commentRef = _firestore
          .collection(collection)
          .doc(itemId)
          .collection('comments')
          .doc(commentId);
      final interactionRef = commentRef.collection('interactions').doc(userEmail);

      final snapshot = await interactionRef.get();
      final hasLiked = snapshot.exists && snapshot.data()?['liked'] == true;

      if (!hasLiked) {
        final batch = _firestore.batch();
        batch.update(commentRef, {
          'likes': FieldValue.increment(1),
        });
        batch.set(interactionRef, {'liked': true}, SetOptions(merge: true));
        await batch.commit();
      }
    } catch (e) {
      print("Error liking comment: $e");
      rethrow;
    }
  }

  Future<void> removeCommentLike({
    required String collection,
    required String itemId,
    required String commentId,
    required String userEmail,
  }) async {
    try {
      final commentRef = _firestore
          .collection(collection)
          .doc(itemId)
          .collection('comments')
          .doc(commentId);
      final interactionRef = commentRef.collection('interactions').doc(userEmail);

      final snapshot = await interactionRef.get();
      final hasLiked = snapshot.exists && snapshot.data()?['liked'] == true;

      if (hasLiked) {
        final batch = _firestore.batch();
        batch.update(commentRef, {
          'likes': FieldValue.increment(-1),
        });
        batch.set(interactionRef, {'liked': false}, SetOptions(merge: true));
        await batch.commit();
      }
    } catch (e) {
      print("Error removing comment like: $e");
      rethrow;
    }
  }
}