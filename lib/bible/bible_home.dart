import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart'; 
import 'package:firebase_database/firebase_database.dart'; 
import 'bible_search.dart';
 // పాత్ సరిచూసుకో బ్రో

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
  List<Map<String, String>> verses = []; // వచనాల నంబర్స్ కోసం

  // మ్యూజిక్ ప్లేయర్
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isMusicPlaying = false;
  String? bgmUrl;

  final Map<String, String> teluguBooks = {
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
    } catch (e) {
      debugPrint("Error loading XML: $e");
    }
  }

  void _updateChapters(String bookName) {
    if (_document == null) return;
    final book = _document!.findAllElements('BIBLEBOOK').firstWhere(
      (e) => e.getAttribute('bname') == bookName
    );
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
    });
  }

  // రీడింగ్ పేజీకి వెళ్ళడానికి ఫంక్షన్
  void _goToReadingPage(int verseIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BibleReadingPage(
          bookName: teluguBooks[selectedBook] ?? selectedBook,
          chapterNumber: selectedChapter,
          verses: verses,
          initialScrollIndex: verseIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // ప్యూర్ బ్లాక్
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("B I B L E", style: GoogleFonts.ubuntu(color: Colors.white, letterSpacing: 4, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isMusicPlaying ? Icons.music_note : Icons.music_off, color: Colors.blueAccent),
            onPressed: () {
              isMusicPlaying ? _audioPlayer.pause() : _audioPlayer.resume();
              setState(() => isMusicPlaying = !isMusicPlaying);
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              if (_document == null) return;
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BibleSearch(document: _document!, currentBook: selectedBook),
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
        ],
      ),
      body: books.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // హెడర్స్ (BOOKS | CHAPTERS | VERSES)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white24, width: 1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 5, child: Center(child: Text("BOOKS", style: GoogleFonts.ubuntu(color: Colors.white54, fontSize: 12, letterSpacing: 2)))),
                      Expanded(flex: 2, child: Center(child: Text("CH", style: GoogleFonts.ubuntu(color: Colors.white54, fontSize: 12, letterSpacing: 2)))),
                      Expanded(flex: 2, child: Center(child: Text("VS", style: GoogleFonts.ubuntu(color: Colors.white54, fontSize: 12, letterSpacing: 2)))),
                    ],
                  ),
                ),
                // 3 కాలమ్స్ (Books | Chapters | Verses)
                Expanded(
                  child: Row(
                    children: [
                      // కాలమ్ 1: BOOKS
                      Expanded(
                        flex: 5,
                        child: Container(
                          decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white12, width: 1))),
                          child: ListView.builder(
                            itemCount: books.length,
                            itemBuilder: (context, index) {
                              String bName = books[index];
                              bool isSelected = selectedBook == bName;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedBook = bName;
                                    _updateChapters(bName);
                                  });
                                },
                                child: Container(
                                  color: isSelected ? Colors.white12 : Colors.transparent, // సెలెక్ట్ అయినప్పుడు గ్రే కలర్
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                  child: Row(
                                    children: [
                                      Icon(Icons.menu_book, color: isSelected ? Colors.white : Colors.white54, size: 16),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          teluguBooks[bName] ?? bName,
                                          style: GoogleFonts.balooTammudu2(
                                            color: isSelected ? Colors.white : Colors.white54,
                                            fontSize: 16,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // కాలమ్ 2: CHAPTERS
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white12, width: 1))),
                          child: ListView.builder(
                            itemCount: chapters.length,
                            itemBuilder: (context, index) {
                              String cNum = chapters[index];
                              bool isSelected = selectedChapter == cNum;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedChapter = cNum;
                                    _updateVerses(selectedBook, cNum);
                                  });
                                },
                                child: Container(
                                  color: isSelected ? Colors.white12 : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  alignment: Alignment.center,
                                  child: Text(
                                    cNum,
                                    style: GoogleFonts.ubuntu(
                                      color: isSelected ? Colors.white : Colors.white54,
                                      fontSize: 18,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // కాలమ్ 3: VERSES
                      Expanded(
                        flex: 2,
                        child: ListView.builder(
                          itemCount: verses.length,
                          itemBuilder: (context, index) {
                            String vNum = verses[index]['num']!;
                            return InkWell(
                              onTap: () => _goToReadingPage(index), // నొక్కగానే రీడింగ్ పేజీ ఓపెన్ అవుతుంది
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                alignment: Alignment.center,
                                child: Text(
                                  vNum,
                                  style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 18),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// =========================================================================
// రీడింగ్ పేజీ (ఇక్కడే వచనాలు చదువుకోవచ్చు, షేర్ చేయొచ్చు)
// =========================================================================
class BibleReadingPage extends StatefulWidget {
  final String bookName;
  final String chapterNumber;
  final List<Map<String, String>> verses;
  final int initialScrollIndex;

  const BibleReadingPage({
    super.key,
    required this.bookName,
    required this.chapterNumber,
    required this.verses,
    required this.initialScrollIndex,
  });

  @override
  State<BibleReadingPage> createState() => _BibleReadingPageState();
}

class _BibleReadingPageState extends State<BibleReadingPage> {
  Set<int> selectedVerseIndices = {};

  void _shareVerses() {
    String textToShare = "${widget.bookName} ${widget.chapterNumber}\n\n";
    var sortedIndices = selectedVerseIndices.toList()..sort();
    for (var index in sortedIndices) {
      textToShare += "${widget.verses[index]['num']}. ${widget.verses[index]['text']}\n";
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
        title: Text("${widget.bookName} ${widget.chapterNumber}", style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 20)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (selectedVerseIndices.isNotEmpty)
            IconButton(icon: const Icon(Icons.share, color: Colors.blueAccent), onPressed: _shareVerses),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        itemCount: widget.verses.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedVerseIndices.contains(index);
          // మనం సెలెక్ట్ చేసిన వచనం దగ్గర బ్యాక్‌గ్రౌండ్ కొంచెం హైలైట్ అవుతుంది
          bool isInitial = index == widget.initialScrollIndex && selectedVerseIndices.isEmpty;

          return ListTile(
            contentPadding: EdgeInsets.zero,
            selected: isSelected,
            selectedTileColor: Colors.white10,
            onLongPress: () => setState(() => selectedVerseIndices.add(index)),
            onTap: () {
              if (selectedVerseIndices.isNotEmpty) {
                setState(() {
                  isSelected ? selectedVerseIndices.remove(index) : selectedVerseIndices.add(index);
                });
              }
            },
            title: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isInitial ? Colors.white10 : Colors.transparent, // సెలెక్ట్ చేసిన వచనానికి చిన్న హైలైట్
                borderRadius: BorderRadius.circular(5)
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${widget.verses[index]['num']}. ",
                      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    TextSpan(
                      text: widget.verses[index]['text']!,
                      style: GoogleFonts.balooTammudu2(fontSize: 18, color: Colors.white, height: 1.6),
                    ),
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
