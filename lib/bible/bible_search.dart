import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bible_utils.dart';

class BibleSearch extends StatefulWidget {
  final XmlDocument document;
  const BibleSearch({super.key, required this.document});

  @override
  State<BibleSearch> createState() => _BibleSearchState();
}

class _BibleSearchState extends State<BibleSearch> {
  List<Map<String, dynamic>> searchResults = [];
  final TextEditingController _controller = TextEditingController();
  
  String selectedBookFilter = "అన్ని పుస్తకాలు";
  String selectedChapterFilter = "అన్ని అధ్యాయాలు";
  List<String> availableBooks = ["అన్ని పుస్తకాలు"];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final bookElements = widget.document.findAllElements('BIBLEBOOK');
    for (var b in bookElements) {
      String? engName = b.getAttribute('bname');
      if (engName != null) {
        availableBooks.add(BibleUtils.teluguBooks[engName] ?? engName);
      }
    }
  }

  void _performSearch() {
    String query = _controller.text.trim();
    if (query.isEmpty) return;
    setState(() => _isLoading = true);

    List<Map<String, dynamic>> results = [];
    final books = widget.document.findAllElements('BIBLEBOOK');

    for (var book in books) {
      String bName = book.getAttribute('bname')!;
      String telName = BibleUtils.teluguBooks[bName] ?? bName;
      
      // ఫిల్టర్ చెక్
      if (selectedBookFilter != "అన్ని పుస్తకాలు" && selectedBookFilter != telName) continue;

      for (var chapter in book.findAllElements('CHAPTER')) {
        String cNum = chapter.getAttribute('cnumber')!;
        
        int vIdx = 0;
        for (var verse in chapter.findAllElements('VERS')) {
          String vText = verse.innerText;
          if (vText.contains(query)) {
            results.add({
              'book': bName,
              'chapter': cNum,
              'vNum': verse.getAttribute('vnumber'),
              'text': vText.trim(),
              'vIndex': vIdx,
            });
          }
          vIdx++;
        }
      }
    }
    setState(() { searchResults = results; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text("S E A R C H", style: GoogleFonts.ubuntu(letterSpacing: 4, fontSize: 18, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // సెర్చ్ బాక్స్
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _performSearch(),
                decoration: InputDecoration(
                  hintText: "దేవుడు",
                  hintStyle: const TextStyle(color: Colors.white30),
                  prefixIcon: const Icon(Icons.search, color: Colors.white30),
                  suffixIcon: IconButton(icon: const Icon(Icons.close, color: Colors.white30), onPressed: () => _controller.clear()),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          // ఫిల్టర్లు (Dropdowns)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedBookFilter,
                      dropdownColor: Colors.black87,
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white),
                      items: availableBooks.map((b) => DropdownMenuItem(value: b, child: Text(b, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) => setState(() => selectedBookFilter = val!),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedChapterFilter,
                      dropdownColor: Colors.black87,
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white),
                      items: [selectedChapterFilter].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: null, // చాప్టర్ ఫిల్టర్ ప్రస్తుతానికి అవసరం లేదు
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // రిజల్ట్స్
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, i) {
                    final res = searchResults[i];
                    return GestureDetector(
                      onTap: () => Navigator.pop(context, res),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${BibleUtils.teluguBooks[res['book']]} ${res['chapter']}:${res['vNum']}",
                              style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              res['text'],
                              style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 17, height: 1.4),
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
