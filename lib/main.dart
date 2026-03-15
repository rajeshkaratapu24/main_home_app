import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

void main() {
  runApp(const WOGApp());
}

class WOGApp extends StatelessWidget {
  const WOGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'W O G',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.balooTammudu2TextTheme(ThemeData.dark().textTheme),
      ),
      home: const HomePage(),
    );
  }
}
