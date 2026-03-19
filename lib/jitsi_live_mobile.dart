import 'package:flutter/material.dart';

class JitsiLivePage extends StatelessWidget {
  const JitsiLivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Stream"), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          "Jitsi Live is supported on Web.\nMobile version coming soon!",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
