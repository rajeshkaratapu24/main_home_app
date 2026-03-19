import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'upload_book.dart'; // అప్‌లోడ్ పేజీకి వెళ్ళడానికి

class AdminBooks extends StatefulWidget {
  const AdminBooks({super.key});

  @override
  State<AdminBooks> createState() => _AdminBooksState();
}

class _AdminBooksState extends State<AdminBooks> {
  // పుస్తకాన్ని డిలీట్ చేసే ఫంక్షన్
  Future<void> _deleteBook(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('books').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("పుస్తకం డిలీట్ చేయబడింది!"), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // డిలీట్ చేసే ముందు కన్ఫర్మేషన్ అడిగే డైలాగ్
  void _confirmDelete(String docId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Delete Book?", style: TextStyle(color: Colors.white)),
        content: Text("మీరు '$title' పుస్తకాన్ని డిలీట్ చేయాలనుకుంటున్నారా?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBook(docId);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("MANAGE BOOKS", style: TextStyle(color: Colors.white, letterSpacing: 2)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("పుస్తకాలు ఏమీ లేవు", style: TextStyle(color: Colors.white54)));
          }

          var books = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: books.length,
            itemBuilder: (context, index) {
              var bookData = books[index].data() as Map<String, dynamic>;
              String docId = books[index].id;
              String title = bookData['title'] ?? 'No Title';

              return Card(
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      bookData['coverUrl'] ?? '',
                      width: 50, height: 70, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.book, color: Colors.white24),
                    ),
                  ),
                  title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(bookData['author'] ?? 'Unknown', style: const TextStyle(color: Colors.white54)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(docId, title),
                  ),
                ),
              );
            },
          );
        },
      ),
      // కొత్త బుక్ అడ్ చేయడానికి బటన్
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadBook())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
