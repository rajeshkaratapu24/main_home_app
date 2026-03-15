import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';
import 'verse_page.dart';

class ChapterPage extends StatefulWidget {
  final String bookName;
  final String bookId;
  const ChapterPage({super.key, required this.bookName, required this.bookId});

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  List<String> _chapters = [];

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final String xmlString = await rootBundle.loadString('assets/bible.xml');
    final document = XmlDocument.parse(xmlString);
    final book = document.findAllElements('BIBLEBOOK').firstWhere(
      (element) => element.getAttribute('bname') == widget.bookName
    );
    setState(() {
      _chapters = book.findAllElements('CHAPTER').map((node) => node.getAttribute('cnumber') ?? '0').toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.bookName), backgroundColor: Colors.black),
      body: GridView.builder(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _chapters.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => VersePage(bookName: widget.bookName, chapterNumber: _chapters[index]),
              ));
            },
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text(_chapters[index], style: const TextStyle(color: Colors.white))),
            ),
          );
        },
      ),
    );
  }
}
