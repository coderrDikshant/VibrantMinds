import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class RoleBasedHome extends StatelessWidget {
  const RoleBasedHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await Amplify.Auth.signOut();
              } catch (e) {
                safePrint("Sign out error: $e");
              }
            },
          )
        ],
      ),
      body: const Center(
        child: Text("Welcome to the dashboard!"),
      ),
    );
  }
}
