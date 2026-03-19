import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http; // కొత్తగా ఇది యాడ్ చేశాం

class BookReaderPage extends StatefulWidget {
  final String url;
  final String title;

  const BookReaderPage({super.key, required this.url, required this.title});

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF));
    
    // డైరెక్ట్ గా లోడ్ చేయకుండా, డేటాని తెచ్చుకుని లోడ్ చేస్తాం
    _loadBookContent();
  }

  // గిట్‌హబ్ కోడ్‌ని వెబ్‌సైట్ లాగా మార్చే ఫంక్షన్
  Future<void> _loadBookContent() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        // కోడ్‌ని HTML లాగా వెబ్‌వ్యూలోకి పంపిస్తున్నాం
        await _controller.loadHtmlString(response.body);
      } else {
        throw Exception("Failed to load book");
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.purpleAccent)),
        ],
      ),
    );
  }
}
