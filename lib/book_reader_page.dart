import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';

class BookReaderPage extends StatelessWidget {
  final String htmlContent;
  final String title;

  const BookReaderPage({super.key, required this.htmlContent, required this.title});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFDF6E3), // Sepia background for Light mode
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.ubuntu(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: HtmlWidget(
          htmlContent,
          textStyle: GoogleFonts.notoSansTelugu(
            fontSize: 19, 
            height: 1.7, 
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          // HTML లోని ఇమేజెస్ ని లోడ్ చేస్తుంది
          onLoadingBuilder: (context, element, loadingProgress) => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
