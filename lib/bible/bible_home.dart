import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';

class BibleHome extends StatefulWidget {
  const BibleHome({super.key});

  @override
  State<BibleHome> createState() => _BibleHomeState();
}

class _BibleHomeState extends State<BibleHome> {
  List<String> _books = [];
  bool _isLoading = true;
  String _debugInfo = ""; // Debugging info chupinchadaniki

  @override
  void initState() {
    super.initState();
    _loadBibleData();
  }

  Future<void> _loadBibleData() async {
    try {
      // 1. Load XML File
      final String xmlString = await rootBundle.loadString('assets/bible.xml');
      
      // 2. Parse XML
      final document = XmlDocument.parse(xmlString);
      
      // 3. Trying multiple tag names (Common in Bible XMLs: 'book', 'B', 'v')
      Iterable<XmlElement> bookElements = document.findAllElements('book');
      if (bookElements.isEmpty) {
        bookElements = document.findAllElements('B'); // Konni XMLs lo <B> ani untundi
      }

      List<String> tempBooks = [];
      for (var element in bookElements) {
        // Look for attributes: 'name', 'n', 'title'
        String? name = element.getAttribute('name') ?? 
                       element.getAttribute('n') ?? 
                       element.getAttribute('title');
        
        if (name != null) {
          tempBooks.add(name);
        } else if (element.innerText.trim().isNotEmpty) {
          tempBooks.add(element.innerText.trim());
        }
      }

      setState(() {
        _books = tempBooks;
        _isLoading = false;
        if (_books.isEmpty) {
          _debugInfo = "File loaded but no books found. Check XML Tags!";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _debugInfo = "Error: $e\n\nTips: Check if 'assets/bible.xml' is spelled correctly in GitHub.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("పరిశుద్ధ గ్రంథము", style: GoogleFonts.balooTammudu2(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _debugInfo.isNotEmpty
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(_debugInfo, style: const TextStyle(color: Colors.red, fontSize: 14), textAlign: TextAlign.center),
                ))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _books.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_books[index], style: GoogleFonts.balooTammudu2(fontSize: 18, color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    );
                  },
                ),
    );
  }
}
