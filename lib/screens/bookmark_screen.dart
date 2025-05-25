import 'package:flutter/material.dart';
import '../../theme/vibrant_theme.dart';

class BookmarkScreen extends StatelessWidget {
  final List<String> bookmarks = [
    'How to improve your Flutter animations',
    'Understanding Firebase Firestore rules',
    'Top 10 Dart tips for productivity',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: bookmarks.isEmpty
          ? const Center(
        child: Text(
          'No bookmarks yet!',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            child: ListTile(
              title: Text(
                bookmarks[index],
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  // Handle remove bookmark
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
