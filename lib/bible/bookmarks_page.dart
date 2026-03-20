import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Map<String, dynamic>> _bookmarkList = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bible_bookmarks') ?? [];
    setState(() {
      _bookmarkList = bookmarks.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _deleteBookmark(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bible_bookmarks') ?? [];
    bookmarks.removeAt(index);
    await prefs.setStringList('bible_bookmarks', bookmarks);
    _loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("S A V E D", style: TextStyle(color: Colors.white, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: _bookmarkList.isEmpty
          ? const Center(child: Text("No bookmarks saved yet.", style: TextStyle(color: Colors.white30)))
          : ListView.builder(
              itemCount: _bookmarkList.length,
              itemBuilder: (context, index) {
                final item = _bookmarkList[index];
                return Card(
                  color: Colors.white10,
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text("${item['book']} ${item['chapter']}:${item['num']}", 
                        style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    subtitle: Text(item['text'], 
                        style: GoogleFonts.balooTammudu2(color: Colors.white70, fontSize: 16)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _deleteBookmark(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
