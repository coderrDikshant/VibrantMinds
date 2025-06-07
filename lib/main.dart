import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';

import 'firebase_options.dart';
import 'amplifyconfiguration.dart';
import 'utils/jwt_utils.dart';
import 'screens/profile_screens/role_based_home.dart';
import 'widgets/profile_cards/personal_info_section.dart';
import 'package:provider/provider.dart';
import 'services/firestore_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('profileBox');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _configureAmplify();

  runApp(const AuthApp());
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    safePrint('Amplify configuration failed: $e');
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
        // Add other providers if needed
      ],
      child: Authenticator(
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: Authenticator.builder(),
      debugShowCheckedModeBanner: false,
      home: const LandingScreen(),
    );
  }
}

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  String _email = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
  try {
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
    final idToken = session.userPoolTokensResult.value.idToken;
    final decoded = parseJwt(idToken.raw);

    final email = decoded['email'] ?? '';
    final groups = decoded['cognito:groups'] as List<dynamic>? ?? [];
    final isEnrolled = groups.contains('Course_enroll');

    final profileBox = Hive.box('profileBox');
    await profileBox.put('isCourseEnrolled', isEnrolled); // Save it locally
  
  await Hive.openBox('jobCacheBox');
    setState(() {
      _email = email;
      _loading = false;
    });
  } catch (e) {
    safePrint('Error loading email: $e');
    setState(() => _loading = false);
  }
}



  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profileBox = Hive.box('profileBox');
    final personalInfo = profileBox.get('personalInfo');

    if (personalInfo is Map && personalInfo['firstName'] != null) {
      return RoleBasedHome(
        firstName: personalInfo['firstName'] ?? '',
        lastName: personalInfo['lastName'] ?? '',
      );
    }

    return PersonalInfoScreen(email: _email);
  }}
