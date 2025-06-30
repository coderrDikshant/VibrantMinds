import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

import '../../models/blog_models/blog.dart';
import '../../theme/vibrant_theme.dart';

class BlogDetailPage extends StatelessWidget {
  final Blog blog;
  final String userEmail;
  final String userName;
  final bool isLiked;
  final AnimationController? animationController;
  final VoidCallback onLike;

  const BlogDetailPage({
    super.key,
    required this.blog,
    required this.userEmail,
    required this.userName,
    required this.isLiked,
    this.animationController,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final quillController = QuillController(
      document: Document.fromJson(blog.content),
      selection: const TextSelection.collapsed(offset: 0),
    );
    final editorFocusNode = FocusNode();
    final editorScrollController = ScrollController();

    return Scaffold(
      backgroundColor: VibrantTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          blog.title,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (blog.imageUrl.isNotEmpty)
              GestureDetector(
                onDoubleTap: onLike,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      blog.imageUrl,
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
                    blog.title,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${blog.author}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 300,
                    child: QuillEditor(
                      controller: quillController,
                      focusNode: editorFocusNode,
                      scrollController: editorScrollController,
                      config: QuillEditorConfig(
                        embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                        showCursor: false,
                        enableInteractiveSelection: true,
                        scrollable: true,
                        padding: const EdgeInsets.all(8.0),
                        autoFocus: false,
                      ),
                    ),
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
    );
  }
}
