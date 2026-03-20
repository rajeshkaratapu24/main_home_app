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
  bool _isLoading = false;

  // బటన్ నొక్కినప్పుడు మాత్రమే సెర్చ్ అవుతుంది
  void _performSearch() {
    String query = _controller.text.trim();
    if (query.isEmpty || query.length < 2) return;

    setState(() => _isLoading = true);

    List<Map<String, dynamic>> results = [];
    final books = widget.document.findAllElements('BIBLEBOOK');

    for (var book in books) {
      String bName = book.getAttribute('bname')!;
      for (var chapter in book.findAllElements('CHAPTER')) {
        String cNum = chapter.getAttribute('cnumber')!;
        int vIdx = 0;
        for (var verse in chapter.findAllElements('VERS')) {
          if (verse.innerText.contains(query)) {
            results.add({
              'book': bName,
              'chapter': cNum,
              'vNum': verse.getAttribute('vnumber'),
              'text': verse.innerText.trim(),
              'vIndex': vIdx,
            });
          }
          vIdx++;
        }
      }
    }
    setState(() {
      searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _performSearch(), // కీబోర్డ్ లో సెర్చ్ నొక్కినప్పుడు
          decoration: InputDecoration(
            hintText: "వెతకండి (ఉదా: యేసు)...",
            hintStyle: const TextStyle(color: Colors.white30),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.blueAccent),
              onPressed: _performSearch, // బటన్ నొక్కినప్పుడు
            ),
          ),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, i) {
                final res = searchResults[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  title: Text(
                    "${BibleUtils.teluguBooks[res['book']]} - అధ్యాయం ${res['chapter']} : ${res['vNum']}", 
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text(res['text'], style: GoogleFonts.balooTammudu2(color: Colors.white70, fontSize: 16)),
                  onTap: () => Navigator.pop(context, res),
                );
              },
            ),
    );
  }
}
