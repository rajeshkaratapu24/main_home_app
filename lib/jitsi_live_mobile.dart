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
