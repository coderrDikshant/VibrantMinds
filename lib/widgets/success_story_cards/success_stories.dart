import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/success_story.dart';
import '../../models/comment.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../theme/vibrant_theme.dart';

class SuccessStoryPage extends StatefulWidget {
  final String userEmail;
  final String userName;

  const SuccessStoryPage({super.key, required this.userEmail, required this.userName});

  @override
  State<SuccessStoryPage> createState() => _SuccessStoryPageState();
}

class _SuccessStoryPageState extends State<SuccessStoryPage> with TickerProviderStateMixin {
  late Future<List<SuccessStory>> _storiesFuture;
  final Map<String, bool> _likedStories = {};
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, AnimationController> _cardAnimationControllers = {};
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, Future<List<Comment>>> _commentsFutures = {};
  final Map<String, bool> _isCommentSectionExpanded = {};
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _refreshStories();
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
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _refreshStories() async {
    setState(() {
      _storiesFuture = Provider.of<FirestoreService>(context, listen: false).getSuccessStories(widget.userEmail);
    });
  }

  Future<void> _handleLike(SuccessStory story) async {
    final service = Provider.of<FirestoreService>(context, listen: false);
    if (_likedStories[story.id] == true) {
      try {
        await service.removeLikeSuccessStory(story.id, widget.userEmail);
        setState(() {
          _likedStories[story.id] = false;
          story.likes--;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error unliking story: $e'),
              backgroundColor: VibrantTheme.errorColor,
            ),
          );
        }
      }
      return;
    }

