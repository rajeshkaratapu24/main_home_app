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
import 'bookmarks_page.dart';

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
    "2 Corinthians": "2 కొరింథీయులకు", "Galatians": "గలతీయులకు", "Ephesians": "エフェソయులకు",
    "Philippians": "フィリピయులకు", "Colossians": "కొలొస్సయులకు", "1 Thessalonians": "1 థెస్సలొనీకయులకు",
    "2 Thessalonians": "2 థెస్సలొనీకయులకు", "1 Timothy": "1 తిమోతికి", "2 Timothy": "2 తిమోతికి",
    "Titus": "తీతుకు", "Philemon": "フィレーమోనుకు", "Hebrews": "ヘブライయులకు",
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
  Set<int> selectedVerseIndices = {};
  double _fontSize = 18.0;

  final Map<String, String> reverseTskCodes = {
    "GEN": "Genesis", "EXO": "Exodus", "LEV": "Leviticus", "NUM": "Numbers", "DEU": "Deuteronomy",
    "JOS": "Joshua", "JDG": "Judges", "RUT": "Ruth", "1SA": "1 Samuel", "2SA": "2 Samuel",
    "1KI": "1 Kings", "2KI": "2 Kings", "1CH": "1 Chronicles", "2CH": "2 Chronicles",
    "EZR": "Ezra", "NEH": "Nehemiah", "EST": "Esther", "JOB": "Job", "PSA": "Psalms",
    "PRO": "Proverbs", "ECC": "Ecclesiastes", "SNG": "Song of Solomon", "ISA": "Isaiah",
    "JER": "Jeremiah", "LAM": "Lamentations", "EZE": "Ezekiel", "DAN": "Daniel",
    "HOS": "Hosea", "JOE": "Joel", "AMO": "Amos", "OBA": "Obadiah", "JON": "Jonah",
    "MIC": "Micah", "NAH": "Nahum", "HAB": "Habakkuk", "ZEP": "Zephaniah", "HAG": "Haggai",
    "ZEC": "Zechariah", "MAL": "Malachi", "MAT": "Matthew", "MAR": "Mark", "LUK": "Luke",
    "JOH": "John", "ACT": "Acts", "ROM": "Romans", "1CO": "1 Corinthians", "2CO": "2 Corinthians",
    "GAL": "Galatians", "EPH": "Ephesians", "PHI": "Philippians", "COL": "Colossians",
    "1TH": "1 Thessalonians", "2TH": "2 Thessalonians", "1TI": "1 Timothy", "2TI": "2 Timothy",
    "TIT": "Titus", "PHM": "Philemon", "HEB": "Hebrews", "JAM": "James", "1PE": "1 Peter",
    "2PE": "2 Peter", "1JO": "1 John", "2JO": "2 John", "3JO": "3 John", "JUD": "Jude", "REV": "Revelation"
  };

  void _showReferences(int index) {
    final int globalId = widget.verses[index]['globalId'] ?? 0;
    final String verseNum = widget.verses[index]['num'];
    int fileNum = ((globalId - 1) ~/ 1000) + 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => FutureBuilder<List<String>>(
        future: _fetchFromJSON(fileNum, globalId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
          final refs = snapshot.data ?? [];
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text("క్రాస్ రిఫరెన్సులు: ${widget.bookName} ${widget.chapterNumber}:$verseNum", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(color: Colors.white12),
                Expanded(
                  child: refs.isEmpty ? const Center(child: Text("రిఫరెన్సులు లేవు బ్రో", style: TextStyle(color: Colors.white30))) : ListView.builder(
                    itemCount: refs.length,
                    itemBuilder: (context, i) {
                      List<String> parts = refs[i].split(' ');
                      String engName = reverseTskCodes[parts[0]] ?? parts[0];
                      String telName = BibleHome.teluguBooks[engName] ?? engName;
                      String display = "$telName ${parts[1]}:${parts[2]}";

                      return ListTile(
                        leading: const Icon(Icons.link, color: Colors.blueAccent, size: 18),
                        title: Text(display, style: const TextStyle(color: Colors.white70)),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToRef(engName, parts[1], parts[2]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToRef(String bName, String cNum, String vNum) {
    try {
      final book = widget.document.findAllElements('BIBLEBOOK').firstWhere((e) => e.getAttribute('bname') == bName);
      final chapter = book.findAllElements('CHAPTER').firstWhere((e) => e.getAttribute('cnumber') == cNum);
      final List<Map<String, dynamic>> vList = chapter.findAllElements('VERS').map((e) => {'num': e.getAttribute('vnumber')!, 'text': e.innerText.trim()}).toList();

      Navigator.push(context, MaterialPageRoute(builder: (context) => BibleReadingPage(bookName: BibleHome.teluguBooks[bName] ?? bName, englishBookName: bName, chapterNumber: cNum, verses: vList, initialScrollIndex: int.parse(vNum) - 1, document: widget.document)));
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("వచనం దొరకలేదు బ్రో"))); }
  }

  Future<void> _toggleBookmark(Map<String, dynamic> verse) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bible_bookmarks') ?? [];
    String bookmarkData = jsonEncode({'book': widget.bookName, 'chapter': widget.chapterNumber, 'num': verse['num'], 'text': verse['text']});
    if (bookmarks.contains(bookmarkData)) { bookmarks.remove(bookmarkData); } else { bookmarks.add(bookmarkData); }
    await prefs.setStringList('bible_bookmarks', bookmarks);
    setState(() {});
  }

  Future<List<String>> _fetchFromJSON(int fileNum, int globalId) async {
    try {
      final String res = await rootBundle.loadString('assets/references/$fileNum.json');
      final data = json.decode(res);
      if (data.containsKey(globalId.toString())) {
        final refMap = data[globalId.toString()]['r'] as Map<String, dynamic>;
        return refMap.values.map((v) => v.toString()).toList();
      }
    } catch (e) { debugPrint("JSON Error: $e"); }
    return [];
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
          if (selectedVerseIndices.isNotEmpty) IconButton(icon: const Icon(Icons.share, color: Colors.blueAccent), onPressed: () {
            String shareText = "${widget.bookName} ${widget.chapterNumber}\n\n";
            var sorted = selectedVerseIndices.toList()..sort();
            for (var i in sorted) { shareText += "${widget.verses[i]['num']}. ${widget.verses[i]['text']}\n"; }
            Share.share(shareText);
          }),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: widget.verses.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedVerseIndices.contains(index);
          return ListTile(
            contentPadding: EdgeInsets.zero,
            onLongPress: () => setState(() => selectedVerseIndices.add(index)),
            onTap: () {
              if (selectedVerseIndices.isNotEmpty) { setState(() => isSelected ? selectedVerseIndices.remove(index) : selectedVerseIndices.add(index)); }
              else { _showReferences(index); }
            },
            trailing: IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.white12, size: 20), onPressed: () => _toggleBookmark(widget.verses[index])),
            title: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: isSelected ? Colors.white12 : Colors.transparent, borderRadius: BorderRadius.circular(5)),
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
