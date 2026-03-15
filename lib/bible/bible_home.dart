import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart'; // pubspec లో add చెయ్

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
  Set<int> selectedVerseIndices = {}; // Multiple Selection కోసం

  @override
  void initState() {
    super.initState();
    _loadBible();
  }

  Future<void> _loadBible() async {
    final xmlString = await rootBundle.loadString('assets/bible.xml');
    _document = XmlDocument.parse(xmlString);
    final bookElements = _document!.findAllElements('BIBLEBOOK');
    setState(() {
      books = bookElements.map((e) => e.getAttribute('bname')!).toList();
      _updateChapters(selectedBook);
    });
  }

  void _updateChapters(String bookName) {
    final book = _document!.findAllElements('BIBLEBOOK').firstWhere((e) => e.getAttribute('bname') == bookName);
    chapters = book.findAllElements('CHAPTER').map((e) => e.getAttribute('cnumber')!).toList();
    selectedChapter = chapters.first;
    _updateVerses(bookName, selectedChapter);
  }

  void _updateVerses(String bookName, String chapterNum) {
    final book = _document!.findAllElements('BIBLEBOOK').firstWhere((e) => e.getAttribute('bname') == bookName);
    final chapter = book.findAllElements('CHAPTER').firstWhere((e) => e.getAttribute('cnumber') == chapterNum);
    setState(() {
      verses = chapter.findAllElements('VERS').map((e) => {'num': e.getAttribute('vnumber')!, 'text': e.innerText.trim()}).toList();
      selectedVerseIndices.clear();
    });
  }

  void _shareVerses() {
    String textToShare = "$selectedBook $selectedChapter\n";
    for (var index in selectedVerseIndices) {
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
        backgroundColor: Colors.black87,
        title: _buildSelectors(),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () { /* Search Logic */ }),
          if (selectedVerseIndices.isNotEmpty) ...[
            IconButton(icon: const Icon(Icons.share), onPressed: _shareVerses),
            IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          ]
        ],
      ),
      body: verses.isEmpty 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView.builder(
            itemCount: verses.length,
            itemBuilder: (context, index) {
              bool isSelected = selectedVerseIndices.contains(index);
              return ListTile(
                selected: isSelected,
                selectedTileColor: Colors.white10,
                onLongPress: () => setState(() => selectedVerseIndices.add(index)),
                onTap: () {
                  if (selectedVerseIndices.isNotEmpty) {
                    setState(() => isSelected ? selectedVerseIndices.remove(index) : selectedVerseIndices.add(index));
                  }
                },
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: "${verses[index]['num']}. ", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      TextSpan(text: verses[index]['text']!, style: GoogleFonts.balooTammudu2(fontSize: 18, color: Colors.white)),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildSelectors() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _customDropdown(books, selectedBook, (val) => setState(() { selectedBook = val!; _updateChapters(val); })),
          const SizedBox(width: 10),
          _customDropdown(chapters, selectedChapter, (val) => setState(() { selectedChapter = val!; _updateVerses(selectedBook, val); })),
        ],
      ),
    );
  }

  Widget _customDropdown(List<String> items, String value, Function(String?) onChanged) {
    return DropdownButton<String>(
      value: value,
      dropdownColor: Colors.black,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      underline: const SizedBox(),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
