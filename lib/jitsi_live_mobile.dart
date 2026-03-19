import 'package:flutter/material.dart';

class JitsiLivePage extends StatelessWidget {
  const JitsiLivePage({super.key}); // const ఖచ్చితంగా ఉండాలి

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Stream"), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          "Jitsi Live is supported on Web.\nMobile version coming soon!",
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
