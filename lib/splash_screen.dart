import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:hive_flutter/hive_flutter.dart';


import '../screens/profile_screens/role_based_home.dart';
import '../widgets/profile_cards/personal_info_section.dart';
import '../utils/jwt_utils.dart'; // Ensure parseJwt is here


class CombinedRedirector extends StatefulWidget {
  const CombinedRedirector({super.key});

  @override
  State<CombinedRedirector> createState() => _CombinedRedirectorState();
}

class _CombinedRedirectorState extends State<CombinedRedirector> {
  String _email = '';
  bool _loadingEmailAndProfile = true;

  @override
  void initState() {
    super.initState();
    _loadEmailAndProfile();
  }

 Future<void> _loadEmailAndProfile() async {
  try {
   final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
final idToken = session.userPoolTokensResult.value.idToken;
final decoded = parseJwt(idToken.raw);

   
    final email = decoded['email'] ?? '';
    final groups = decoded['cognito:groups'] as List<dynamic>? ?? [];
    final isEnrolled = groups.contains('Course_enroll');

    final profileBox = Hive.box('profileBox');
    await profileBox.put('isCourseEnrolled', isEnrolled);

    setState(() {
      _email = email;
      _loadingEmailAndProfile = false;
    });
  } catch (e) {
    safePrint('Error: $e');
    setState(() => _loadingEmailAndProfile = false);
  }
}


  @override
  Widget build(BuildContext context) {
    if (_loadingEmailAndProfile) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profileBox = Hive.box('profileBox');
    final personalInfo = profileBox.get('personalInfo');

    if (personalInfo is Map &&
        personalInfo['firstName'] != null &&
        personalInfo['firstName'].toString().isNotEmpty) {
      return RoleBasedHome(
        firstName: personalInfo['firstName'] ?? '',
        lastName: personalInfo['lastName'] ?? '',
      );
    }

    return PersonalInfoScreen(email: _email);
  }
}

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   late VideoPlayerController _controller;
//   bool _videoInitialized = false;
//   bool _backgroundProcessesCompleted = false;
//   bool _videoStartedPlaying = false;
//   bool _videoFinishedPlaying = false;

//   @override
//   void initState() {
//     super.initState();

//     // 1. Initialize video player
//     _controller = VideoPlayerController.asset('assets/video/Logo_Animation.mp4')
//       ..initialize()
//           .then((_) {
//             if (mounted) {
//               setState(() {
//                 _videoInitialized = true;
//               });
//               _triggerVideoPlayIfReady();
//             }
//           })
//           .catchError((error) {
//             debugPrint('Video initialization error: $error');
//             if (mounted) {
//               setState(() {
//                 _videoFinishedPlaying = true; // Skip video if it fails
//               });
//               _checkAndNavigate();
//             }
//           });

//     // 2. Listen for video completion
//     _controller.addListener(() {
//       if (_controller.value.isInitialized &&
//           _controller.value.position >= _controller.value.duration &&
//           mounted) {
//         setState(() {
//           _videoFinishedPlaying = true;
//         });
//         _checkAndNavigate();
//       }
//     });

//     // 3. Start background process checks immediately
//     _performBackgroundTasks();
//   }

//   Future<void> _performBackgroundTasks() async {
//     // Verify Amplify is configured (should be true very quickly after main.dart awaits)
//     if (!Amplify.isConfigured) {
//       await Future.delayed(const Duration(milliseconds: 200));
//       if (!mounted) return;
//       if (!Amplify.isConfigured) {
//         debugPrint(
//           'Amplify not configured after initial delay. Possible issue.',
//         );
//       }
//     }

//     // Crucial: Perform initial Amplify Auth session check.
//     try {
//       await Amplify.Auth.fetchAuthSession();
//       safePrint('Auth session checked in SplashScreen.');
//     } on AuthException catch (e) {
//       safePrint(
//         'Auth session check failed in SplashScreen: ${e.message}. (User might be signed out, which is fine)',
//       );
//     } catch (e) {
//       safePrint('Generic error during auth session check in SplashScreen: $e');
//     }

//     if (mounted) {
//       setState(() {
//         _backgroundProcessesCompleted = true;
//       });
//       _triggerVideoPlayIfReady();
//     }
//   }

// void _triggerVideoPlayIfReady() {
//   if (_videoInitialized && !_videoStartedPlaying && mounted) {
//     _controller.play();
//     _controller.setLooping(false);
//     setState(() {
//       _videoStartedPlaying = true;
//     });
//     debugPrint('🎬 Video started immediately on init');
//   }
// }


//   void _checkAndNavigate() {
//     if (_videoFinishedPlaying && mounted) {
//       _controller.pause();
//       // Navigate to the CombinedRedirector which will then decide the actual
//       // destination (RoleBasedHome or PersonalInfoScreen)
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (_) => const CombinedRedirector()),
//       );
//       debugPrint('Navigated to CombinedRedirector at ${DateTime.now()}');
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//  @override
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.white, // Keeps background white
//     body: Stack(
//       children: [
//         // White background (full screen)
//         const SizedBox.expand(),

//         // Video with fade-in when initialized
//         AnimatedOpacity(
//           opacity: _videoInitialized ? 1.0 : 0.0,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//           child: _videoInitialized ? buildVideoPlayer() : const SizedBox.expand(),
//         ),
//       ],
//     ),
//   );
// }


// Widget buildVideoPlayer() {
//   return Center(
//     child: LayoutBuilder(
//       builder: (context, constraints) {
//         return SizedBox(
//           width: constraints.maxWidth,
//           height: constraints.maxHeight,
//           child: FittedBox(
//             fit: BoxFit.cover,
//             child: SizedBox(
//               width: _controller.value.size.width,
//               height: _controller.value.size.height,
//               child: VideoPlayer(_controller),
//             ),
//           ),
//         );
//       },
//     ),
//   );
// }


// }


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _initializationDone = false;
  bool _minimumDisplayDone = false;

  @override
  void initState() {
    super.initState();
    _startInitialization();
    _startMinimumDisplayTimer();
  }

  // Simulates 2s minimum display of the splash image
  void _startMinimumDisplayTimer() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _minimumDisplayDone = true);
      _checkNavigationReady();
    }
  }

  void _startInitialization() async {
    try {
      await Future.wait([
        _initHiveBoxes(),
        _checkAmplifyAuth(),
      ]);
    } catch (e) {
      debugPrint("Initialization error: $e");
    }

    if (mounted) {
      setState(() => _initializationDone = true);
      _checkNavigationReady();
    }
  }

  void _checkNavigationReady() {
    if (_initializationDone && _minimumDisplayDone) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CombinedRedirector()),
      );
    }
  }

  // You can customize these further
  Future<void> _initHiveBoxes() async {
    if (!Hive.isBoxOpen('profileBox')) {
      await Hive.openBox('profileBox');
    }
  }

  Future<void> _checkAmplifyAuth() async {
    if (!Amplify.isConfigured) return;

    try {
      await Amplify.Auth.fetchAuthSession();
    } on AuthException catch (e) {
      safePrint('Auth error in splash: ${e.message}');
    } catch (e) {
      safePrint('Unknown error in splash: $e');
    }
  }

  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SizedBox.expand(
      child: Image.asset(
        'assets/images/logo_vibrant_minds.jpg',
        fit: BoxFit.cover, 
      ),
    ),
  );
}

}
