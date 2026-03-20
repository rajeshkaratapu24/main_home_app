import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bible_utils.dart';

class BibleSearch extends StatefulWidget {
  final XmlDocument document;
  final String currentBook;
  const BibleSearch({super.key, required this.document, required this.currentBook});

  @override
  State<BibleSearch> createState() => _BibleSearchState();
}

class _BibleSearchState extends State<BibleSearch> {
  List<Map<String, dynamic>> searchResults = [];
  final TextEditingController _controller = TextEditingController();

  void _search(String query) {
    if (query.isEmpty || query.length < 2) return;
    List<Map<String, dynamic>> results = [];
    final books = widget.document.findAllElements('BIBLEBOOK');
    for (var book in books) {
      String bName = book.getAttribute('bname')!;
      for (var chapter in book.findAllElements('CHAPTER')) {
        String cNum = chapter.getAttribute('cnumber')!;
        int vIdx = 0;
        for (var verse in chapter.findAllElements('VERS')) {
          if (verse.innerText.contains(query)) {
            results.add({
              'book': bName,
              'chapter': cNum,
              'vNum': verse.getAttribute('vnumber'),
              'text': verse.innerText.trim(),
              'vIndex': vIdx, // వచనానికి వెళ్లడానికి ఇండెక్స్
            });
          }
          vIdx++;
        }
      }
    }
    setState(() => searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "Search here...", border: InputBorder.none),
          onChanged: _search,
        ),
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, i) => ListTile(
          title: Text("${BibleUtils.teluguBooks[searchResults[i]['book']]} ${searchResults[i]['chapter']}:${searchResults[i]['vNum']}", style: const TextStyle(color: Colors.blueAccent)),
          subtitle: Text(searchResults[i]['text'], style: GoogleFonts.balooTammudu2(color: Colors.white70)),
          onTap: () => Navigator.pop(context, searchResults[i]), // డేటాని బ్యాక్ పంపిస్తుంది
        ),
      ),
    );
  }
}
