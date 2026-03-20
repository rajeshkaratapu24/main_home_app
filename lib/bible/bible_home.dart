import 'dart:convert';
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
  List<Map<String, dynamic>> verses = [];

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
    "Ezekiel": "యెహెజ్కేలు", "Daniel": "దానియేలు", "Hosea": "ホషేయ",
    "Joel": "యోవేలు", "Amos": "ఆమోసు", "Obadiah": "ఓబద్యా",
    "Jonah": "యోనా", "Micah": "మీకా", "Nahum": "నహూము",
    "Habakkuk": "హబక్కుకు", "Zephaniah": "జెఫన్యా", "Haggai": "హగ్గయి",
    "Zechariah": "జెకర్యా", "Malachi": "మలాకీ", "Matthew": "మత్తయి",
    "Mark": "మార్కు", "Luke": "లూకా", "John": "యోహాను",
    "Acts": "అపొస్తలుల కార్యములు", "Romans": "రోమీయులకు", "1 Corinthians": "1 కొరింథీయులకు",
    "2 Corinthians": "2 కొరింథీయులకు", "Galatians": "గలతీయులకు", "Ephesians": "ఎఫెసీయులకు",
    "Philippians": "フィリピయులకు", "Colossians": "కొలొస్సయులకు", "1 Thessalonians": "1 థెస్సలొనీకయులకు",
    "2 Thessalonians": "2 థెస్సలొనీకయులకు", "1 Timothy": "1 తిమోతికి", "2 Timothy": "2 తిమోతికి",
    "Titus": "తీతుకు", "Philemon": "フィレーమోనుకు", "Hebrews": "ヘブライయులకు",
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
      debugPrint("Error: $e");
    }
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
    
    int currentGlobalIdx = 0;
    for (var b in bookElements) {
      final bName = b.getAttribute('bname');
      final chaptersInBook = b.findAllElements('CHAPTER').toList();
      for (var c in chaptersInBook) {
        final cNum = c.getAttribute('cnumber');
        if (bName == bookName && cNum == chapterNum) {
          setState(() {
            verses = c.findAllElements('VERS').map((e) {
              currentGlobalIdx++;
              return {
                'num': e.getAttribute('vnumber')!,
                'text': e.innerText.trim(),
                'globalId': currentGlobalIdx // JSON లో ఉండే ID
              };
            }).toList();
          });
          return;
        }
        currentGlobalIdx += c.findAllElements('VERS').length;
      }
    }
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
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => BibleSearch(document: _document!, currentBook: selectedBook)));
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
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: ListView.builder(
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            String bName = books[index];
                            bool isSelected = selectedBook == bName;
                            return ListTile(
                              tileColor: isSelected ? Colors.white12 : Colors.transparent,
                              onTap: () => setState(() { selectedBook = bName; _updateChapters(bName); }),
                              title: Text(teluguBooks[bName] ?? bName, style: GoogleFonts.balooTammudu2(color: isSelected ? Colors.white : Colors.white54, fontSize: 16)),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ListView.builder(
                          itemCount: chapters.length,
                          itemBuilder: (context, index) {
                            String cNum = chapters[index];
                            bool isSelected = selectedChapter == cNum;
                            return ListTile(
                              tileColor: isSelected ? Colors.white12 : Colors.transparent,
                              onTap: () => setState(() { selectedChapter = cNum; _updateVerses(selectedBook, cNum); }),
                              title: Center(child: Text(cNum, style: GoogleFonts.ubuntu(color: isSelected ? Colors.white : Colors.white54, fontSize: 18))),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ListView.builder(
                          itemCount: verses.length,
                          itemBuilder: (context, index) => ListTile(
                            onTap: () => _goToReadingPage(index),
                            title: Center(child: Text(verses[index]['num']!, style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 18))),
                          ),
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

class BibleReadingPage extends StatefulWidget {
  final String bookName;
  final String chapterNumber;
  final List<Map<String, dynamic>> verses;
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
  void _showReferences(int index) {
    final int globalId = widget.verses[index]['globalId'];
    final String verseNum = widget.verses[index]['num'];
    
    // ఏ ఫైల్ లో డేటా ఉందో లెక్క కడుతున్నాం (ప్రతి ఫైల్ లో 1000 వచనాలు)
    int fileNum = ((globalId - 1) ~/ 1000) + 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => FutureBuilder<List<String>>(
        future: _fetchFromJSON(fileNum, globalId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
          }
          final refs = snapshot.data ?? [];
          return Container(
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
                          title: Text(refs[i], style: const TextStyle(color: Colors.white70)),
                        ),
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<List<String>> _fetchFromJSON(int fileNum, int globalId) async {
    try {
      final String response = await rootBundle.loadString('assets/references/$fileNum.json');
      final Map<String, dynamic> data = json.decode(response);
      
      // JSON లో నీ డేటా ఇలా ఉంది: {"1": {"v": "...", "r": {"ID": "REF"}}}
      if (data.containsKey(globalId.toString())) {
        final refMap = data[globalId.toString()]['r'] as Map<String, dynamic>;
        // కేవలం రిఫరెన్స్ టెక్స్ట్ (ఉదా: EXO 20 11) కావాలి కాబట్టి Values తీసుకుంటున్నాం
        return refMap.values.map((v) => v.toString()).toList();
      }
    } catch (e) {
      debugPrint("JSON Load Error: $e");
    }
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
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: widget.verses.length,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () => _showReferences(index),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: "${widget.verses[index]['num']}. ", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                        TextSpan(text: widget.verses[index]['text']!, style: GoogleFonts.balooTammudu2(fontSize: 18, color: Colors.white, height: 1.6)),
                      ],
                    ),
                  ),
                ),
                const Icon(Icons.auto_awesome_motion, color: Colors.white12, size: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
