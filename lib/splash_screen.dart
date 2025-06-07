import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart'; // Import for AuthException

import 'main.dart'; // Import main.dart to access CombinedRedirector

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _videoInitialized = false; // Is the video player ready to show frames?
  bool _backgroundProcessesCompleted =
      false; // Are Firebase, Amplify, Auth session checks done?
  bool _videoStartedPlaying =
      false; // Has the video started playing after tasks completed?
  bool _videoFinishedPlaying = false; // Has the video reached its end?

  @override
  void initState() {
    super.initState();

    // 1. Initialize video player
    _controller = VideoPlayerController.asset('assets/video/Logo_Animation.mp4')
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _videoInitialized = true;
              });
              _triggerVideoPlayIfReady(); // Check if video can start playing
            }
          })
          .catchError((error) {
            debugPrint('Video initialization error: $error');
            if (mounted) {
              // If video fails to initialize, treat it as finished and move on.
              setState(() {
                _videoFinishedPlaying = true;
              });
              _checkAndNavigate();
            }
          });

    // 2. Listen for video completion
    _controller.addListener(() {
      if (_controller.value.isInitialized &&
          _controller.value.position >= _controller.value.duration &&
          mounted) {
        setState(() {
          _videoFinishedPlaying = true;
        });
        _checkAndNavigate(); // Video finished, check if ready to navigate
      }
    });

    // 3. Start background process checks immediately
    _performBackgroundTasks();
  }

  // This method combines all background checks:
  // - Basic Amplify configuration (already done in main, but good to verify)
  // - Amplify Auth session check (this is likely the 2-second delay you saw)
  Future<void> _performBackgroundTasks() async {
    // Verify Amplify is configured (should be true very quickly after main.dart awaits)
    if (!Amplify.isConfigured) {
      // Small delay and retry if not immediately configured (should rarely happen)
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      if (!Amplify.isConfigured) {
        debugPrint(
          'Amplify not configured after initial delay. Possible issue.',
        );
        // Consider more robust error handling or a longer delay here if common
      }
    }

    // Crucial: Perform initial Amplify Auth session check.
    // This is often where the 2-second loading occurs when Authenticator first runs.
    try {
      await Amplify.Auth.fetchAuthSession();
      safePrint('Auth session checked.');
    } on AuthException catch (e) {
      safePrint(
        'Auth session check failed: ${e.message}. (User might be signed out, which is fine)',
      );
      // It's okay if it fails, it just means no current session, but the check completed.
    } catch (e) {
      safePrint('Generic error during auth session check: $e');
    }

    if (mounted) {
      setState(() {
        _backgroundProcessesCompleted = true;
      });
      _triggerVideoPlayIfReady(); // Background tasks done, check if video can start
    }
  }

  // Checks if both video is ready AND background tasks are done, then starts video
  void _triggerVideoPlayIfReady() {
    if (_videoInitialized &&
        _backgroundProcessesCompleted &&
        !_videoStartedPlaying &&
        mounted) {
      _controller.play();
      _controller.setLooping(false); // Play only once
      setState(() {
        _videoStartedPlaying = true;
      });
      debugPrint('Video started playing at ${DateTime.now()}');
    }
  }

  // Navigates away only when the video has completely finished playing
  void _checkAndNavigate() {
    if (_videoFinishedPlaying && mounted) {
      _controller.pause(); // Pause before navigating away
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CombinedRedirector()),
      );
      debugPrint('Navigated to CombinedRedirector at ${DateTime.now()}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Display the video player, but it won't play until _triggerVideoPlayIfReady() is called.
    // This ensures a static image (first frame of video or black screen) is shown
    // during background loading.
    return Scaffold(
      backgroundColor: Colors.black, // Ensures a solid black background
      body:
          _videoInitialized
              ? Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: FittedBox(
                        fit: BoxFit.cover, // Ensures video covers the screen
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    );
                  },
                ),
              )
              : const SizedBox.expand(), // Show a full black screen while video is not initialized
    );
  }
}
