import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodTrackerScreen extends StatelessWidget {
  const MoodTrackerScreen({super.key});

  void _saveMood(BuildContext context, int score) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final today = DateTime.now().toIso8601String().split('T')[0];
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('moods').doc(today).set({
      'score': score, 'timestamp': FieldValue.serverTimestamp()
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mood saved!")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("How are you feeling?")),
        body: Center(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          for (int i = 1; i <= 5; i++)
            GestureDetector(onTap: () => _saveMood(context, i), child: Column(children: [
              Text(['😞', '😕', '😐', '🙂', '😄'][i-1], style: const TextStyle(fontSize: 40)),
              Text("Score $i")
            ]))
        ]))
    );
  }
}