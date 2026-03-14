import 'package:flutter/material.dart';
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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
      ),
      home: const HomePage(),
    );
  }
}
