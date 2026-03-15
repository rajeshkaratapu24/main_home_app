import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bible/bible_home.dart';
import 'admin/admin_login.dart'; // Admin login page import

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("WORLD OF GOD", style: GoogleFonts.philosopher(fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      // --- Side Menu (Drawer) Start ---
      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, size: 50, color: Colors.blueAccent),
                  const SizedBox(height: 10),
                  Text("WOG APP", style: GoogleFonts.philosopher(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            _drawerItem(Icons.home, "Home", () => Navigator.pop(context)),
            _drawerItem(Icons.book, "Bible", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BibleHome()));
            }),
            
            const Divider(color: Colors.white10), // Chinna line separation kosam

            // --- Admin Button ikkada undi ---
            _drawerItem(Icons.admin_panel_settings, "Admin Portal", () {
              Navigator.pop(context); // Drawer close chesthundhi
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const AdminLogin())
              );
            }),
          ],
        ),
      ),
      // --- Side Menu End ---
      
      body: Center(
        child: Text("Welcome to World of God", style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  // Common Drawer Item Widget
  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
