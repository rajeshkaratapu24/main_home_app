import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart'; // XML package import
import 'package:google_fonts/google_fonts.dart';

class BibleHome extends StatefulWidget {
  const BibleHome({super.key});

  @override
  State<BibleHome> createState() => _BibleHomeState();
}

class _BibleHomeState extends State<BibleHome> {
  List<String> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBibleXml();
  }

  // XML File load chesi parse chese function
  Future<void> _loadBibleXml() async {
    try {
      final String xmlString = await rootBundle.loadString('assets/bible.xml');
      final document = XmlDocument.parse(xmlString);
      
      // XML Structure batti 'book' tags ni vethukuthundi
      // Example structure: <bible><book name="Genesis">...</book></bible>
      final booksData = document.findAllElements('book');
      
      setState(() {
        _books = booksData.map((node) => node.getAttribute('name') ?? 'Unknown').toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading XML: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("పరిశుద్ధ గ్రంథము", style: GoogleFonts.balooTammudu2()),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _books.isEmpty
              ? const Center(child: Text("Data not found", style: TextStyle(color: Colors.white)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _books.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _books[index],
                        style: GoogleFonts.balooTammudu2(fontSize: 20, color: Colors.white),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        // Chapters logic ikkada add cheddam
                      },
                    );
                  },
                ),
    );
  }
}
