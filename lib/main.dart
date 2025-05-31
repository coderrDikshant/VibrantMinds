import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';

// Local imports
import 'firebase_options.dart';
import 'amplifyconfiguration.dart';
import 'services/firestore_service.dart';
import 'widgets/profile_cards/profile_redirector.dart'; // Main app landing screen
import 'theme/vibrant_theme.dart'; // ✅ Your custom theme

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final api_key = 'AIzaSyANcLW4GibTK4q29-9TP77chbhEPpik34k';
  // Initialize Amplify
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
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    safePrint('Amplify error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vibrant Minds App',
        theme: VibrantTheme.themeData, // ✅ Use your theme here
        builder: Authenticator.builder(), // Required for Amplify Authenticator
        home: const CombinedRedirector(),
      ),
    );
  }
}

/// This widget decides which screen to show initially.
/// You can adjust this logic based on user roles or states.
class CombinedRedirector extends StatelessWidget {
  const CombinedRedirector({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileRedirector(); // Role-based redirect
  }
}
