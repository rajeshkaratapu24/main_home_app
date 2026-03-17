import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ఫైర్‌బేస్ కీస్ ఉండే ఫైల్
import 'splash_screen.dart';

void main() async {
  // యాప్ స్టార్ట్ అయ్యే ముందే ఫైర్‌బేస్ ని కనెక్ట్ చేస్తున్నాం
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WORLD OF GOD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        
        // 1. మెయిన్ బ్యాక్‌గ్రౌండ్ (Premium Dark Gray)
        scaffoldBackgroundColor: const Color(0xFF121212), 
        
        // 2. యాప్‌బార్ (పైన ఉండే హెడ్డింగ్ బార్) థీమ్
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0, // గీత రాకుండా స్మూత్ గా ఉండటానికి
          iconTheme: IconThemeData(color: Colors.white),
        ),
        
        // 3. బాటమ్ నేవిగేషన్ బార్ థీమ్ (మెయిన్ దానికంటే కొంచెం లైట్ గ్రే)
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A1A), 
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white38,
          elevation: 10,
        ),
        
        // 4. కార్డ్స్, డైలాగ్ బాక్సులు, డ్రాయర్ (సైడ్ మెనూ) థీమ్
        cardColor: const Color(0xFF1E1E1E),
        dialogBackgroundColor: const Color(0xFF1E1E1E),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF121212),
        ),
      ),
      home: const SplashScreen(), 
    );
  }
}
