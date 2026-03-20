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
      final chapters = book.findAllElements('CHAPTER');
      for (var chapter in chapters) {
        String cNum = chapter.getAttribute('cnumber')!;
        final verses = chapter.findAllElements('VERS');
        int vIdx = 0;
        for (var verse in verses) {
          String vText = verse.innerText;
          if (vText.contains(query)) {
            results.add({
              'book': bName,
              'chapter': cNum,
              'vNum': verse.getAttribute('vnumber'),
              'text': vText.trim(),
              'vIndex': vIdx, // Reading page లో ఆ వచనానికి వెళ్లడానికి
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
          decoration: const InputDecoration(hintText: "Search Bible...", hintStyle: TextStyle(color: Colors.white30), border: InputBorder.none),
          onChanged: _search,
        ),
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, i) {
          final res = searchResults[i];
          return ListTile(
            title: Text("${BibleUtils.teluguBooks[res['book']]} ${res['chapter']}:${res['vNum']}", 
                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            subtitle: Text(res['text'], style: GoogleFonts.balooTammudu2(color: Colors.white70)),
            // క్లిక్ చేయగానే డేటాతో సహా వెనక్కి వెళ్తుంది
            onTap: () => Navigator.pop(context, res), 
          );
        },
      ),
    );
  }
}
