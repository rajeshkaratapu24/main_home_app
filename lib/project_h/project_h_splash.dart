import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'project_h_main.dart';

class ProjectHSplash extends StatefulWidget {
  const ProjectHSplash({super.key});

  @override
  State<ProjectHSplash> createState() => _ProjectHSplashState();
}

class _ProjectHSplashState extends State<ProjectHSplash> {
  @override
  void initState() {
    super.initState();
    // 2 సెకన్ల పాటు స్ప్లాష్ స్క్రీన్ ఉండి, మెయిన్ పేజీకి వెళ్తుంది
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProjectHMain()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "PROJECT H",
          style: GoogleFonts.ubuntu(
            fontSize: 35,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: 6,
          ),
        ),
      ),
    );
  }
}
