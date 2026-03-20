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

  // --- BGM Logic ---
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

  // --- XML Loading Logic ---
  Future<void> _loadBible() async {
    try {
      final String xmlString = await rootBundle.loadString('assets/bible.xml');
      _document = XmlDocument.parse(xmlString);
      setState(() {
        books = _document!.findAllElements('BIBLEBOOK').map((e) => e.getAttribute('bname')!).toList();
        _updateChapters(selectedBook);
      });
    } catch (e) { 
      debugPrint("Error: $e"); 
    }
  }

  void _updateChapters(String bookName) {
    final book = _document!.findAllElements('BIBLEBOOK').firstWhere((e) => e.getAttribute('bname') == bookName);
    setState(() {
      chapters = book.findAllElements('CHAPTER').map((e) => e.getAttribute('cnumber')!).toList();
      _updateVerses(bookName, selectedChapter);
    });
  }

  void _updateVerses(String bookName, String chapterNum) {
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
              return {
                'num': e.getAttribute('vnumber')!, 
                'text': e.innerText.trim(), 
                'globalId': currentIdx
              };
            }).toList();
          });
          return;
        }
        currentIdx += c.findAllElements('VERS').length;
      }
    }
  }

  void _goToReadingPage(int index) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BibleReadingPage(
      bookName: BibleUtils.teluguBooks[selectedBook] ?? selectedBook,
      englishBookName: selectedBook,
      chapterNumber: selectedChapter,
      verses: verses,
      initialScrollIndex: index,
      document: _document!,
    )));
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
          IconButton(
            icon: Icon(isMusicPlaying ? Icons.music_note : Icons.music_off, color: Colors.blueAccent), 
            onPressed: () {
              isMusicPlaying ? _audioPlayer.pause() : _audioPlayer.resume();
              setState(() => isMusicPlaying = !isMusicPlaying);
            }
          ),
          IconButton(
            icon: const Icon(Icons.search), 
            onPressed: () async {
              if (_document == null) return;
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => BibleSearch(document: _document!)));
              if (result != null) {
                setState(() {
                  selectedBook = result['book'];
                  _updateChapters(selectedBook);
                  selectedChapter = result['chapter'];
                  _updateVerses(selectedBook, selectedChapter);
                });
                _goToReadingPage(result['vIndex']);
              }
            }
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined, color: Colors.blueAccent), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BookmarksPage()))
          ),
        ],
      ),
      body: Row(
        children: [
          // 1. Books Column
          Expanded(flex: 5, child: ListView.builder(itemCount: books.length, itemBuilder: (context, i) => ListTile(
            tileColor: selectedBook == books[i] ? Colors.white12 : Colors.transparent,
            onTap: () => setState(() { selectedBook = books[i]; _updateChapters(selectedBook); }),
            title: Text(BibleUtils.teluguBooks[books[i]] ?? books[i], style: GoogleFonts.balooTammudu2(color: selectedBook == books[i] ? Colors.white : Colors.white54, fontSize: 16)),
          ))),
          // 2. Chapters Column
          Expanded(flex: 2, child: Container(
            decoration: const BoxDecoration(border: Border(left: BorderSide(color: Colors.white12), right: BorderSide(color: Colors.white12))), 
            child: ListView.builder(itemCount: chapters.length, itemBuilder: (context, i) => ListTile(
              tileColor: selectedChapter == chapters[i] ? Colors.white12 : Colors.transparent,
              onTap: () => setState(() { selectedChapter = chapters[i]; _updateVerses(selectedBook, selectedChapter); }),
              title: Center(child: Text(chapters[i], style: GoogleFonts.ubuntu(color: selectedChapter == chapters[i] ? Colors.white : Colors.white54, fontSize: 18))),
            ))
          )),
          // 3. Verses Column
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
  Map<int, Color> highlights = {};

  @override
  void initState() { 
    super.initState(); 
    _loadHighlights(); 
  }

  // --- Highlights Storage ---
  Future<void> _loadHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    String? stored = prefs.getString('v_highlights');
    if (stored != null) {
      Map<String, dynamic> decoded = jsonDecode(stored);
      setState(() { highlights = decoded.map((k, v) => MapEntry(int.parse(k), Color(v))); });
    }
  }

  Future<void> _saveHighlight(int globalId, Color color) async {
    setState(() => highlights[globalId] = color.withOpacity(0.3));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('v_highlights', jsonEncode(highlights.map((k, v) => MapEntry(k.toString(), v.value))));
  }

  // --- Long Press Menu Logic ---
  void _showLongPressMenu(int index) {
    final verse = widget.verses[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark, color: Colors.blueAccent), 
            title: const Text("Bookmark", style: TextStyle(color: Colors.white)), 
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              List<String> bks = prefs.getStringList('bible_bookmarks') ?? [];
              bks.add(jsonEncode({'book': widget.bookName, 'chapter': widget.chapterNumber, 'num': verse['num'], 'text': verse['text']}));
              await prefs.setStringList('bible_bookmarks', bks);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("బుక్‌మార్క్ చేయబడింది!")));
            }
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.blueAccent), 
            title: const Text("Share", style: TextStyle(color: Colors.white)), 
            onTap: () {
              Share.share("${widget.bookName} ${widget.chapterNumber}:${verse['num']}\n${verse['text']}");
              Navigator.pop(context);
            }
          ),
          const Divider(color: Colors.white12),
          const Padding(padding: EdgeInsets.all(8.0), child: Text("Highlight Color", style: TextStyle(color: Colors.white54))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [Colors.yellow, Colors.green, Colors.blue, Colors.pink].map((c) => GestureDetector(
              onTap: () {
                _saveHighlight(verse['globalId'], c);
                Navigator.pop(context);
              },
              child: CircleAvatar(backgroundColor: c, radius: 18),
            )).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _navigateToRef(String bName, String cNum, String vNum) {
    try {
      final book = widget.document.findAllElements('BIBLEBOOK').firstWhere((e) => e.getAttribute('bname') == bName);
      final chapter = book.findAllElements('CHAPTER').firstWhere((e) => e.getAttribute('cnumber') == cNum);
      final List<Map<String, dynamic>> vList = chapter.findAllElements('VERS').map((e) => {'num': e.getAttribute('vnumber')!, 'text': e.innerText.trim()}).toList();
      Navigator.push(context, MaterialPageRoute(builder: (context) => BibleReadingPage(bookName: BibleUtils.teluguBooks[bName] ?? bName, englishBookName: bName, chapterNumber: cNum, verses: vList, initialScrollIndex: int.parse(vNum) - 1, document: widget.document)));
    } catch (e) { 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("వచనం దొరకలేదు బ్రో"))); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("${widget.bookName} ${widget.chapterNumber}", style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 20)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
          return ListTile(
            contentPadding: EdgeInsets.zero,
            onLongPress: () => _showLongPressMenu(index),
            onTap: () => BibleReferencesHelper.showReferences(
              context: context, 
              bookName: widget.bookName, 
              chapterNumber: widget.chapterNumber, 
              verseData: verse, 
              document: widget.document, 
              onNavigate: (b, c, v) => _navigateToRef(b, c, v)
            ),
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              decoration: BoxDecoration(color: highlights[verse['globalId']] ?? Colors.transparent, borderRadius: BorderRadius.circular(5)),
              child: RichText(text: TextSpan(children: [
                TextSpan(text: "${verse['num']}. ", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                TextSpan(text: verse['text']!, style: GoogleFonts.balooTammudu2(fontSize: _fontSize, color: Colors.white, height: 1.6)),
              ])),
            ),
          );
        },
      ),
    );
  }
}
