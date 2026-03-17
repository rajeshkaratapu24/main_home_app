import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart'; 
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // 3 సెకన్ల తర్వాత ఆటోమేటిక్ గా హోమ్ పేజీకి వెళ్ళిపోతుంది (యానిమేషన్స్ ఏమీ లేవు)
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), 
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "WORLD OF GOD",
              style: GoogleFonts.ubuntu( 
                fontSize: 38,
                fontWeight: FontWeight.w300, 
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "eco system",
              style: GoogleFonts.ubuntu(
                fontSize: 18,
                fontWeight: FontWeight.w300, 
                color: Colors.white, // గ్రీన్ తీసేశాం, నార్మల్ వైట్ పెట్టాం
                letterSpacing: 3,
                // ఇటాలిక్ తీసేశాం
              ),
            ),
          ],
        ),
      ),
    );
  }
}
