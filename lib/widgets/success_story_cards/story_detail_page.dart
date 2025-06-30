import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../models/success_story.dart';
import '../../theme/vibrant_theme.dart';

class StoryDetailPage extends StatelessWidget {
  final SuccessStory story;
  final String userEmail;
  final String userName;
  final bool isLiked;
  final AnimationController? animationController;
  final VoidCallback onLike;

  const StoryDetailPage({
    super.key,
    required this.story,
    required this.userEmail,
    required this.userName,
    required this.isLiked,
    this.animationController,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VibrantTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          story.title,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (story.imageUrl.isNotEmpty)
              GestureDetector(
                onDoubleTap: onLike,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      story.imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 250,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: VibrantTheme.primaryColor,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: VibrantTheme.greyTextColor.withOpacity(0.2),
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: VibrantTheme.errorColor,
                          ),
                        );
                      },
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
                    story.description,
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
    );
  }
}
