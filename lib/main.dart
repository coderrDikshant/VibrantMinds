import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';

import 'firebase_options.dart';
import 'amplifyconfiguration.dart';
import 'services/firestore_service.dart';
import 'widgets/profile_cards/profile_redirector.dart';
import 'theme/vibrant_theme.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // These initializations still run first, hiding the native splash screen.
  // The '2-second' delay you observed after the native splash screen was
  // likely the Authenticator's initial session check, which we'll now
  // handle within the Flutter SplashScreen.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _configureAmplify();

  runApp(
    MultiProvider(
      providers: [
        Provider<FirestoreService>(
          create: (_) => FirestoreService(FirebaseFirestore.instance),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _configureAmplify() async {
  try {
    if (!Amplify.isConfigured) {
      await Amplify.addPlugin(AmplifyAuthCognito());
      await Amplify.configure(amplifyconfig);
      safePrint('Amplify configured successfully');
    } else {
      safePrint('Amplify already configured');
    }
  } on AmplifyException catch (e) {
    safePrint('Amplify configuration error: ${e.message}');
  } catch (e) {
    safePrint('Generic configuration error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We keep Authenticator here. The SplashScreen will ensure all
    // loading is done before handing off control for actual authentication flow.
    return Authenticator(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vibrant Minds App',
        theme: VibrantTheme.themeData,
        // The Authenticator.builder() handles the navigation to sign-in/signed-in views
        // based on the auth state, *after* the SplashScreen is done.
        builder: Authenticator.builder(),
        home:
            const SplashScreen(), // The app still starts with your custom splash screen
      ),
    );
  }
}

class CombinedRedirector extends StatelessWidget {
  const CombinedRedirector({super.key});

  @override
  Widget build(BuildContext context) {
    // This will be the first screen shown after the splash screen and
    // after the Authenticator has processed its initial state.
    return const ProfileRedirector();
  }
}
