import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';

class BibleSearch extends StatefulWidget {
  final XmlDocument document;
  final String currentBook;
  const BibleSearch({super.key, required this.document, required this.currentBook});

  @override
  State<BibleSearch> createState() => _BibleSearchState();
}

class _BibleSearchState extends State<BibleSearch> {
  String _query = "";
  String _filter = "సర్వ గ్రంథము"; // Default Filter
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  // నిబంధనల విభజన (Search Filter కోసం)
  final List<String> oldTestament = [
    "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth", 
    "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra", 
    "Nehemiah", "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes", "Song of Solomon", 
    "Isaiah", "Jeremiah", "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos", 
    "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah", "Haggai", "Zechariah", "Malachi"
  ];

  void _performSearch() {
    if (_query.length < 2) return;
    setState(() => _isSearching = true);

    List<Map<String, dynamic>> results = [];
    final books = widget.document.findAllElements('BIBLEBOOK');

    for (var book in books) {
      String bname = book.getAttribute('bname') ?? "";
      
      // ఫిల్టర్ కండిషన్స్
      if (_filter == "పాత నిబంధన" && !oldTestament.contains(bname)) continue;
      if (_filter == "క్రొత్త నిబంధన" && oldTestament.contains(bname)) continue;
      if (_filter == "ఈ గ్రంథము" && bname != widget.currentBook) continue;

      final chapters = book.findAllElements('CHAPTER');
      for (var chapter in chapters) {
        String cnum = chapter.getAttribute('cnumber') ?? "";
        final verses = chapter.findAllElements('VERS');
        for (var verse in verses) {
          String vnum = verse.getAttribute('vnumber') ?? "";
          String text = verse.innerText;

          if (text.contains(_query)) {
            results.add({
              'book': bname,
              'chapter': cnum,
              'verse': vnum,
              'text': text,
            });
          }
        }
      }
    }

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "వెతకండి...",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (val) => _query = val,
          onSubmitted: (val) => _performSearch(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _performSearch),
        ],
      ),
      body: Column(
        children: [
          // ఫిల్టర్ ఆప్షన్స్ (Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: ["సర్వ గ్రంథము", "పాత నిబంధన", "క్రొత్త నిబంధన", "ఈ గ్రంథము"].map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(f, style: TextStyle(color: _filter == f ? Colors.black : Colors.white)),
                    selected: _filter == f,
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white10,
                    onSelected: (bool selected) {
                      setState(() { _filter = f; _performSearch(); });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          // రిజల్ట్స్ కౌంట్
          if (_searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("${_searchResults.length} ఫలితాలు దొరికాయి", style: const TextStyle(color: Colors.grey)),
            ),
          // రిజల్ట్స్ లిస్ట్
          Expanded(
            child: _isSearching 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final res = _searchResults[index];
                    return ListTile(
                      title: Text("${res['book']} ${res['chapter']}:${res['verse']}", 
                        style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      subtitle: Text(res['text'], 
                        style: GoogleFonts.balooTammudu2(color: Colors.white70, fontSize: 16)),
                      onTap: () {
                        // క్లిక్ చేస్తే ఆ వర్స్ కి వెళ్ళే లాజిక్
                        Navigator.pop(context, res);
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
