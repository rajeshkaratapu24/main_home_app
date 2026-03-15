import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final String adminEmail = "rajeshkaratapu24@gmail.com"; // Nee Gmail ID ikkada pettu

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Security Check: Login ayina user nuvvu kaakapothe access ivvadhu
    if (user == null || user.email != adminEmail) {
      return const Scaffold(
        body: Center(child: Text("Access Denied! Admin only.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("WOG Admin Portal"), centerTitle: true),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _adminCard(Icons.album, "Albums", () => _navigate("albums")),
          _adminCard(Icons.music_note, "Songs", () => _navigate("songs")),
          _adminCard(Icons.library_books, "Books", () => _navigate("books")),
          _adminCard(Icons.mic, "Audio Messages", () => _navigate("audios")),
        ],
      ),
    );
  }

  Widget _adminCard(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _navigate(String type) {
    // Ikkada nuvvu select chesina section ki navigate chestham
  }
}
