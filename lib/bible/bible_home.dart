import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class BibleHome extends StatefulWidget {
  const BibleHome({super.key});

  @override
  State<BibleHome> createState() => _BibleHomeState();
}

class _BibleHomeState extends State<BibleHome> {
  List _books = [];

  @override
  void initState() {
    super.initState();
    _loadBibleData();
  }

  // Local assets nundi data load chesthunnam
  Future<void> _loadBibleData() async {
    try {
      final String response = await rootBundle.loadString('assets/bible_data.json');
      final data = await json.decode(response);
      setState(() {
        _books = data['books'];
      });
    } catch (e) {
      debugPrint("Error loading Bible data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("పరిశుద్ధ గ్రంథము", 
          style: GoogleFonts.balooTammudu2(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _books.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _books.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _books[index]['name'],
                    style: GoogleFonts.balooTammudu2(fontSize: 20, color: Colors.white),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // Navigate to Chapters page
                  },
                );
              },
            ),
    );
  }
}
