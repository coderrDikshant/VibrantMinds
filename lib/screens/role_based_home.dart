import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../utils/jwt_utils.dart';


class RoleBasedHome extends StatefulWidget {
  const RoleBasedHome({super.key});

  @override
  State<RoleBasedHome> createState() => _RoleBasedHomeState();
}

class _RoleBasedHomeState extends State<RoleBasedHome> {
  String? userGroup;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserGroup();
  }

  Future<void> _loadUserGroup() async {
  try {
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
    final idToken = session.userPoolTokensResult.value.idToken;
    final decoded = parseJwt(idToken.raw);
    final groups = decoded['cognito:groups'] as List<dynamic>?;

    if (groups != null) {
      if (groups.contains('Inappropriate_group')) {
        userGroup = 'Inappropriate_group';

        // Show alert and sign out
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text('Access Denied'),
              content: const Text(
                'Your account is restricted. Please contact VibrantMinds for support.',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close dialog
                    await Amplify.Auth.signOut(); // Sign out
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        });
      } 

      else if (groups.contains('Course_enroll')) {
        userGroup = 'Group Enroller';
      } else if (groups.contains('Open_drive')) {
        userGroup = 'Non Enroller';
      } else {
        userGroup = 'Unknown Group';
      }
    } else {
      userGroup = 'No Group Assigned';
    }
  } catch (e) {
    safePrint('Error fetching group: $e');
    userGroup = 'Error fetching group';
  } finally {
    setState(() {
      loading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // if (userGroup == 'Admin') {
    //   return const AdminDashboard();
    // }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await Amplify.Auth.signOut();
              } catch (e) {
                safePrint('Logout failed: $e');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'You are a $userGroup',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}