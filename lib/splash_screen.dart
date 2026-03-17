import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart'; // గూగుల్ ఫాంట్స్ ఇంపోర్ట్
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // యానిమేషన్ కంట్రోలర్ (2 సెకన్ల పాటు జరుగుతుంది)
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // స్మూత్ గా రావడానికి కరువ్ యానిమేషన్
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    // యానిమేషన్ స్టార్ట్ చేయి
    _controller.forward();

    // 3 సెకన్ల తర్వాత ఆటోమేటిక్ గా హోమ్ పేజీకి వెళ్ళిపోతుంది
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), 
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // బ్యాక్‌గ్రౌండ్ బ్లాక్
      body: Center(
        child: FadeTransition(
          opacity: _controller, // నెమ్మదిగా కనిపిస్తుంది
          child: ScaleTransition(
            scale: _animation, // చిన్న సైజు నుంచి పెద్దగా అవుతుంది
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "WORLD OF GOD",
                  style: GoogleFonts.ubuntu( // ఉబుంటు ఫాంట్ అప్లై చేశాం
                    fontSize: 38,
                    fontWeight: FontWeight.w300, // ఇది స్లిమ్ (Light) లుక్ ఇస్తుంది
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "eco system",
                  style: GoogleFonts.ubuntu(
                    fontSize: 18,
                    fontWeight: FontWeight.w300, // ఇది కూడా స్లిమ్ గా
                    color: Colors.greenAccent.withOpacity(0.9),
                    letterSpacing: 3,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
