import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BookReaderPage extends StatefulWidget {
  final String htmlContent;
  final String title;

  const BookReaderPage({super.key, required this.htmlContent, required this.title});

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF)) // Background white color
      ..loadHtmlString(widget.htmlContent); // HTML code ni direct ga load chesthunnam
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
