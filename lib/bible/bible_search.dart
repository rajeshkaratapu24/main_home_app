import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';

class BibleSearch extends StatefulWidget {
  final XmlDocument document;
  final String currentBook;

  const BibleSearch({super.key, required this.document, required this.currentBook});

  @override
  State<BibleSearch> createState() => _BibleSearchState();
}

class _BibleSearchState extends State<BibleSearch> {
  final TextEditingController _searchController = TextEditingController();
  
  String searchText = "";
  String selectedBookFilter = "All Books";
  String selectedChapterFilter = "All Chapters";

  List<String> books = ["All Books"];
  List<String> chapters = ["All Chapters"];
  List<Map<String, dynamic>> searchResults = [];

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
    _loadFilterData();
  }

  void _loadFilterData() {
    final bookElements = widget.document.findAllElements('BIBLEBOOK');
    books.addAll(bookElements.map((e) => e.getAttribute('bname')!).toList());
  }

  void _updateChaptersForBook(String bookName) {
    chapters = ["All Chapters"];
    selectedChapterFilter = "All Chapters";
    if (bookName != "All Books") {
      final book = widget.document.findAllElements('BIBLEBOOK').firstWhere(
        (e) => e.getAttribute('bname') == bookName,
      );
      chapters.addAll(book.findAllElements('CHAPTER').map((e) => e.getAttribute('cnumber')!).toList());
    }
    _performSearch(); // ఫిల్టర్ మార్చగానే సెర్చ్ రిజల్ట్స్ అప్‌డేట్ అవుతాయి
  }

  void _performSearch() {
    searchResults.clear();
    if (searchText.trim().isEmpty) {
      setState(() {});
      return;
    }

    final bookElements = widget.document.findAllElements('BIBLEBOOK');
    for (var book in bookElements) {
      String bName = book.getAttribute('bname')!;
      
      // బుక్ ఫిల్టర్ చెక్
      if (selectedBookFilter != "All Books" && bName != selectedBookFilter) continue;

      final chapterElements = book.findAllElements('CHAPTER');
      for (var chapter in chapterElements) {
        String cNum = chapter.getAttribute('cnumber')!;
        
        // చాప్టర్ ఫిల్టర్ చెక్
        if (selectedChapterFilter != "All Chapters" && cNum != selectedChapterFilter) continue;

        final verses = chapter.findAllElements('VERS');
        for (var verse in verses) {
          String vText = verse.innerText.trim();
          String vNum = verse.getAttribute('vnumber')!;

          // సెర్చ్ పదం ఉందో లేదో చెక్ చేస్తున్నాం
          if (vText.contains(searchText) || vText.toLowerCase().contains(searchText.toLowerCase())) {
            searchResults.add({
              'book': bName,
              'chapter': cNum,
              'verseNum': vNum,
              'text': vText,
            });
          }
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    Color bgColor = isLight ? Colors.white : Colors.black;
    Color textColor = isLight ? Colors.black : Colors.white;
    Color subTextColor = isLight ? Colors.black54 : Colors.white54;
    Color cardColor = isLight ? Colors.grey[100]! : const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text("S E A R C H", style: GoogleFonts.ubuntu(color: textColor, letterSpacing: 4, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: Column(
        children: [
          // సెర్చ్ బార్
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor),
              onChanged: (val) {
                searchText = val;
                _performSearch();
              },
              decoration: InputDecoration(
                hintText: "వచనం లేదా పదం వెతకండి...",
                hintStyle: TextStyle(color: subTextColor),
                prefixIcon: Icon(Icons.search, color: subTextColor),
                suffixIcon: searchText.isNotEmpty 
                    ? IconButton(
                        icon: Icon(Icons.clear, color: subTextColor),
                        onPressed: () {
                          _searchController.clear();
                          searchText = "";
                          _performSearch();
                        },
                      ) 
                    : null,
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // బుక్ & చాప్టర్ ఫిల్టర్స్ (డ్రాప్‌డౌన్స్)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
                    child: DropdownButton<String>(
                      value: selectedBookFilter,
                      isExpanded: true,
                      dropdownColor: cardColor,
                      underline: const SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: subTextColor),
                      style: GoogleFonts.balooTammudu2(color: textColor, fontSize: 14),
                      items: books.map((b) {
                        String displayTitle = (b == "All Books") ? "అన్ని పుస్తకాలు" : (teluguBooks[b] ?? b);
                        return DropdownMenuItem(value: b, child: Text(displayTitle));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedBookFilter = val!;
                          _updateChaptersForBook(val);
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
                    child: DropdownButton<String>(
                      value: selectedChapterFilter,
                      isExpanded: true,
                      dropdownColor: cardColor,
                      underline: const SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: subTextColor),
                      style: GoogleFonts.ubuntu(color: textColor, fontSize: 14),
                      items: chapters.map((c) {
                        String displayTitle = (c == "All Chapters") ? "అన్ని అధ్యాయాలు" : "Ch: $c";
                        return DropdownMenuItem(value: c, child: Text(displayTitle));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedChapterFilter = val!;
                          _performSearch();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          Divider(color: isLight ? Colors.black12 : Colors.white12, thickness: 1),

          // సెర్చ్ రిజల్ట్స్
          Expanded(
            child: searchResults.isEmpty && searchText.isNotEmpty
                ? Center(child: Text("ఎలాంటి వచనాలు దొరకలేదు 😔", style: TextStyle(color: subTextColor, fontSize: 16)))
                : searchResults.isEmpty
                    ? Center(child: Icon(Icons.menu_book, size: 80, color: isLight ? Colors.black12 : Colors.white12))
                    : ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          var item = searchResults[index];
                          String bookInTelugu = teluguBooks[item['book']] ?? item['book'];

                          return InkWell(
                            onTap: () {
                              // వచనం మీద నొక్కగానే నేరుగా ఆ బుక్, చాప్టర్ తో మెయిన్ పేజీకి వెళ్తాం!
                              Navigator.pop(context, {
                                'book': item['book'],
                                'chapter': item['chapter'],
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isLight ? Colors.black12 : Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$bookInTelugu ${item['chapter']}:${item['verseNum']}",
                                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    item['text'],
                                    style: GoogleFonts.balooTammudu2(color: textColor, fontSize: 16, height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
