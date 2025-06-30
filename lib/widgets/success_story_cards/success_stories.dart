import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/success_story.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../theme/vibrant_theme.dart';
import 'story_detail_page.dart';

class SuccessStoryPage extends StatefulWidget {
  final String userEmail;
  final String userName;

  const SuccessStoryPage({
    super.key,
    required this.userEmail,
    required this.userName,
  });

  @override
  State<SuccessStoryPage> createState() => _SuccessStoryPageState();
}

class _SuccessStoryPageState extends State<SuccessStoryPage>
    with TickerProviderStateMixin {
  late Future<List<SuccessStory>> _storiesFuture;
  final Map<String, bool> _likedStories = {};
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
    super.dispose();
  }

  Future<void> _refreshStories() async {
    setState(() {
      _storiesFuture = Provider.of<FirestoreService>(
        context,
        listen: false,
      ).getSuccessStories(widget.userEmail);
    });
  }

  Future<void> _handleLike(SuccessStory story) async {
    final service = Provider.of<FirestoreService>(context, listen: false);
    bool currentlyLiked = _likedStories[story.id] ?? story.userLiked;

    // Optimistic update
    setState(() {
      _likedStories[story.id] = !currentlyLiked;
      story.likes = !currentlyLiked ? story.likes + 1 : story.likes - 1;
    });

    try {
      if (currentlyLiked) {
        await service.removeLikeSuccessStory(story.id, widget.userEmail);
      } else {
        await service.likeSuccessStory(story.id, widget.userEmail);
        _likeAnimationCounter[story.id] =
            (_likeAnimationCounter[story.id] ?? 0) + 1;
        if (_likeAnimationCounter[story.id]! <= 2) {
          _animationControllers[story.id]?.dispose();
          final controller = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 800),
          );
          _animationControllers[story.id] = controller;

          int cycleCount = 0;
          bool isAnimationActive = true;

          void playAnimation() {
            if (!mounted ||
                !isAnimationActive ||
                controller.status == AnimationStatus.completed) {
              controller.dispose();
              if (mounted) {
                setState(() {
                  _animationControllers.remove(story.id);
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
                    _animationControllers.remove(story.id);
                  });
                }
              }
            });
          }

          playAnimation();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted &&
                isAnimationActive &&
                _animationControllers.containsKey(story.id)) {
              isAnimationActive = false;
              _animationControllers[story.id]?.stop();
              _animationControllers[story.id]?.dispose();
              if (mounted) {
                setState(() {
                  _animationControllers.remove(story.id);
                });
              }
            }
          });
        }
      }
    } catch (e) {
      // Revert optimistic update on error
      setState(() {
        _likedStories[story.id] = currentlyLiked;
        story.likes = !currentlyLiked ? story.likes - 1 : story.likes + 1;
      });
      if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VibrantTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Success Stories',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStories,
        color: VibrantTheme.primaryColor,
        backgroundColor: VibrantTheme.surfaceColor,
        child: FutureBuilder<List<SuccessStory>>(
          future: _storiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Lottie.asset(
                  'assets/animations/connection_animation.json',
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
                      'Failed to load stories: ${snapshot.error}',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: VibrantTheme.errorColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: Theme.of(context).elevatedButtonTheme.style,
                      onPressed: _refreshStories,
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

            final stories = snapshot.data ?? [];

            if (stories.isEmpty) {
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
                      'No success stories available',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: VibrantTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: Theme.of(context).elevatedButtonTheme.style,
                      onPressed: _refreshStories,
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
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                _likedStories.putIfAbsent(story.id, () => story.userLiked);
                _cardAnimationControllers.putIfAbsent(
                  story.id,
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
                  child: _StoryCard(
                    story: story,
                    userEmail: widget.userEmail,
                    userName: widget.userName,
                    isLiked: _likedStories[story.id]!,
                    animationController: _animationControllers[story.id],
                    cardAnimationController:
                        _cardAnimationControllers[story.id]!,
                    onLike: () => _handleLike(story),
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

class _StoryCard extends StatelessWidget {
  final SuccessStory story;
  final String userEmail;
  final String userName;
  final bool isLiked;
  final AnimationController? animationController;
  final AnimationController cardAnimationController;
  final VoidCallback onLike;

  const _StoryCard({
    required this.story,
    required this.userEmail,
    required this.userName,
    required this.isLiked,
    this.animationController,
    required this.cardAnimationController,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final truncatedDescription =
        story.description.length > 100
            ? '${story.description.substring(0, 100)}...'
            : story.description;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => StoryDetailPage(
                  story: story,
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
              if (story.imageUrl.isNotEmpty)
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
                          story.imageUrl,
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
                      story.title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      truncatedDescription,
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
                          '${story.likes}',
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
