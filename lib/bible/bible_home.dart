import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart'; // మ్యూజిక్ కోసం
import 'package:firebase_database/firebase_database.dart'; // అడ్మిన్ కంట్రోల్ కోసం
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
  Set<int> selectedVerseIndices = {};
  
  // మ్యూజిక్ ప్లేయర్
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isMusicPlaying = false;
  String? bgmUrl;

 // 66 పుస్తకాల తెలుగు పేర్ల మ్యాపింగ్
  final Map<String, String> teluguBooks = {
    // పాత నిబంధన (Old Testament)
    "Genesis": "ఆదికాండము",
    "Exodus": "నిర్గమకాండము",
    "Leviticus": "లేవీయకాండము",
    "Numbers": "సంఖ్యాకాండము",
    "Deuteronomy": "ద్వితీయోపదేశకాండము",
    "Joshua": "యెహోషువ",
    "Judges": "న్యాయాధిపతులు",
    "Ruth": "రూతు",
    "1 Samuel": "1 సమూయేలు",
    "2 Samuel": "2 సమూయేలు",
    "1 Kings": "1 రాజులు",
    "2 Kings": "2 రాజులు",
    "1 Chronicles": "1 దినవృత్తాంతములు",
    "2 Chronicles": "2 దినవృత్తాంతములు",
    "Ezra": "ఎజ్రా",
    "Nehemiah": "నెహెమ్యా",
    "Esther": "ఎస్తేరు",
    "Job": "యోబు",
    "Psalms": "కీర్తనలు",
    "Proverbs": "సామెతలు",
    "Ecclesiastes": "ప్రసంగి",
    "Song of Solomon": "పరమగీతము",
    "Isaiah": "యెషయా",
    "Jeremiah": "యిర్మీయా",
    "Lamentations": "విలాపవాక్యములు",
    "Ezekiel": "యెహెజ్కేలు",
    "Daniel": "దానియేలు",
    "Hosea": "హోషేయ",
    "Joel": "యోవేలు",
    "Amos": "ఆమోసు",
    "Obadiah": "ఓబద్యా",
    "Jonah": "యోనా",
    "Micah": "మీకా",
    "Nahum": "నహూము",
    "Habakkuk": "హబక్కుకు",
    "Zephaniah": "జెఫన్యా",
    "Haggai": "హగ్గయి",
    "Zechariah": "జెకర్యా",
    "Malachi": "మలాకీ",

    // కొత్త నిబంధన (New Testament)
    "Matthew": "మత్తయి",
    "Mark": "మార్కు",
    "Luke": "లూకా",
    "John": "యోహాను",
    "Acts": "అపొస్తలుల కార్యములు",
    "Romans": "రోమీయులకు",
    "1 Corinthians": "1 కొరింథీయులకు",
    "2 Corinthians": "2 కొరింథీయులకు",
    "Galatians": "గలతీయులకు",
    "Ephesians": "ఎఫెసీయులకు",
    "Philippians": "ఫిలిప్పీయులకు",
    "Colossians": "కొలొస్సయులకు",
    "1 Thessalonians": "1 థెస్సలొనీకయులకు",
    "2 Thessalonians": "2 థెస్సలొనీకయులకు",
    "1 Timothy": "1 తిమోతికి",
    "2 Timothy": "2 తిమోతికి",
    "Titus": "తీతుకు",
    "Philemon": "ఫిలేమోనుకు",
    "Hebrews": "హెబ్రీయులకు",
    "James": "యాకోబు",
    "1 Peter": "1 పేతురు",
    "2 Peter": "2 Peter",
    "1 John": "1 యోహాను",
    "2 John": "2 యోహాను",
    "3 John": "3 యోహాను",
    "Jude": "యూదా",
    "Revelation": "ప్రకటన గ్రంథము",
  };

  @override
  void initState() {
    super.initState();
    _loadBible();
    _setupBGM(); // మ్యూజిక్ సెటప్
  }

  // ఫైర్‌బేస్ నుండి అడ్మిన్ సెట్ చేసిన మ్యూజిక్ లింక్ తెచ్చుకోవడం
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
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // లూప్‌లో ప్లే అవుతుంది
      await _audioPlayer.play(UrlSource(bgmUrl!));
      setState(() => isMusicPlaying = true);
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop(); // పేజీ క్లోజ్ చేస్తే మ్యూజిక్ ఆగిపోతుంది
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
        _updateChapters(selectedBook);
      });
    } catch (e) {
      debugPrint("Error loading XML: $e");
    }
  }

  void _updateChapters(String bookName) {
    final book = _document!.findAllElements('BIBLEBOOK').firstWhere(
      (e) => e.getAttribute('bname') == bookName
    );
    chapters = book.findAllElements('CHAPTER').map((e) => e.getAttribute('cnumber')!).toList();
    selectedChapter = chapters.first;
    _updateVerses(bookName, selectedChapter);
  }

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
      selectedVerseIndices.clear();
    });
  }

  void _shareVerses() {
    String bookInTelugu = teluguBooks[selectedBook] ?? selectedBook;
    String textToShare = "$bookInTelugu $selectedChapter\n\n";
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
          // మ్యూజిక్ ఆన్/ఆఫ్ బటన్
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
          if (selectedVerseIndices.isNotEmpty) ...[
            IconButton(icon: const Icon(Icons.share), onPressed: _shareVerses),
          ]
        ],
      ),
      body: verses.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              itemCount: verses.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedVerseIndices.contains(index);
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
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${verses[index]['num']}. ",
                          style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        TextSpan(
                          text: verses[index]['text']!,
                          style: GoogleFonts.balooTammudu2(
                            fontSize: 17, // అక్షరాల సైజు తగ్గించాను
                            color: Colors.white, 
                            height: 1.6
                          ),
                        ),
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
          _customDropdown(books, selectedBook, (val) {
            setState(() {
              selectedBook = val!;
              _updateChapters(val);
            });
          }, isBook: true),
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

  Widget _customDropdown(List<String> items, String value, Function(String?) onChanged, {bool isBook = false}) {
    return DropdownButton<String>(
      value: items.contains(value) ? value : items.first,
      dropdownColor: const Color(0xFF1A1A1A),
      style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
      items: items.map((e) {
        // పుస్తకం పేరు అయితే తెలుగులోకి మారుస్తుంది
        String displayTitle = isBook ? (teluguBooks[e] ?? e) : e;
        return DropdownMenuItem(value: e, child: Text(displayTitle));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
