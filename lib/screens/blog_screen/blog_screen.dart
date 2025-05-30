import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../models/blog_models/blog.dart';
import '../../models/comment.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';

class BlogScreen extends StatefulWidget {
  final String userEmail;
  final String userName;

  const BlogScreen({super.key, required this.userEmail, required this.userName});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> with TickerProviderStateMixin {
  late Future<List<Blog>> _blogsFuture;
  final Map<String, bool> _likedBlogs = {};
  final Map<String, int> _likeAnimationCounter = {};
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, Future<List<Comment>>> _commentsFutures = {};
  final Map<String, bool> _isCommentSectionExpanded = {};

  @override
  void initState() {
    super.initState();
    _refreshBlogs();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _refreshBlogs() async {
    setState(() {
      _blogsFuture = Provider.of<FirestoreService>(context, listen: false).getBlogs(widget.userEmail);
    });
  }

  Future<void> _handleLike(Blog blog) async {
    final service = Provider.of<FirestoreService>(context, listen: false);
    if (_likedBlogs[blog.id] == true) {
      await service.removeLike(blog.id, widget.userEmail);
      setState(() {
        _likedBlogs[blog.id] = false;
        blog.likes--;
      });
      return;
    }

    try {
      await service.likeBlog(blog.id, widget.userEmail);
      setState(() {
        _likedBlogs[blog.id] = true;
        blog.likes++;
        _likeAnimationCounter.putIfAbsent(blog.id, () => 0);
        if (_likeAnimationCounter[blog.id]! < 2) {
          _likeAnimationCounter[blog.id] = _likeAnimationCounter[blog.id]! + 1;
          // Remove existing controller if any
          _animationControllers[blog.id]?.dispose();
          _animationControllers.remove(blog.id);

          // Create new animation controller
          final controller = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 800),
          );

          int cycleCount = 0;
          bool isAnimationActive = true;

          // Animation loop
          void playAnimation() {
            if (!mounted || !isAnimationActive || cycleCount >= 3) {
              controller.dispose();
              if (mounted) {
                setState(() {
                  _animationControllers.remove(blog.id);
                });
              }
              return;
            }
            controller.forward().then((_) {
              cycleCount++;
              controller.reverse().then((_) {
                playAnimation();
              });
            });
          }

          _animationControllers[blog.id] = controller;
          playAnimation();

          // Force stop after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && isAnimationActive) {
              isAnimationActive = false;
              controller.stop();
              controller.dispose();
              setState(() {
                _animationControllers.remove(blog.id);
              });
            }
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error liking blog: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _postComment(Blog blog) async {
    final controller = _commentControllers[blog.id];
    if (controller == null || controller.text.trim().isEmpty) return;

    try {
      await Provider.of<FirestoreService>(context, listen: false).postComment(
        collection: AppConstants.blogsCollection,
        itemId: blog.id,
        content: controller.text.trim(),
        userEmail: widget.userEmail,
        userName: widget.userName,
      );
      setState(() {
        controller.clear();
        _commentsFutures[blog.id] = Provider.of<FirestoreService>(context, listen: false).getComments(
          collection: AppConstants.blogsCollection,
          itemId: blog.id,
          userEmail: widget.userEmail,
        );
        blog.commentCount++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error posting comment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleCommentLike(String blogId, Comment comment) async {
    final service = Provider.of<FirestoreService>(context, listen: false);
    try {
      if (comment.userLiked) {
        await service.removeCommentLike(
          collection: AppConstants.blogsCollection,
          itemId: blogId,
          commentId: comment.id,
          userEmail: widget.userEmail,
        );
        setState(() {
          comment.userLiked = false;
          comment.likes--;
        });
      } else {
        await service.likeComment(
          collection: AppConstants.blogsCollection,
          itemId: blogId,
          commentId: comment.id,
          userEmail: widget.userEmail,
        );
        setState(() {
          comment.userLiked = true;
          comment.likes++;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error liking comment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleCommentSection(String blogId) {
    setState(() {
      _isCommentSectionExpanded[blogId] = !(_isCommentSectionExpanded[blogId] ?? false);
    });
  }

  void _showBlogDialog(BuildContext context, Blog blog) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 600,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF9F9F9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (blog.imageUrl.isNotEmpty)
                        GestureDetector(
                          onDoubleTap: () => _handleLike(blog),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.network(
                                  blog.imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error, color: Color(0xFFD32F2F)),
                                    );
                                  },
                                ),
                              ),
                              if (_animationControllers.containsKey(blog.id))
                                FadeTransition(
                                  opacity: _animationControllers[blog.id]!.drive(
                                    Tween<double>(begin: 1.0, end: 0.0).chain(
                                      CurveTween(curve: Curves.easeOut),
                                    ),
                                  ),
                                  child: ScaleTransition(
                                    scale: _animationControllers[blog.id]!.drive(
                                      Tween<double>(begin: 1.2, end: 0.8).chain(
                                        CurveTween(curve: Curves.easeOut),
                                      ),
                                    ),
                                    child: Lottie.asset(
                                      'assets/animations/like_animation.json',
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              blog.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Color(0xFF000000),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'By ${blog.author}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              blog.content,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _likedBlogs[blog.id]! ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                                    color: _likedBlogs[blog.id]! ? const Color(0xFFD32F2F) : Colors.grey,
                                  ),
                                  onPressed: () => _handleLike(blog),
                                ),
                                Text('${blog.likes}', style: const TextStyle(fontFamily: 'Roboto')),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: Icon(
                                    Icons.comment,
                                    color: _isCommentSectionExpanded[blog.id]! ? const Color(0xFFD32F2F) : Colors.grey,
                                  ),
                                  onPressed: () => _toggleCommentSection(blog.id),
                                ),
                                Text('${blog.commentCount}', style: const TextStyle(fontFamily: 'Roboto')),
                              ],
                            ),
                            const Divider(),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Column(
                                children: [
                                  TextField(
                                    controller: _commentControllers[blog.id],
                                    decoration: InputDecoration(
                                      hintText: 'Add a comment...',
                                      hintStyle: const TextStyle(fontFamily: 'Roboto', color: Colors.grey),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.send, color: Color(0xFFD32F2F)),
                                        onPressed: () => _postComment(blog),
                                      ),
                                    ),
                                    style: const TextStyle(fontFamily: 'Roboto'),
                                  ),
                                  const SizedBox(height: 8),
                                  FutureBuilder<List<Comment>>(
                                    future: _commentsFutures[blog.id],
                                    builder: (context, commentSnapshot) {
                                      if (commentSnapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
                                        );
                                      }
                                      if (commentSnapshot.hasError) {
                                        return const Text(
                                          'Error loading comments',
                                          style: TextStyle(fontFamily: 'Roboto', color: Colors.red),
                                        );
                                      }

                                      final comments = commentSnapshot.data ?? [];

                                      if (comments.isEmpty) {
                                        return const Text(
                                          'No comments yet',
                                          style: TextStyle(fontFamily: 'Roboto', color: Colors.grey),
                                        );
                                      }

                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: comments.length,
                                        itemBuilder: (context, commentIndex) {
                                          final comment = comments[commentIndex];
                                          return ListTile(
                                            title: Text(
                                              comment.authorName,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            subtitle: Text(
                                              comment.content,
                                              style: const TextStyle(fontFamily: 'Roboto', fontSize: 14),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    comment.userLiked ? Icons.favorite : Icons.favorite_border,
                                                    color: comment.userLiked ? const Color(0xFFD32F2F) : Colors.grey,
                                                    size: 20,
                                                  ),
                                                  onPressed: () => _handleCommentLike(blog.id, comment),
                                                ),
                                                Text(
                                                  '${comment.likes}',
                                                  style: const TextStyle(fontFamily: 'Roboto', fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              crossFadeState: _isCommentSectionExpanded[blog.id]!
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 300),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF5F5F5), Color(0xFFFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _refreshBlogs,
        color: const Color(0xFFD32F2F),
        child: FutureBuilder<List<Blog>>(
          future: _blogsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Lottie.asset(
                  'assets/animations/loading_animation.json',
                  width: 100,
                  height: 100,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Failed to load blogs',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshBlogs,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final blogs = snapshot.data ?? [];

            if (blogs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/empty_state_animation.json',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No blogs available',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                final blog = blogs[index];
                _likedBlogs.putIfAbsent(blog.id, () => blog.userLiked);
                _commentControllers.putIfAbsent(blog.id, () => TextEditingController());
                _commentsFutures.putIfAbsent(
                  blog.id,
                      () => Provider.of<FirestoreService>(context, listen: false).getComments(
                    collection: AppConstants.blogsCollection,
                    itemId: blog.id,
                    userEmail: widget.userEmail,
                  ),
                );
                _isCommentSectionExpanded.putIfAbsent(blog.id, () => false);

                return GestureDetector(
                  onTap: () => _showBlogDialog(context, blog),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFF9F9F9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              blog.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Color(0xFF000000),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'By ${blog.author}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (blog.imageUrl.isNotEmpty)
                              GestureDetector(
                                onDoubleTap: () => _handleLike(blog),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        blog.imageUrl,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(
                                            child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 200,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.error, color: Color(0xFFD32F2F)),
                                          );
                                        },
                                      ),
                                    ),
                                    if (_animationControllers.containsKey(blog.id))
                                      FadeTransition(
                                        opacity: _animationControllers[blog.id]!.drive(
                                          Tween<double>(begin: 1.0, end: 0.0).chain(
                                            CurveTween(curve: Curves.easeOut),
                                          ),
                                        ),
                                        child: ScaleTransition(
                                          scale: _animationControllers[blog.id]!.drive(
                                            Tween<double>(begin: 1.2, end: 0.8).chain(
                                              CurveTween(curve: Curves.easeOut),
                                            ),
                                          ),
                                          child: Lottie.asset(
                                            'assets/animations/like_animation.json',
                                            width: 80,
                                            height: 80,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              blog.content.length > 100 ? '${blog.content.substring(0, 100)}...' : blog.content,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _likedBlogs[blog.id]! ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                                    color: _likedBlogs[blog.id]! ? const Color(0xFFD32F2F) : Colors.grey,
                                  ),
                                  onPressed: () => _handleLike(blog),
                                ),
                                Text('${blog.likes}', style: const TextStyle(fontFamily: 'Roboto')),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: Icon(
                                    Icons.comment,
                                    color: _isCommentSectionExpanded[blog.id]! ? const Color(0xFFD32F2F) : Colors.grey,
                                  ),
                                  onPressed: () => _toggleCommentSection(blog.id),
                                ),
                                Text('${blog.commentCount}', style: const TextStyle(fontFamily: 'Roboto')),
                              ],
                            ),
                            const Divider(),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Column(
                                children: [
                                  TextField(
                                    controller: _commentControllers[blog.id],
                                    decoration: InputDecoration(
                                      hintText: 'Add a comment...',
                                      hintStyle: const TextStyle(fontFamily: 'Roboto', color: Colors.grey),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.send, color: Color(0xFFD32F2F)),
                                        onPressed: () => _postComment(blog),
                                      ),
                                    ),
                                    style: const TextStyle(fontFamily: 'Roboto'),
                                  ),
                                  const SizedBox(height: 8),
                                  FutureBuilder<List<Comment>>(
                                    future: _commentsFutures[blog.id],
                                    builder: (context, commentSnapshot) {
                                      if (commentSnapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
                                        );
                                      }
                                      if (commentSnapshot.hasError) {
                                        return const Text(
                                          'Error loading comments',
                                          style: TextStyle(fontFamily: 'Roboto', color: Colors.red),
                                        );
                                      }

                                      final comments = commentSnapshot.data ?? [];

                                      if (comments.isEmpty) {
                                        return const Text(
                                          'No comments yet',
                                          style: TextStyle(fontFamily: 'Roboto', color: Colors.grey),
                                        );
                                      }

                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: comments.length,
                                        itemBuilder: (context, commentIndex) {
                                          final comment = comments[commentIndex];
                                          return ListTile(
                                            title: Text(
                                              comment.authorName,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            subtitle: Text(
                                              comment.content,
                                              style: const TextStyle(fontFamily: 'Roboto', fontSize: 14),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    comment.userLiked ? Icons.favorite : Icons.favorite_border,
                                                    color: comment.userLiked ? const Color(0xFFD32F2F) : Colors.grey,
                                                    size: 20,
                                                  ),
                                                  onPressed: () => _handleCommentLike(blog.id, comment),
                                                ),
                                                Text(
                                                  '${comment.likes}',
                                                  style: const TextStyle(fontFamily: 'Roboto', fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              crossFadeState: _isCommentSectionExpanded[blog.id]!
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 300),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}