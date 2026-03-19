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
    
    // HTML content ni fix chese logic
    String formattedHtml = """
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body { 
            margin: 0; 
            padding: 15px; 
            font-family: sans-serif; 
            overflow-x: hidden; /* Atu itu kadalaniyyadu */
            word-wrap: break-word;
          }
          img { 
            max-width: 100%; 
            height: auto; 
            display: block;
            margin: 10px 0;
          }
          iframe, table { 
            max-width: 100% !important; 
          }
        </style>
      </head>
      <body>
        ${widget.htmlContent}
      </body>
    </html>
    """;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..loadHtmlString(formattedHtml); // Fixed HTML ni load chesthunnam
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

