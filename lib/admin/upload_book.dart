import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadBook extends StatefulWidget {
  const UploadBook({super.key});

  @override
  State<UploadBook> createState() => _UploadBookState();
}

class _UploadBookState extends State<UploadBook> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController(text: "రాజా తాళ్లూరి");
  final TextEditingController _categoryController = TextEditingController(text: "Theology");
  final TextEditingController _coverUrlController = TextEditingController();
  final TextEditingController _bookUrlController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController(text: "5");

  bool _isLoading = false;

  Future<void> _saveBook() async {
    if (_titleController.text.isEmpty || _coverUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title and Cover Link are mandatory!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('books').add({
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'category': _categoryController.text.trim(),
        'coverUrl': _coverUrlController.text.trim(),
        'bookUrl': _bookUrlController.text.trim(),
        'rating': int.tryParse(_ratingController.text) ?? 5,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Book Uploaded Successfully!"), backgroundColor: Colors.green));
        _titleController.clear();
        _coverUrlController.clear();
        _bookUrlController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Upload New Book"), backgroundColor: Colors.black),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildField(_titleController, "Book Title", Icons.book),
          _buildField(_authorController, "Author Name", Icons.person),
          _buildField(_categoryController, "Category (Theology/Devotional)", Icons.category),
          _buildField(_coverUrlController, "Cover Image URL", Icons.image),
          _buildField(_bookUrlController, "Book HTML/PDF Link", Icons.link),
          _buildField(_ratingController, "Rating (1-5)", Icons.star),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, padding: const EdgeInsets.symmetric(vertical: 15)),
            onPressed: _isLoading ? null : _saveBook,
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SAVE BOOK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.purpleAccent),
          filled: true, fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
