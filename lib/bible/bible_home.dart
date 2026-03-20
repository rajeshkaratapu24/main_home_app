import 'dart:convert'; // JSON కోసం
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart'; 
import 'package:firebase_database/firebase_database.dart'; 
import 'bible_search.dart';

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

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isMusicPlaying = false;
  String? bgmUrl;

  final Map<String, String> teluguBooks = {
    "Genesis": "ఆదికాండము", "Exodus": "నిర్గమకాండము", "Leviticus": "లేవీయకాండము",
    "Numbers": "సంఖ్యాకాండము", "Deuteronomy": "ద్వితీయోపదేశకాండము", "Joshua": "యెహోషువ",
    "Judges": "న్యాయาధిపతులు", "Ruth": "రూతు", "1 Samuel": "1 సమూయేలు",
    "2 Samuel": "2 సమూయేలు", "1 Kings": "1 రాజులు", "2 Kings": "2 రాజులు",
    "1 Chronicles": "1 దినవృత్తాంతములు", "2 Chronicles": "2 దినవృత్తాంతములు",
    "Ezra": "ఎజ్రా", "Nehemiah": "నెహెమ్యా", "Esther": "ఎస్తేరు",
    "Job": "యోబు", "Psalm": "కీర్తనలు", "Psalms": "కీర్తనలు", 
    "Proverbs": "సామెతలు", "Ecclesiastes": "ప్రసంగి", "Song of Solomon": "పరమగీతము",
    "Isaiah": "యెషయా", "Jeremiah": "యిర్మీయా", "Lamentations": "విలాపవాక్యములు",
    "Ezekiel": "యెహెజ్కేలు", "Daniel": "దానియేలు", "Hosea": "ホషేయ",
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

  void _goToReadingPage(int verseIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BibleReadingPage(
          bookName: teluguBooks[selectedBook] ?? selectedBook,
          chapterNumber: selectedChapter,
          verses: verses,
          initialScrollIndex: verseIndex,
          englishBookName: selectedBook, // ఇంగ్లీష్ పేరు కూడా పంపిస్తున్నాం
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
                Expanded(
                  child: Row(
                    children: [
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
                                  color: isSelected ? Colors.white12 : Colors.transparent,
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
                      Expanded(
                        flex: 2,
                        child: ListView.builder(
                          itemCount: verses.length,
                          itemBuilder: (context, index) {
                            String vNum = verses[index]['num']!;
                            return InkWell(
                              onTap: () => _goToReadingPage(index),
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
// రీడింగ్ పేజీ - ఇక్కడే మార్పులు జరిగాయి
// =========================================================================
class BibleReadingPage extends StatefulWidget {
  final String bookName;
  final String englishBookName; // క్రాస్ రిఫరెన్స్ కోసం
  final String chapterNumber;
  final List<Map<String, String>> verses;
  final int initialScrollIndex;

  const BibleReadingPage({
    super.key,
    required this.bookName,
    required this.englishBookName,
    required this.chapterNumber,
    required this.verses,
    required this.initialScrollIndex,
  });

  @override
  State<BibleReadingPage> createState() => _BibleReadingPageState();
}

class _BibleReadingPageState extends State<BibleReadingPage> {
  Set<int> selectedVerseIndices = {};
  Map<String, dynamic> _tskData = {}; // క్రాస్ రిఫరెన్స్ డేటా

  // ఇంగ్లీష్ పేరు నుండి TSK షార్ట్ కోడ్ మ్యాపింగ్
  final Map<String, String> tskBookCodes = {
    "Genesis": "Gen", "Exodus": "Exo", "Leviticus": "Lev", "Numbers": "Num",
    "Deuteronomy": "Deu", "Joshua": "Jos", "Judges": "Jdg", "Ruth": "Rut",
    "1 Samuel": "1Sa", "2 Samuel": "2Sa", "1 Kings": "1Ki", "2 Kings": "2Ki",
    "1 Chronicles": "1Ch", "2 Chronicles": "2Ch", "Ezra": "Ezr", "Nehemiah": "Neh",
    "Esther": "Est", "Job": "Job", "Psalm": "Psa", "Psalms": "Psa",
    "Proverbs": "Pro", "Ecclesiastes": "Ecc", "Song of Solomon": "Sng",
    "Isaiah": "Isa", "Jeremiah": "Jer", "Lamentations": "Lam", "Ezekiel": "Eze",
    "Daniel": "Dan", "Hosea": "Hos", "Joel": "Joe", "Amos": "Amo",
    "Obadiah": "Oba", "Jonah": "Jon", "Micah": "Mic", "Nahum": "Nah",
    "Habakkuk": "Hab", "Zephaniah": "Zep", "Haggai": "Hag", "Zechariah": "Zec",
    "Malachi": "Mal", "Matthew": "Mat", "Mark": "Mar", "Luke": "Luk",
    "John": "Joh", "Acts": "Act", "Romans": "Rom", "1 Corinthians": "1Co",
    "2 Corinthians": "2Co", "Galatians": "Gal", "Ephesians": "Eph",
    "Philippians": "Phi", "Colossians": "Col", "1 Thessalonians": "1Th",
    "2 Thessalonians": "2Th", "1 Timothy": "1Ti", "2 Timothy": "2Ti",
    "Titus": "Tit", "Philemon": "Phm", "Hebrews": "Heb", "James": "Jam",
    "1 Peter": "1Pe", "2 Peter": "2Pe", "1 John": "1Jo", "2 John": "2Jo",
    "3 John": "3Jo", "Jude": "Jud", "Revelation": "Rev",
  };

  @override
  void initState() {
    super.initState();
    _loadTSK();
  }

  // TSK JSON డేటా లోడ్ చేయడం
  Future<void> _loadTSK() async {
    try {
      final String response = await rootBundle.loadString('assets/tsk.json');
      setState(() {
        _tskData = json.decode(response);
      });
    } catch (e) {
      debugPrint("TSK Error: $e");
    }
  }

  // రిఫరెన్స్ బాక్స్ చూపించే ఫంక్షన్
  void _showReferences(String verseNum) {
    String bookCode = tskBookCodes[widget.englishBookName] ?? widget.englishBookName;
    String key = "$bookCode.${widget.chapterNumber}.$verseNum";
    List<dynamic> refs = _tskData[key] ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("క్రాస్ రిఫరెన్సులు: ${widget.bookName} ${widget.chapterNumber}:$verseNum", 
                 style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white12),
            Expanded(
              child: refs.isEmpty 
                ? const Center(child: Text("నోట్స్ లేవు బ్రో", style: TextStyle(color: Colors.white30)))
                : ListView.builder(
                    itemCount: refs.length,
                    itemBuilder: (context, i) => ListTile(
                      leading: const Icon(Icons.link, color: Colors.blueAccent, size: 18),
                      title: Text(refs[i].toString(), style: const TextStyle(color: Colors.white70)),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

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
              } else {
                // సెలెక్షన్ మోడ్ లో లేనప్పుడు నొక్కితే రిఫరెన్సులు చూపిస్తుంది
                _showReferences(widget.verses[index]['num']!);
              }
            },
            title: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isInitial ? Colors.white10 : Colors.transparent,
                borderRadius: BorderRadius.circular(5)
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
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
                  // రిఫరెన్స్ ఐకాన్
                  Icon(Icons.auto_awesome_motion, color: Colors.white12, size: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
