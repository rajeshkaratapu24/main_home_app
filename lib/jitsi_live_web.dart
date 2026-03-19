import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class JitsiLivePage extends StatefulWidget {
  const JitsiLivePage({super.key});

  @override
  State<JitsiLivePage> createState() => _JitsiLivePageState();
}

class _JitsiLivePageState extends State<JitsiLivePage> {
  final String viewId = "jitsi-iframe";

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = "https://meet.jit.si/WorldOfGodLive" // నీ లైవ్ లింక్
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Web Live Stream")),
      body: HtmlElementView(viewType: viewId),
    );
  }
}
