import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart'; 
import 'package:firebase_database/firebase_database.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'bible_search.dart';
import 'bible_utils.dart';
import 'bible_references_helper.dart';
import 'bookmarks_page.dart';

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
  List<Map<String, dynamic>> verses = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isMusicPlaying = false;
  String? bgmUrl;

  @override
  void initState() {
    super.initState();
    _loadBible();
    _setupBGM();
  }

  Future<void> _setupBGM() async {
    final ref = FirebaseDatabase.instance.ref("admin_settings/bible_bgm");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      bgmUrl = snapshot.value.toString();
      _playBGM();
    }
  }

  void _playBGM() async {
    if (bgmUrl != null) {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(UrlSource(bgmUrl!));
      setState(() => isMusicPlaying = true);
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
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

  void _goToReadingPage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BibleReadingPage(
          bookName: BibleUtils.teluguBooks[selectedBook] ?? selectedBook,
          englishBookName: selectedBook,
          chapterNumber: selectedChapter,
          verses: verses,
          initialScrollIndex: index,
          document: _document!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("B I B L E", style: GoogleFonts.ubuntu(color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: Icon(isMusicPlaying ? Icons.music_note : Icons.music_off, color: Colors.blueAccent), onPressed: () {
            isMusicPlaying ? _audioPlayer.pause() : _audioPlayer.resume();
            setState(() => isMusicPlaying = !isMusicPlaying);
          }),
          IconButton(icon: const Icon(Icons.search), onPressed: () async {
            if (_document == null) return;
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => BibleSearch(document: _document!, currentBook: selectedBook)));
            if (result != null) {
              setState(() { selectedBook = result['book']; _updateChapters(selectedBook); selectedChapter = result['chapter']; _updateVerses(selectedBook, selectedChapter); });
            }
          }),
          IconButton(icon: const Icon(Icons.bookmarks, color: Colors.blueAccent), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BookmarksPage()));
          }),
        ],
      ),
      body: Row(
        children: [
          Expanded(flex: 5, child: Container(decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white12))), child: ListView.builder(itemCount: books.length, itemBuilder: (context, i) => ListTile(
            tileColor: selectedBook == books[i] ? Colors.white12 : Colors.transparent,
            onTap: () => setState(() { selectedBook = books[i]; _updateChapters(selectedBook); }),
            title: Text(BibleUtils.teluguBooks[books[i]] ?? books[i], style: GoogleFonts.balooTammudu2(color: selectedBook == books[i] ? Colors.white : Colors.white54, fontSize: 16)),
          )))),
          Expanded(flex: 2, child: Container(decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white12))), child: ListView.builder(itemCount: chapters.length, itemBuilder: (context, i) => ListTile(
            tileColor: selectedChapter == chapters[i] ? Colors.white12 : Colors.transparent,
            onTap: () => setState(() { selectedChapter = chapters[i]; _updateVerses(selectedBook, selectedChapter); }),
            title: Center(child: Text(chapters[i], style: GoogleFonts.ubuntu(color: selectedChapter == chapters[i] ? Colors.white : Colors.white54, fontSize: 18))),
          )))),
          Expanded(flex: 2, child: ListView.builder(itemCount: verses.length, itemBuilder: (context, i) => ListTile(
            onTap: () => _goToReadingPage(i),
            title: Center(child: Text(verses[i]['num']!, style: const TextStyle(color: Colors.white70, fontSize: 18))),
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
  double _fontSize = 18.0;
  Map<int, Color> highlights = {}; // Highlights store cheyyడానికి

  @override
  void initState() {
    super.initState();
    _loadHighlights();
  }

  // Highlight colors load cheyyadam
  Future<void> _loadHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    String? stored = prefs.getString('verse_highlights');
    if (stored != null) {
      Map<String, dynamic> decoded = jsonDecode(stored);
      setState(() {
        highlights = decoded.map((key, value) => MapEntry(int.parse(key), Color(value)));
      });
    }
  }

  // Highlight color save cheyyadam
  Future<void> _saveHighlight(int globalId, Color? color) async {
    final prefs = await SharedPreferences.getInstance();
    if (color == null) {
      highlights.remove(globalId);
    } else {
      highlights[globalId] = color;
    }
    String encoded = jsonEncode(highlights.map((key, value) => MapEntry(key.toString(), value.value)));
    await prefs.setString('verse_highlights', encoded);
    setState(() {});
  }

  // Long Press మెనూ
  void _showVerseMenu(int index) {
    final verse = widget.verses[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${widget.bookName} ${widget.chapterNumber}:${verse['num']}", style: const TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _menuItem(Icons.bookmark_add, "Bookmark", () {
                    Navigator.pop(context);
                    _toggleBookmark(verse);
                  }),
                  _menuItem(Icons.share, "Share", () {
                    Navigator.pop(context);
                    Share.share("${widget.bookName} ${widget.chapterNumber}:${verse['num']}\n${verse['text']}");
                  }),
                ],
              ),
              const Divider(color: Colors.white10, height: 30),
              const Text("Highlight Color", style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _colorOption(Colors.yellow.withOpacity(0.3), verse['globalId']),
                  _colorOption(Colors.green.withOpacity(0.3), verse['globalId']),
                  _colorOption(Colors.blue.withOpacity(0.3), verse['globalId']),
                  _colorOption(Colors.pink.withOpacity(0.3), verse['globalId']),
                  IconButton(icon: const Icon(Icons.format_color_reset, color: Colors.white), onPressed: () {
                    Navigator.pop(context);
                    _saveHighlight(verse['globalId'], null);
                  }),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(backgroundColor: Colors.white10, child: Icon(icon, color: Colors.blueAccent)),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _colorOption(Color color, int globalId) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _saveHighlight(globalId, color);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        width: 35,
        height: 35,
        decoration: BoxDecoration(color: color.withOpacity(1), shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
      ),
    );
  }

  Future<void> _toggleBookmark(Map<String, dynamic> verse) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bible_bookmarks') ?? [];
    String bookmarkData = jsonEncode({'book': widget.bookName, 'chapter': widget.chapterNumber, 'num': verse['num'], 'text': verse['text']});
    if (bookmarks.contains(bookmarkData)) { 
      bookmarks.remove(bookmarkData); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from Bookmarks")));
    } else { 
      bookmarks.add(bookmarkData); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved to Bookmarks")));
    }
    await prefs.setStringList('bible_bookmarks', bookmarks);
  }

  void _navigateToRef(String bName, String cNum, String vNum) {
    try {
      final book = widget.document.findAllElements('BIBLEBOOK').firstWhere((e) => e.getAttribute('bname') == bName);
      final chapter = book.findAllElements('CHAPTER').firstWhere((e) => e.getAttribute('cnumber') == cNum);
      final List<Map<String, dynamic>> vList = chapter.findAllElements('VERS').map((e) => {'num': e.getAttribute('vnumber')!, 'text': e.innerText.trim()}).toList();
      Navigator.push(context, MaterialPageRoute(builder: (context) => BibleReadingPage(bookName: BibleUtils.teluguBooks[bName] ?? bName, englishBookName: bName, chapterNumber: cNum, verses: vList, initialScrollIndex: int.parse(vNum) - 1, document: widget.document)));
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("వచనం దొరకలేదు బ్రో"))); }
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
          IconButton(icon: const Icon(Icons.zoom_in), onPressed: () => setState(() => _fontSize < 40 ? _fontSize += 2 : null)),
          IconButton(icon: const Icon(Icons.zoom_out), onPressed: () => setState(() => _fontSize > 12 ? _fontSize -= 2 : null)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: widget.verses.length,
        itemBuilder: (context, index) {
          final verse = widget.verses[index];
          Color? highlightColor = highlights[verse['globalId']];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            onLongPress: () => _showVerseMenu(index),
            onTap: () {
              BibleReferencesHelper.showReferences(context: context, bookName: widget.bookName, chapterNumber: widget.chapterNumber, verseData: verse, document: widget.document, onNavigate: (b, c, v) => _navigateToRef(b, c, v));
            },
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              decoration: BoxDecoration(color: highlightColor ?? Colors.transparent, borderRadius: BorderRadius.circular(5)),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: "${verse['num']}. ", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    TextSpan(text: verse['text']!, style: GoogleFonts.balooTammudu2(fontSize: _fontSize, color: Colors.white, height: 1.6)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
