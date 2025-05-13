import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../screens/role_based_home.dart';
import '../screens/complete_profile_screen.dart';
import '../utils/jwt_utils.dart';

class ProfileRedirector extends StatefulWidget {
  const ProfileRedirector({super.key});

  @override
  State<ProfileRedirector> createState() => _ProfileRedirectorState();
}

class _ProfileRedirectorState extends State<ProfileRedirector> {
  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
  try {
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
    final idToken = session.userPoolTokensResult.value.idToken;
    final decoded = parseJwt(idToken.raw);
    final email = decoded['email'];

    // ⬇️ Use POST to send the expected structure
    final response = await http.post(
      Uri.parse('https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/User_exist/User_profile_exist'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "httpMethod": "GET",
        "queryStringParameters": {
          "email": email
        }
      }),
    );

    safePrint("📡 Status: ${response.statusCode}");
    safePrint("📄 Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(jsonDecode(response.body)['body']);
      final profileComplete = data['profileComplete'];

      if (profileComplete == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleBasedHome()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CompleteProfileScreen(email: email)),
        );
      }
    } else {
      safePrint("❌ Error: Profile API failed");
    }
  } catch (e) {
    safePrint("⚠️ Exception: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
