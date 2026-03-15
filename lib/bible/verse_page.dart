import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';

class VersePage extends StatefulWidget {
  final String bookName;
  final String chapterNumber;
  const VersePage({super.key, required this.bookName, required this.chapterNumber});

  @override
  State<VersePage> createState() => _VersePageState();
}

class _VersePageState extends State<VersePage> {
  List<Map<String, String>> _verses = [];

  @override
  void initState() {
    super.initState();
    _loadVerses();
  }

  Future<void> _loadVerses() async {
    final String xmlString = await rootBundle.loadString('assets/bible.xml');
    final document = XmlDocument.parse(xmlString);
    final book = document.findAllElements('BIBLEBOOK').firstWhere((e) => e.getAttribute('bname') == widget.bookName);
    final chapter = book.findAllElements('CHAPTER').firstWhere((e) => e.getAttribute('cnumber') == widget.chapterNumber);
    setState(() {
      _verses = chapter.findAllElements('VERS').map((node) => {
        'num': node.getAttribute('vnumber') ?? '0',
        'text': node.innerText.trim()
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("${widget.bookName} ${widget.chapterNumber}"), backgroundColor: Colors.black),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _verses.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${_verses[index]['num']}. ", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                Expanded(child: Text(_verses[index]['text']!, style: GoogleFonts.balooTammudu2(fontSize: 18, color: Colors.white, height: 1.5))),
              ],
            ),
          );
        },
      ),
    );
  }
}
