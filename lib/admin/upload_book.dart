import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadBook extends StatefulWidget {
  const UploadBook({super.key});

  @override
  State<UploadBook> createState() => _UploadBookState();
}

class _UploadBookState extends State<UploadBook> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController coverController = TextEditingController();
  final TextEditingController contentController = TextEditingController(); // HTML Code కోసం
  bool isUploading = false;

  Future<void> uploadBook() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title and Content are required!")));
      return;
    }

    setState(() => isUploading = true);

    try {
      await FirebaseFirestore.instance.collection('books').add({
        'title': titleController.text,
        'author': authorController.text,
        'coverUrl': coverController.text,
        'content': contentController.text, // HTML కోడ్ ఇక్కడ సేవ్ అవుతుంది
        'rating': 5,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Book Uploaded Successfully!")));
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("UPLOAD BOOK"), backgroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(titleController, "Book Title"),
            const SizedBox(height: 15),
            _buildTextField(authorController, "Author Name"),
            const SizedBox(height: 15),
            _buildTextField(coverController, "Cover Image URL (GitHub Raw)"),
            const SizedBox(height: 15),
            // HTML Code పేస్ట్ చేసే బాక్స్
            TextField(
              controller: contentController,
              maxLines: 12,
              style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: "ఇక్కడ HTML కోడ్ పేస్ట్ చెయ్ బ్రో...",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),
            isUploading 
              ? const CircularProgressIndicator(color: Colors.purpleAccent)
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, minimumSize: const Size(double.infinity, 50)),
                  onPressed: uploadBook, 
                  child: const Text("SAVE BOOK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
