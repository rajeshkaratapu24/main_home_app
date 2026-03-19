import 'package:flutter/material.dart';

class JitsiLivePage extends StatelessWidget {
  const JitsiLivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Stream")),
      body: const Center(
        child: Text("Jitsi Live is currently supported on Web. Mobile version coming soon!"),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class JitsiLivePage extends StatefulWidget {
  const JitsiLivePage({super.key});

  @override
  State<JitsiLivePage> createState() => _JitsiLivePageState();
}

class _JitsiLivePageState extends State<JitsiLivePage> {
  final String viewId = 'jitsi-live-frame';

  @override
  void initState() {
    super.initState();

    // యాప్ లోపలే Jitsi ని చూపించడానికి ఒక IFrame క్రియేట్ చేస్తున్నాం
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final iframe = html.IFrameElement()
        // ఇక్కడే మ్యాజిక్ చేసాం! ఆ ప్రమోషన్ పేజీ రాకుండా లింక్ చివరన కండిషన్ పెట్టాం
        ..src = 'https://meet.jit.si/WorldOfGodLiveRoom#config.disableDeepLinking=true' 
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'camera; microphone; fullscreen; display-capture'; 
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "🔴 L I V E", 
          style: TextStyle(color: Colors.white, letterSpacing: 3, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      // ఆ IFrame ని ఇక్కడ స్క్రీన్ మీద చూపిస్తున్నాం
      body: const HtmlElementView(viewType: 'jitsi-live-frame'),
    );
  }
}