import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:user_end/splash_screen.dart';

import 'firebase_options.dart';
import 'amplifyconfiguration.dart';
import 'services/firestore_service.dart';
import 'theme/vibrant_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('profileBox');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _configureAmplify();

  runApp(const AuthApp());
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

class AuthApp extends StatelessWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>(
          create: (_) => FirestoreService(FirebaseFirestore.instance),
        ),
      ],
      child: Authenticator(child: const MyApp()),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vibrant Minds App',
      theme: VibrantTheme.themeData,
      builder: Authenticator.builder(),
      home: const SplashScreen(),
    );
  }
}