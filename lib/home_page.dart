import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bible/bible_home.dart';
import 'admin/admin_login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Bottom Navigation Routing
  void _onItemTapped(int index) {
    if (index == 1) { // BIBLE clicked
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BibleHome()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "W   O   G",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 4),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.wb_sunny_outlined, color: Colors.white),
            onPressed: () {
              // Theme toggle logic here if needed
            },
          ),
        ],
      ),
      
      // --- THE ORIGINAL SIDE MENU ---
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80), // Top spacing matching screenshot
            _drawerItem("P R O F I L E", () {}),
            const SizedBox(height: 20),
            _drawerItem("B O O K M A R K S", () {}),
            const SizedBox(height: 20),
            _drawerItem("S E T T I N G S", () {}),
            const SizedBox(height: 20),
            _drawerItem("A B O U T", () {}),
            
            const Spacer(), // Pushes everything below to the bottom
            
            // --- NEW ADMIN BUTTON HIDDEN HERE ---
            _drawerItem("A D M I N", () {
              Navigator.pop(context); // Close Drawer
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLogin()));
            }),
            const SizedBox(height: 40),
            
            // Footer
            const Padding(
              padding: EdgeInsets.only(left: 30, bottom: 40),
              child: Text(
                "W  O  G   S  T  U  D  I  O  S",
                style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 3),
              ),
            )
          ],
        ),
      ),

      // --- THE ORIGINAL BODY ---
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "D A I L Y   V E R S E",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 3),
            ),
            const SizedBox(height: 30),
            Text(
              "నేను నీకు తోడైయున్నాను,\nభయపడకుము. నీ దేవుడనైన\nనేను నిన్ను బలపరతును.",
              style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 22, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "— యెషయా 41:10",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            
            const SizedBox(height: 40),
            const Divider(color: Colors.white24, thickness: 1),
            const SizedBox(height: 40),

            const Text(
              "N O T I F I C A T I O N",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 3),
            ),
            const SizedBox(height: 25),
            Text(
              "నేటి ధ్యానం",
              style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              "దేవుని వాక్యం నీ పాదములకు దీపము, నీ\nత్రోవకు వెలుగు.",
              style: GoogleFonts.balooTammudu2(color: Colors.white70, fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 30),
            
            GestureDetector(
              onTap: () {},
              child: const Text(
                "EXPLORE NOW  →",
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
          ],
        ),
      ),

      // --- THE ORIGINAL BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white38,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 5), child: Icon(Icons.home_outlined)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 5), child: Icon(Icons.home)),
              label: "H O M E",
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 5), child: Icon(Icons.menu_book_outlined)),
              label: "B I B L E",
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 5), child: Icon(Icons.music_note_outlined)),
              label: "S O N G S",
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 5), child: Icon(Icons.radar_outlined)), // Using a similar icon for track
              label: "T R A C K",
            ),
          ],
        ),
      ),
    );
  }

  // Drawer Item Helper Widget to match exactly your screenshot
  Widget _drawerItem(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 2.5,
          ),
        ),
      ),
    );
  }
}
