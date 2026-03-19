import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';

class BookReaderPage extends StatefulWidget {
  final String url;
  final String title;

  const BookReaderPage({super.key, required this.url, required this.title});

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  String _htmlContent = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookData();
  }

  Future<void> _fetchBookData() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        setState(() {
          _htmlContent = response.body;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5DC), // సెపియా/డార్క్ థీమ్
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.ubuntu(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: HtmlWidget(
                _htmlContent,
                textStyle: GoogleFonts.notoSansTelugu(
                  fontSize: 18, 
                  height: 1.6, // లైన్ల మధ్య గ్యాప్ (చదవడానికి సులభంగా ఉంటుంది)
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                // HTML లో ఉన్న ఇమేజెస్ ని కూడా ఇది హ్యాండిల్ చేస్తుంది
                onLoadingBuilder: (context, element, loadingProgress) => const CircularProgressIndicator(),
              ),
            ),
    );
  }
}
