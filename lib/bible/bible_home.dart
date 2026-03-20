import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bookmarks_page.dart'; // Kottha file create chestham

class BibleHome extends StatefulWidget {
  const BibleHome({super.key});
  static const Map<String, String> teluguBooks = {
    "Genesis": "ఆదికాండము", "Exodus": "నిర్గమకాండము", "Leviticus": "లేవీయకాండము",
    "Numbers": "సంఖ్యాకాండము", "Deuteronomy": "ద్వితీయోపదేశకాండము", "Joshua": "యెహోషువ",
    "Judges": "న్యాయాధిపతులు", "Ruth": "రూతు", "1 Samuel": "1 సమూయేలు",
    "2 Samuel": "2 సమూయేలు", "1 Kings": "1 రాజులు", "2 Kings": "2 రాజులు",
    "1 Chronicles": "1 దినవృత్తాంతములు", "2 Chronicles": "2 దినవృత్తాంతములు",
    "Ezra": "ఎజ్రా", "Nehemiah": "నెహెమ్యా", "Esther": "ఎస్తేరు",
    "Job": "యోబు", "Psalm": "కీర్తనలు", "Psalms": "కీర్తనలు",
    "Proverbs": "సామెతలు", "Ecclesiastes": "ప్రసంగి", "Song of Solomon": "పరమగీతము",
    "Isaiah": "యెషయా", "Jeremiah": "యిర్మీయా", "Lamentations": "విలాపవాక్యములు",
    "Ezekiel": "యెహెజ్కేలు", "Daniel": "దానియేలు", "Hosea": "హోషేయ",
    "Joel": "యోవేలు", "Amos": "ఆమోసు", "Obadiah": "ఓబద్యా",
    "Jonah": "యోనా", "Micah": "మీకా", "Nahum": "నహూము",
    "Habakkuk": "హబక్కుకు", "Zephaniah": "జెఫన్యా", "Haggai": "హగ్గయి",
    "Zechariah": "జెకర్యా", "Malachi": "మలాకీ", "Matthew": "మత్తయి",
    "Mark": "మార్కు", "Luke": "లూకా", "John": "యోహాను",
    "Acts": "అపొస్తలుల కార్యములు", "Romans": "రోమీయులకు", "1 Corinthians": "1 కొరింథీయులకు",
    "2 Corinthians": "2 కొరింథీయులకు", "Galatians": "గలతీయులకు", "Ephesians": "ఎఫెసీయులకు",
    "Philippians": "ఫిలిప్పీయులకు", "Colossians": "కొలొస్సయులకు", "1 Thessalonians": "1 థెస్సలొనీకయులకు",
    "2 Thessalonians": "2 థెస్సలొనీకయులకు", "1 Timothy": "1 తిమోతికి", "2 Timothy": "2 తిమోతికి",
    "Titus": "తీతుకు", "Philemon": "ఫిలేమోనుకు", "Hebrews": "హెబ్రీయులకు",
    "James": "యాకోబు", "1 Peter": "1 పేతురు", "2 Peter": "2 పేతురు",
    "1 John": "1 యోహాను", "2 John": "2 యోహాను", "3 John": "3 యోహాను",
    "Jude": "యూదా", "Revelation": "ప్రకటన గ్రంథము",
  };

  @override
  State<BibleHome> createState() => _BibleHomeState();
}

