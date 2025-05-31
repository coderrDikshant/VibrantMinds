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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final api_key = 'AIzaSyANcLW4GibTK4q29-9TP77chbhEPpik34k';
 
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
        theme: VibrantTheme.themeData, 
        builder: Authenticator.builder(), 
        home: const CombinedRedirector(),
      ),
    );
  }
}

class CombinedRedirector extends StatelessWidget {
  const CombinedRedirector({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileRedirector(); 
  }
}
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import '../../widgets/profile_cards/experience_section.dart'; // Import your EducationSection file

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Education Section Debug',
//       theme: ThemeData(
//         primaryColor: Colors.orange[700],
//         colorScheme: ColorScheme.fromSwatch(
//           primarySwatch: Colors.orange,
//           accentColor: Colors.orangeAccent,
//           backgroundColor: Colors.grey[100],
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.orange[300]!),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.orange[300]!),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.orange[700]!, width: 2),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.red[700]!),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.red[700]!, width: 2),
//           ),
//           labelStyle: TextStyle(color: Colors.orange[900]),
//           filled: true,
//           fillColor: Colors.white,
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.orange[700],
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Debug Education Section'),
//           backgroundColor: Colors.orange[700],
//         ),
//         body: ExperienceSection(
//           onSaved: (data) {
//             // Mock callback to print form data for debugging
//             print('Saved Education Data: $data');
//           },
//         ),
//       ),
//     );
//   }
// }