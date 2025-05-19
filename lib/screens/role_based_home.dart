import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../widgets/success_stories.dart';
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
      bottomNavigationBar: Container(
        height: 60,
        decoration : BoxDecoration(
          color: Color(0xFFFE2E00),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children :[
            IconButton(
              enableFeedback: false,
             onPressed: () {},
             icon:const Icon(
              Icons.home_outlined,
              color: Colors.white,
              size: 35,
             )
             ),
             IconButton(
              enableFeedback: false,
             onPressed: () {},
             icon:const Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 35,
             )
             ),
             IconButton(
              enableFeedback: false,
             onPressed: () {
              Navigator.push(context, 
              MaterialPageRoute(builder: (content) => SuccessStoryPage()),
              );
             },
             icon:const Icon(
             Icons.star_outline,
              color: Colors.white,
              size: 35,
             )
             ),
             IconButton(
              enableFeedback: false,
             onPressed: () {},
             icon:const Icon(
              Icons.work_outline,
              color: Colors.white,
              size: 35,
             )
             )
          ],
        )
      ),
      body: const Center(
        child: Text("Welcome to the dashboard!"),
      ),
    );
  }
}
