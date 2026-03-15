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
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString('assets/bible_data.json');
      final data = await json.decode(response);
      setState(() => _books = data['books'] ?? []);
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("పరిశుద్ధ గ్రంథము"), backgroundColor: Colors.black),
      body: _books.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              itemCount: _books.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_books[index]['name'], style: const TextStyle(color: Colors.white)),
                  onTap: () {},
                );
              },
            ),
    );
  }
}
