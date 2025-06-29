// add_vocabulary.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddVocabularyPage extends StatelessWidget {
  final TextEditingController wordController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final String selectedLanguage = 'en'; // bahasa default (english)

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kosakata')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: wordController,
              decoration: const InputDecoration(labelText: 'Kata'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (wordController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty &&
                    user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('vocabularies')
                      .add({
                        'word': wordController.text,
                        'language': selectedLanguage,
                        'category': categoryController.text,
                        'translation': '',
                        'isMastered': false,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
