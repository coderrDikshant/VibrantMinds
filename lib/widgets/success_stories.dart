import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuccessStoryPage extends StatelessWidget {
  const SuccessStoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Success Stories'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('success_stories')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final stories = snapshot.data?.docs ?? [];

          if (stories.isEmpty) {
            return const Center(child: Text('No success stories found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   if (story['imageUrl'] != null && story['imageUrl'].toString().isNotEmpty)
  ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
    child: Center(
      child: SizedBox(
        height: 200,
        child: Image.network(
          story['imageUrl'],
          fit: BoxFit.fitHeight,  // fixed height, width adjusts automatically
        ),
      ),
    ),
  ),




                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story['title'] ?? 'No Title',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            story['description'] ?? 'No Description',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