class _BibleHomeState extends State<BibleHome> {
  XmlDocument? _document;
  String selectedBook = "Genesis";
  String selectedChapter = "1";
  List<String> books = [];
  List<String> chapters = [];
  List<Map<String, dynamic>> verses = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadBible();
  }

  Future<void> _loadBible() async {
    try {
      final String xmlString = await rootBundle.loadString('assets/bible.xml');
      _document = XmlDocument.parse(xmlString);
      final bookElements = _document!.findAllElements('BIBLEBOOK');
      setState(() {
        books = bookElements.map((e) => e.getAttribute('bname')!).toList();
        if (books.isNotEmpty) {
          selectedBook = books.first;
          _updateChapters(selectedBook);
        }
      });
    } catch (e) { debugPrint("Error: $e"); }
  }

  void _updateChapters(String bookName) {
    if (_document == null) return;
    final book = _document!.findAllElements('BIBLEBOOK').firstWhere((e) => e.getAttribute('bname') == bookName);
    setState(() {
      chapters = book.findAllElements('CHAPTER').map((e) => e.getAttribute('cnumber')!).toList();
      if (chapters.isNotEmpty) {
        selectedChapter = chapters.first;
        _updateVerses(bookName, selectedChapter);
      }
    });
  }

  void _updateVerses(String bookName, String chapterNum) {
    if (_document == null) return;
    final bookElements = _document!.findAllElements('BIBLEBOOK').toList();
    int currentIdx = 0;
    for (var b in bookElements) {
      final bName = b.getAttribute('bname');
      for (var c in b.findAllElements('CHAPTER')) {
        final cNum = c.getAttribute('cnumber');
        if (bName == bookName && cNum == chapterNum) {
          setState(() {
            verses = c.findAllElements('VERS').map((e) {
              currentIdx++;
              return {'num': e.getAttribute('vnumber')!, 'text': e.innerText.trim(), 'globalId': currentIdx};
            }).toList();
          });
          return;
        }
        currentIdx += c.findAllElements('VERS').length;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("B I B L E", style: GoogleFonts.ubuntu(color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Bookmarks icon to view saved verses
          IconButton(icon: const Icon(Icons.bookmarks, color: Colors.blueAccent), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BookmarksPage()));
          }),
        ],
      ),
      body: books.isEmpty ? const Center(child: CircularProgressIndicator()) : Row(
        children: [
          Expanded(flex: 5, child: ListView.builder(itemCount: books.length, itemBuilder: (context, i) => ListTile(
            tileColor: selectedBook == books[i] ? Colors.white12 : Colors.transparent,
            onTap: () => setState(() { selectedBook = books[i]; _updateChapters(selectedBook); }),
            title: Text(BibleHome.teluguBooks[books[i]] ?? books[i], style: TextStyle(color: selectedBook == books[i] ? Colors.white : Colors.white54)),
          ))),
          Expanded(flex: 2, child: ListView.builder(itemCount: chapters.length, itemBuilder: (context, i) => ListTile(
            tileColor: selectedChapter == chapters[i] ? Colors.white12 : Colors.transparent,
            onTap: () => setState(() { selectedChapter = chapters[i]; _updateVerses(selectedBook, selectedChapter); }),
            title: Center(child: Text(chapters[i], style: TextStyle(color: selectedChapter == chapters[i] ? Colors.white : Colors.white54))),
          ))),
          Expanded(flex: 2, child: ListView.builder(itemCount: verses.length, itemBuilder: (context, i) => ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => BibleReadingPage(
                bookName: BibleHome.teluguBooks[selectedBook] ?? selectedBook,
                englishBookName: selectedBook,
                chapterNumber: selectedChapter,
                verses: verses,
                initialScrollIndex: i,
                document: _document!,
              )));
            },
            title: Center(child: Text(verses[i]['num']!, style: const TextStyle(color: Colors.white70))),
          ))),
        ],
      ),
    );
  }
}

class BibleReadingPage extends StatefulWidget {
  final String bookName;
  final String englishBookName;
  final String chapterNumber;
  final List<Map<String, dynamic>> verses;
  final int initialScrollIndex;
  final XmlDocument document;

  const BibleReadingPage({super.key, required this.bookName, required this.englishBookName, required this.chapterNumber, required this.verses, required this.initialScrollIndex, required this.document});

  @override
  State<BibleReadingPage> createState() => _BibleReadingPageState();
}

class _BibleReadingPageState extends State<BibleReadingPage> {
  double _fontSize = 18.0; // Default Font Size

  // Zoom In / Zoom Out functions
  void _zoomIn() => setState(() { if (_fontSize < 40) _fontSize += 2; });
  void _zoomOut() => setState(() { if (_fontSize > 12) _fontSize -= 2; });

  // Bookmark Save Logic
  Future<void> _toggleBookmark(Map<String, dynamic> verse) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bible_bookmarks') ?? [];
    
    String bookmarkData = jsonEncode({
      'book': widget.bookName,
      'chapter': widget.chapterNumber,
      'num': verse['num'],
      'text': verse['text'],
    });

    if (bookmarks.contains(bookmarkData)) {
      bookmarks.remove(bookmarkData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from Bookmarks")));
    } else {
      bookmarks.add(bookmarkData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved to Bookmarks")));
    }
    await prefs.setStringList('bible_bookmarks', bookmarks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("${widget.bookName} ${widget.chapterNumber}", style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.zoom_in, color: Colors.white), onPressed: _zoomIn),
          IconButton(icon: const Icon(Icons.zoom_out, color: Colors.white), onPressed: _zoomOut),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: widget.verses.length,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () {
               // Normal tap to show references (pata code logic)
            },
            trailing: IconButton(
              icon: const Icon(Icons.bookmark_border, color: Colors.blueAccent, size: 20),
              onPressed: () => _toggleBookmark(widget.verses[index]),
            ),
            title: Container(
              padding: const EdgeInsets.all(5),
              child: RichText(text: TextSpan(children: [
                TextSpan(text: "${widget.verses[index]['num']}. ", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                TextSpan(text: widget.verses[index]['text']!, style: GoogleFonts.balooTammudu2(fontSize: _fontSize, color: Colors.white, height: 1.6)),
              ])),
            ),
          );
        },
      ),
    );
  }
}
