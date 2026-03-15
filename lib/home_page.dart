import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bible/bible_home.dart';
import 'admin/admin_login.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("WORLD OF GOD", 
          style: GoogleFonts.philosopher(
            fontWeight: FontWeight.bold, 
            letterSpacing: 2,
            color: Colors.white
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      
      // --- Side Menu (Drawer) ---
      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Color(0xFF1A1A1A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, size: 50, color: Colors.blueAccent),
                  const SizedBox(height: 10),
                  Text("WOG APP", 
                    style: GoogleFonts.philosopher(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            _drawerItem(Icons.home, "Home", () => Navigator.pop(context)),
            _drawerItem(Icons.book, "Bible", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BibleHome()));
            }),
            const Divider(color: Colors.white10),
            
            // ADMIN PORTAL BUTTON
            _drawerItem(Icons.admin_panel_settings, "Admin Portal", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLogin()));
            }),
          ],
        ),
      ),

      // --- Main Body with Grid ---
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mee Kosam..", 
              style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: [
                  _featureCard(context, "పరిశుద్ధ గ్రంథము", Icons.menu_book, Colors.orange, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BibleHome()));
                  }),
                  _featureCard(context, "పాటలు", Icons.music_note, Colors.blueAccent, () {
                    // Songs Page ki vellali
                  }),
                  _featureCard(context, "ఆడియో సందేశాలు", Icons.mic, Colors.greenAccent, () {
                    // Audio Page ki vellali
                  }),
                  _featureCard(context, "బుక్ మార్క్స్", Icons.bookmark, Colors.redAccent, () {
                    // Bookmarks Page
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Feature Card Widget
  Widget _featureCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 15),
            Text(title, 
              textAlign: TextAlign.center,
              style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // Drawer Item Widget
  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }
}
