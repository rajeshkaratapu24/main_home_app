import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'bible_search.dart'; // Search page import

class BibleHome extends StatefulWidget {
  const BibleHome({super.key});

  @override
  State<BibleHome> createState() => _BibleHomeState();
}

class _BibleHomeState extends State<BibleHome> {
  XmlDocument? _document;
  String selectedBook = "Genesis";
  String selectedChapter = "1";
  List<String> books = [];
  List<String> chapters = [];
  List<Map<String, String>> verses = [];
  Set<int> selectedVerseIndices = {}; // Verses select cheskovadaniki

  @override
  void initState() {
    super.initState();
    _loadBible();
  }

  // XML Load chese logic
  Future<void> _loadBible() async {
    try {
      final String xmlString = await rootBundle.loadString('assets/bible.xml');
      _document = XmlDocument.parse(xmlString);
      final bookElements = _document!.findAllElements('BIBLEBOOK');
      
      setState(() {
        books = bookElements.map((e) => e.getAttribute('bname')!).toList();
        _updateChapters(selectedBook);
      });
    } catch (e) {
      debugPrint("Error loading XML: $e");
    }
  }

  // Chapters list update cheyyadam
  void _updateChapters(String bookName) {
    final book = _document!.findAllElements('BIBLEBOOK').firstWhere(
      (e) => e.getAttribute('bname') == bookName
    );
    chapters = book.findAllElements('CHAPTER').map((e) => e.getAttribute('cnumber')!).toList();
    selectedChapter = chapters.first;
    _updateVerses(bookName, selectedChapter);
  }

  // Verses list update cheyyadam
  void _updateVerses(String bookName, String chapterNum) {
    final book = _document!.findAllElements('BIBLEBOOK').firstWhere(
      (e) => e.getAttribute('bname') == bookName
    );
    final chapter = book.findAllElements('CHAPTER').firstWhere(
      (e) => e.getAttribute('cnumber') == chapterNum
    );
    setState(() {
      verses = chapter.findAllElements('VERS').map((e) => {
        'num': e.getAttribute('vnumber')!,
        'text': e.innerText.trim()
      }).toList();
      selectedVerseIndices.clear(); // Chapter marinappudu selection clear chesthunnam
    });
  }

  // Sharing logic
  void _shareVerses() {
    String textToShare = "$selectedBook $selectedChapter\n\n";
    var sortedIndices = selectedVerseIndices.toList()..sort();
    for (var index in sortedIndices) {
      textToShare += "${verses[index]['num']}. ${verses[index]['text']}\n";
    }
    textToShare += "\nShared by WORLD OF GOD App";
    Share.share(textToShare);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: _buildSelectors(),
        actions: [
          // Search Button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              if (_document == null) return;
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BibleSearch(
                    document: _document!,
                    currentBook: selectedBook,
                  ),
                ),
              );

              if (result != null) {
                setState(() {
                  selectedBook = result['book'];
                  _updateChapters(selectedBook);
                  selectedChapter = result['chapter'];
                  _updateVerses(selectedBook, selectedChapter);
                });
              }
            },
          ),
          // Share & Bookmark Buttons (Selection unnapude kanipisthayi)
          if (selectedVerseIndices.isNotEmpty) ...[
            IconButton(icon: const Icon(Icons.share), onPressed: _shareVerses),
            IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bookmarked!")));
            }),
          ]
        ],
      ),
      body: verses.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: verses.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedVerseIndices.contains(index);
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: Colors.white10,
                  onLongPress: () {
                    setState(() => selectedVerseIndices.add(index));
                  },
                  onTap: () {
                    if (selectedVerseIndices.isNotEmpty) {
                      setState(() {
                        isSelected ? selectedVerseIndices.remove(index) : selectedVerseIndices.add(index);
                      });
                    }
                  },
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${verses[index]['num']}. ",
                          style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        TextSpan(
                          text: verses[index]['text']!,
                          style: GoogleFonts.balooTammudu2(fontSize: 19, color: Colors.white, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // AppBar lo Book, Chapter Dropdowns
  Widget _buildSelectors() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _customDropdown(books, selectedBook, (val) {
            setState(() {
              selectedBook = val!;
              _updateChapters(val);
            });
          }),
          const SizedBox(width: 15),
          _customDropdown(chapters, selectedChapter, (val) {
            setState(() {
              selectedChapter = val!;
              _updateVerses(selectedBook, val);
            });
          }),
        ],
      ),
    );
  }

  Widget _customDropdown(List<String> items, String value, Function(String?) onChanged) {
    return DropdownButton<String>(
      value: items.contains(value) ? value : items.first,
      dropdownColor: const Color(0xFF1A1A1A),
      style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
