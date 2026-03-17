import 'package:flutter/material.dart';
import 'dart:async';
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
                const Text(
                  "WORLD OF GOD",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "eco system",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.greenAccent.withOpacity(0.9), // లైట్ గ్రీన్ కలర్
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
