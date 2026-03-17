import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ఫైర్‌బేస్ కీస్ ఉండే ఫైల్
import 'splash_screen.dart';

// గ్లోబల్ గా థీమ్ ని కంట్రోల్ చేయడానికి ఈ ఒక్క లైన్ రాస్తున్నాం
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'WORLD OF GOD',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode, // ఇక్కడే థీమ్ ఆటోమేటిక్ గా మారుతుంది
          
          // ------------------------------------
          // 1. LIGHT THEME (కొత్తగా యాడ్ చేసింది)
          // ------------------------------------
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Colors.blueAccent,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.black38,
              elevation: 10,
            ),
            cardColor: Colors.grey[100],
            dialogBackgroundColor: Colors.white,
            drawerTheme: const DrawerThemeData(
              backgroundColor: Colors.white,
            ),
          ),

          // ------------------------------------
          // 2. DARK THEME (నీ పాత బ్లాక్/గ్రే థీమ్)
          // ------------------------------------
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212), 
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              elevation: 0, 
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1A1A1A), 
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white38,
              elevation: 10,
            ),
            cardColor: const Color(0xFF1E1E1E),
            dialogBackgroundColor: const Color(0xFF1E1E1E),
            drawerTheme: const DrawerThemeData(
              backgroundColor: Color(0xFF121212),
            ),
          ),
          home: const SplashScreen(), 
        );
      },
    );
  }
}
