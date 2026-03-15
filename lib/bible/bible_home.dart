import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';

class BibleHome extends StatefulWidget {
  const BibleHome({super.key});

  @override
  State<BibleHome> createState() => _BibleHomeState();
}

class _BibleHomeState extends State<BibleHome> {
  List<Map<String, String>> _books = [];
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadBibleXml();
  }

  Future<void> _loadBibleXml() async {
    try {
      // 1. Load XML file
      final String xmlString = await rootBundle.loadString('assets/bible.xml');
      
      // 2. Parse XML
      final document = XmlDocument.parse(xmlString);
      
      // 3. Find <BIBLEBOOK> tags (Nee XML lo unna exact tag idi)
      final bookElements = document.findAllElements('BIBLEBOOK');
      
      List<Map<String, String>> tempBooks = [];
      for (var element in bookElements) {
        // 'bname' attribute ni tiskuntundi (Genesis, etc.)
        String? name = element.getAttribute('bname');
        String? number = element.getAttribute('bnumber');
        
        if (name != null) {
          tempBooks.add({
            'name': name,
            'id': number ?? "0"
          });
        }
      }

      setState(() {
        _books = tempBooks;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e\nCheck if assets/bible.xml exists in GitHub.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("పరిశుద్ధ గ్రంథము", 
          style: GoogleFonts.balooTammudu2(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _books.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white10,
                        child: Text(_books[index]['id']!, 
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      title: Text(
                        _books[index]['name']!,
                        style: GoogleFonts.balooTammudu2(fontSize: 20, color: Colors.white),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        // Next step: Chapters open cheddam
                      },
                    );
                  },
                ),
    );
  }
}
