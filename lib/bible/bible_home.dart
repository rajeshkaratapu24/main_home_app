import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';
// Ee import chala important!
import 'chapter_page.dart'; 

class BibleHome extends StatefulWidget {
  const BibleHome({super.key});

  @override
  State<BibleHome> createState() => _BibleHomeState();
}

class _BibleHomeState extends State<BibleHome> {
  List<Map<String, String>> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBibleXml();
  }

  Future<void> _loadBibleXml() async {
    try {
      final String xmlString = await rootBundle.loadString('assets/bible.xml');
      final document = XmlDocument.parse(xmlString);
      final bookElements = document.findAllElements('BIBLEBOOK');
      
      List<Map<String, String>> tempBooks = [];
      for (var element in bookElements) {
        String? name = element.getAttribute('bname');
        String? number = element.getAttribute('bnumber');
        if (name != null) {
          tempBooks.add({'name': name, 'id': number ?? "0"});
        }
      }
      setState(() { _books = tempBooks; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("పరిశుద్ధ గ్రంథము", style: GoogleFonts.balooTammudu2()), backgroundColor: Colors.black, centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _books.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_books[index]['name']!, style: GoogleFonts.balooTammudu2(fontSize: 20, color: Colors.white)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // Ikkada navigation logic fix chesa
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapterPage(
                          bookName: _books[index]['name']!,
                          bookId: _books[index]['id']!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
