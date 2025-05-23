import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../screens/profile_screens/role_based_home.dart';
import '../../screens/profile_screens/complete_profile_screen.dart';
import '../../utils/jwt_utils.dart';

class ProfileRedirector extends StatefulWidget {
  const ProfileRedirector({super.key});

  @override
  State<ProfileRedirector> createState() => _ProfileRedirectorState();
}

class _ProfileRedirectorState extends State<ProfileRedirector> {
  bool _isLoading = true;
  String? _errorMessage;

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

      final response = await http.post(
        Uri.parse('https://0tkvr567rk.execute-api.us-east-1.amazonaws.com/User_exist/User_profile_exist'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "httpMethod": "GET",
          "queryStringParameters": {"email": email}
        }),
      );

      safePrint("API Response Status: ${response.statusCode}");
      safePrint("API Response Body: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final data = jsonDecode(responseBody['body']);
        final profileComplete = data['profileComplete'] ?? false;

        if (profileComplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RoleBasedHome()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CompleteProfileScreen(email: email),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to verify profile status';
          _isLoading = false;
        });
      }
    } catch (e) {
      safePrint("Profile check error: $e");
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage ?? 'Unknown error',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _checkProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
      ),
    );
  }
}