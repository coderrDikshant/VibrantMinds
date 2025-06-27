import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

import '../../models/blog_models/blog.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../theme/vibrant_theme.dart';
import 'blog_detail_page.dart';

class BlogScreen extends StatefulWidget {
  final String userEmail;
  final String userName;

  const BlogScreen({
    super.key,
    required this.userEmail,
    required this.userName,
  });

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> with TickerProviderStateMixin {
  late Future<List<Blog>> _blogsFuture;
  final Map<String, bool> _likedBlogs = {};
  final Map<String, int> _likeAnimationCounter = {};
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, AnimationController> _cardAnimationControllers = {};
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _refreshBlogs();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    for (var controller in _cardAnimationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _refreshBlogs() async {
    setState(() {
      _blogsFuture = Provider.of<FirestoreService>(
        context,
        listen: false,
      ).getBlogs(widget.userEmail);
    });
  }

  Future<void> _handleLike(Blog blog) async {
    final service = Provider.of<FirestoreService>(context, listen: false);
    bool currentlyLiked = _likedBlogs[blog.id] ?? blog.userLiked;

    // Optimistic update
    setState(() {
      _likedBlogs[blog.id] = !currentlyLiked;
      blog.likes = !currentlyLiked ? blog.likes + 1 : blog.likes - 1;
    });

    try {
      if (currentlyLiked) {
        await service.removeLike(blog.id, widget.userEmail);
      } else {
        await service.likeBlog(blog.id, widget.userEmail);
        _likeAnimationCounter[blog.id] =
            (_likeAnimationCounter[blog.id] ?? 0) + 1;
        if (_likeAnimationCounter[blog.id]! <= 2) {
          _animationControllers[blog.id]?.dispose();
          final controller = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 800),
          );
          _animationControllers[blog.id] = controller;

          int cycleCount = 0;
          bool isAnimationActive = true;

          void playAnimation() {
            if (!mounted ||
                !isAnimationActive ||
                controller.status == AnimationStatus.completed) {
              controller.dispose();
              if (mounted) {
                setState(() {
                  _animationControllers.remove(blog.id);
                });
              }
              return;
            }
            controller.forward().then((_) {
              if (cycleCount < 2) {
                cycleCount++;
                controller.reverse().then((_) => playAnimation());
              } else {
                controller.dispose();
                if (mounted) {
                  setState(() {
                    _animationControllers.remove(blog.id);
                  });
                }
              }
            });
          }

          playAnimation();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted &&
                isAnimationActive &&
                _animationControllers.containsKey(blog.id)) {
              isAnimationActive = false;
              _animationControllers[blog.id]?.stop();
              _animationControllers[blog.id]?.dispose();
              if (mounted) {
                setState(() {
                  _animationControllers.remove(blog.id);
                });
              }
            }
          });
        }
      }
    } catch (e) {
      // Revert optimistic update on error
      setState(() {
        _likedBlogs[blog.id] = currentlyLiked;
        blog.likes = !currentlyLiked ? blog.likes - 1 : blog.likes + 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating like status: $e',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          backgroundColor: VibrantTheme.errorColor,
        ),
      );
    }
  }

  String _getPlainTextSnippet(List<dynamic> quillContent, int maxLength) {
    try {
      final document = Document.fromJson(quillContent);
      final plainText = document.toPlainText();
      return plainText.length > maxLength
          ? '${plainText.substring(0, maxLength).trim()}...'
          : plainText.trim();
    } catch (e) {
      return 'Error loading content or invalid format.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VibrantTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Blogs',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBlogs,
        color: VibrantTheme.primaryColor,
        backgroundColor: VibrantTheme.surfaceColor,
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
                    Lottie.asset(
                      'assets/animations/error_animation.json',
                      width: 140,
                      height: 140,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load blogs: ${snapshot.error}',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: VibrantTheme.errorColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: Theme.of(context).elevatedButtonTheme.style,
                      onPressed: _refreshBlogs,
                      child: Text(
                        'Retry',
                        style: Theme.of(
                          context,
                        ).elevatedButtonTheme.style!.textStyle!.resolve({}),
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
                      width: 140,
                      height: 140,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No blogs available',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: VibrantTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: Theme.of(context).elevatedButtonTheme.style,
                      onPressed: _refreshBlogs,
                      child: Text(
                        'Refresh',
                        style: Theme.of(
                          context,
                        ).elevatedButtonTheme.style!.textStyle!.resolve({}),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                final blog = blogs[index];
                _likedBlogs.putIfAbsent(blog.id, () => blog.userLiked);
                _cardAnimationControllers.putIfAbsent(
                  blog.id,
                  () => AnimationController(
                    vsync: this,
                    duration: const Duration(milliseconds: 200),
                  ),
                );

                return AnimatedBuilder(
                  animation: _listAnimationController,
                  builder: (context, child) {
                    final animation = CurvedAnimation(
                      parent: _listAnimationController,
                      curve: Interval(
                        index * 0.05,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    );
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _BlogCard(
                    blog: blog,
                    userEmail: widget.userEmail,
                    userName: widget.userName,
                    isLiked: _likedBlogs[blog.id]!,
                    animationController: _animationControllers[blog.id],
                    cardAnimationController:
                        _cardAnimationControllers[blog.id]!,
                    onLike: () => _handleLike(blog),
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

class _BlogCard extends StatelessWidget {
  final Blog blog;
  final String userEmail;
  final String userName;
  final bool isLiked;
  final AnimationController? animationController;
  final AnimationController cardAnimationController;
  final VoidCallback onLike;

  const _BlogCard({
    required this.blog,
    required this.userEmail,
    required this.userName,
    required this.isLiked,
    this.animationController,
    required this.cardAnimationController,
    required this.onLike,
  });

  String _getPlainTextSnippet(List<dynamic> quillContent, int maxLength) {
    try {
      final document = Document.fromJson(quillContent);
      final plainText = document.toPlainText();
      return plainText.length > maxLength
          ? '${plainText.substring(0, maxLength).trim()}...'
          : plainText.trim();
    } catch (e) {
      return 'Error loading content or invalid format.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BlogDetailPage(
                  blog: blog,
                  userEmail: userEmail,
                  userName: userName,
                  onLike: onLike,
                  isLiked: isLiked,
                  animationController: animationController,
                ),
          ),
        );
      },
      onTapDown: (_) => cardAnimationController.forward(),
      onTapUp: (_) => cardAnimationController.reverse(),
      onTapCancel: () => cardAnimationController.reverse(),
      child: AnimatedBuilder(
        animation: cardAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale:
                Tween<double>(begin: 1.0, end: 0.98)
                    .animate(
                      CurvedAnimation(
                        parent: cardAnimationController,
                        curve: Curves.easeInOut,
                      ),
                    )
                    .value,
            child: child,
          );
        },
        child: Card(
          elevation: Theme.of(context).cardTheme.elevation,
          shape: Theme.of(context).cardTheme.shape,
          margin: Theme.of(context).cardTheme.margin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (blog.imageUrl.isNotEmpty)
                GestureDetector(
                  onDoubleTap: onLike,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          blog.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: VibrantTheme.primaryColor,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: VibrantTheme.greyTextColor.withOpacity(
                                0.2,
                              ),
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: VibrantTheme.errorColor,
                              ),
                            );
                          },
                        ),
                      ),
                      if (animationController != null)
                        FadeTransition(
                          opacity: animationController!.drive(
                            Tween<double>(
                              begin: 1.0,
                              end: 0.0,
                            ).chain(CurveTween(curve: Curves.easeOut)),
                          ),
                          child: ScaleTransition(
                            scale: animationController!.drive(
                              Tween<double>(
                                begin: 1.2,
                                end: 0.8,
                              ).chain(CurveTween(curve: Curves.easeOut)),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog.title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'By ${blog.author}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getPlainTextSnippet(blog.content, 150),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked
                                ? Icons.thumb_up_alt
                                : Icons.thumb_up_alt_outlined,
                            color:
                                isLiked
                                    ? VibrantTheme.primaryColor
                                    : VibrantTheme.greyTextColor,
                          ),
                          onPressed: onLike,
                        ),
                        Text(
                          '${blog.likes}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
