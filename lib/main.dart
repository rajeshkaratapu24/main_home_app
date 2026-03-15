import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ఫైర్‌బేస్ కీస్ ఉండే ఫైల్
import 'home_page.dart';

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
        scaffoldBackgroundColor: Colors.black,
      ),
      home: HomePage(), // ఇక్కడ const అవసరం లేదు
    );
  }
}
