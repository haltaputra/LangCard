// my_vocab_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyVocabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User belum login')));
    }

    final vocabStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('vocabularies')
        .where('isMastered', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Kosakata Saya')),
      body: StreamBuilder<QuerySnapshot>(
        stream: vocabStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('Belum ada kosakata yang dikuasai.'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final vocab = docs[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text(vocab['word'] ?? ''),
                subtitle: Text(vocab['translation'] ?? ''),
                trailing: Text(vocab['category'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