    try {
      await service.likeSuccessStory(story.id, widget.userEmail);
      setState(() {
        _likedStories[story.id] = true;
        story.likes++;
        _animationControllers.putIfAbsent(
          story.id,
              () => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 800),
          )..forward().then((_) {
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) {
                _animationControllers[story.id]?.reverse();
              }
            });
          }),
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error liking story: $e'),
            backgroundColor: VibrantTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _postComment(SuccessStory story) async {
    final controller = _commentControllers[story.id];
    if (controller == null || controller.text.trim().isEmpty) return;

    try {
      await Provider.of<FirestoreService>(context, listen: false).postComment(
        collection: AppConstants.successStoriesCollection,
        itemId: story.id,
        content: controller.text.trim(),
        userEmail: widget.userEmail,
        userName: widget.userName,
      );
      setState(() {
        controller.clear();
        _commentsFutures[story.id] = Provider.of<FirestoreService>(context, listen: false).getComments(
          collection: AppConstants.successStoriesCollection,
          itemId: story.id,
          userEmail: widget.userEmail,
        );
        story.commentCount++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting comment: $e'),
            backgroundColor: VibrantTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleCommentLike(String storyId, Comment comment) async {
    final service = Provider.of<FirestoreService>(context, listen: false);
    try {
      if (comment.userLiked) {
        await service.removeCommentLike(
          collection: AppConstants.successStoriesCollection,
          itemId: storyId,
          commentId: comment.id,
          userEmail: widget.userEmail,
        );
        setState(() {
          comment.userLiked = false;
          comment.likes--;
        });
      } else {
        await service.likeComment(
          collection: AppConstants.successStoriesCollection,
          itemId: storyId,
          commentId: comment.id,
          userEmail: widget.userEmail,
        );
        setState(() {
          comment.userLiked = true;
          comment.likes++;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error liking comment: $e'),
            backgroundColor: VibrantTheme.errorColor,
          ),
        );
      }
    }
  }

  void _toggleCommentSection(String storyId) {
    setState(() {
      _isCommentSectionExpanded[storyId] = !(_isCommentSectionExpanded[storyId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Success Stories'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [VibrantTheme.backgroundColor, Color(0xFFF9F9F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshStories,
          color: VibrantTheme.primaryColor,
          child: FutureBuilder<List<SuccessStory>>(
            future: _storiesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Lottie.asset(
                    'assets/animations/connection_animation.json',
                    width: 80,
                    height: 80,
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
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load stories: ${snapshot.error}',
                        style: VibrantTheme.themeData.textTheme.bodyLarge?.copyWith(
                          color: VibrantTheme.errorColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _refreshStories,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VibrantTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final stories = snapshot.data ?? [];

              if (stories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/empty_state_animation.json',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No success stories available',
                        style: VibrantTheme.themeData.textTheme.bodyLarge?.copyWith(
                          color: VibrantTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _refreshStories,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VibrantTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  _likedStories.putIfAbsent(story.id, () => story.userLiked);
                  _commentControllers.putIfAbsent(story.id, () => TextEditingController());
                  _cardAnimationControllers.putIfAbsent(
                    story.id,
                        () => AnimationController(
                      vsync: this,
                      duration: const Duration(milliseconds: 200),
                    ),
                  );
                  _commentsFutures.putIfAbsent(
                    story.id,
                        () => Provider.of<FirestoreService>(context, listen: false).getComments(
                      collection: AppConstants.successStoriesCollection,
                      itemId: story.id,
                      userEmail: widget.userEmail,
                    ),
                  );
                  _isCommentSectionExpanded.putIfAbsent(story.id, () => false);

                  return AnimatedBuilder(
                    animation: _listAnimationController,
                    builder: (context, child) {
                      final animation = CurvedAnimation(
                        parent: _listAnimationController,
                        curve: Interval(
                          index * 0.05,
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _StoryCard(
                      story: story,
                      userEmail: widget.userEmail,
                      userName: widget.userName,
                      isLiked: _likedStories[story.id]!,
                      animationController: _animationControllers[story.id],
                      cardAnimationController: _cardAnimationControllers[story.id]!,
                      commentController: _commentControllers[story.id]!,
                      commentsFuture: _commentsFutures[story.id]!,
                      isCommentSectionExpanded: _isCommentSectionExpanded[story.id]!,
                      onLike: () => _handleLike(story),
                      onPostComment: () => _postComment(story),
                      onToggleCommentSection: () => _toggleCommentSection(story.id),
                      onCommentLike: (comment) => _handleCommentLike(story.id, comment),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final SuccessStory story;
  final String userEmail;
  final String userName;
  final bool isLiked;
  final AnimationController? animationController;
  final AnimationController cardAnimationController;
  final TextEditingController commentController;
  final Future<List<Comment>> commentsFuture;
  final bool isCommentSectionExpanded;
  final VoidCallback onLike;
  final VoidCallback onPostComment;
  final VoidCallback onToggleCommentSection;
  final Function(Comment) onCommentLike;

  const _StoryCard({
    required this.story,
    required this.userEmail,
    required this.userName,
    required this.isLiked,
    this.animationController,
    required this.cardAnimationController,
    required this.commentController,
    required this.commentsFuture,
    required this.isCommentSectionExpanded,
    required this.onLike,
    required this.onPostComment,
    required this.onToggleCommentSection,
    required this.onCommentLike,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => cardAnimationController.forward(),
      onTapUp: (_) => cardAnimationController.reverse(),
      onTapCancel: () => cardAnimationController.reverse(),
      child: AnimatedBuilder(
        animation: cardAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: Tween<double>(begin: 1.0, end: 0.98).animate(
              CurvedAnimation(parent: cardAnimationController, curve: Curves.easeInOut),
            ).value,
            child: child,
          );
        },
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (story.imageUrl.isNotEmpty)
                  GestureDetector(
                    onDoubleTap: onLike,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            story.imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(color: VibrantTheme.primaryColor),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error, color: VibrantTheme.errorColor),
                              );
                            },
                          ),
                        ),
                        if (animationController != null)
                          FadeTransition(
                            opacity: animationController!.drive(
                              Tween<double>(begin: 1.0, end: 0.0).chain(
                                CurveTween(curve: Curves.easeOut),
                              ),
                            ),
                            child: ScaleTransition(
                              scale: animationController!.drive(
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
                        story.title,
                        style: VibrantTheme.themeData.textTheme.headlineLarge?.copyWith(
                          fontFamily: 'Poppins',
                          color: VibrantTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        story.description,
                        style: VibrantTheme.themeData.textTheme.bodyLarge?.copyWith(
                          fontFamily: 'Roboto',
                          color: VibrantTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                              color: isLiked ? VibrantTheme.primaryColor : Colors.grey,
                            ),
                            onPressed: onLike,
                          ),
                          Text(
                            '${story.likes}',
                            style: VibrantTheme.themeData.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Roboto',
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: Icon(
                              Icons.comment,
                              color: isCommentSectionExpanded ? VibrantTheme.primaryColor : Colors.grey,
                            ),
                            onPressed: onToggleCommentSection,
                          ),
                          Text(
                            '${story.commentCount}',
                            style: VibrantTheme.themeData.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          children: [
                            TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                hintStyle: VibrantTheme.themeData.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Roboto',
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: VibrantTheme.primaryColor, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.send, color: VibrantTheme.primaryColor),
                                  onPressed: onPostComment,
                                ),
                              ),
                              style: VibrantTheme.themeData.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<List<Comment>>(
                              future: commentsFuture,
                              builder: (context, commentSnapshot) {
                                if (commentSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(color: VibrantTheme.primaryColor),
                                  );
                                }
                                if (commentSnapshot.hasError) {
                                  return Text(
                                    'Error loading comments: ${commentSnapshot.error}',
                                    style: VibrantTheme.themeData.textTheme.bodyMedium?.copyWith(
                                      fontFamily: 'Roboto',
                                      color: VibrantTheme.errorColor,
                                    ),
                                  );
                                }

                                final comments = commentSnapshot.data ?? [];

                                if (comments.isEmpty) {
                                  return Text(
                                    'No comments yet',
                                    style: VibrantTheme.themeData.textTheme.bodyMedium?.copyWith(
                                      fontFamily: 'Roboto',
                                      color: Colors.grey,
                                    ),
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
                                        style: VibrantTheme.themeData.textTheme.headlineMedium?.copyWith(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                        ),
                                      ),
                                      subtitle: Text(
                                        comment.content,
                                        style: VibrantTheme.themeData.textTheme.bodyMedium?.copyWith(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              comment.userLiked ? Icons.favorite : Icons.favorite_border,
                                              color: comment.userLiked ? VibrantTheme.primaryColor : Colors.grey,
                                              size: 20,
                                            ),
                                            onPressed: () => onCommentLike(comment),
                                          ),
                                          Text(
                                            '${comment.likes}',
                                            style: VibrantTheme.themeData.textTheme.bodySmall?.copyWith(
                                              fontFamily: 'Roboto',
                                            ),
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
                        crossFadeState: isCommentSectionExpanded
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
      ),
    );
  }
}