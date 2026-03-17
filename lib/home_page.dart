import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bible/bible_home.dart';
import 'login_page.dart';
import 'admin/admin_dashboard.dart';
import '/songs_page.dart';
import 'project_h/project_h_splash.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) { // BIBLE clicked
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BibleHome()));
    } else if (index == 2) { // SONGS clicked
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SongsPage()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // యాప్ క్లోజ్ చేసే ముందు అడిగే డైలాగ్ బాక్స్
  Future<bool> _showExitConfirmation() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Exit App", style: TextStyle(color: Colors.white)),
        content: const Text("Do you want to close WORLD OF GOD?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("NO", style: TextStyle(color: Colors.blueAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("YES", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    ) ?? false;
  }

  // Drawer Item Helper Widget
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.pop(context);
          return;
        }

        final shouldPop = await _showExitConfirmation();
        if (shouldPop && context.mounted) {
          SystemNavigator.pop(); 
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black, // మళ్ళీ బ్లాక్ కలర్ యాడ్ చేశాం
        appBar: AppBar(
          backgroundColor: Colors.black, // ఇక్కడ కూడా బ్లాక్
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: const Text(
            "W    O    G",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 4),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.wb_sunny_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        
        drawer: Drawer(
          backgroundColor: Colors.black, // డ్రాయర్ కూడా బ్లాక్
          surfaceTintColor: Colors.transparent,
          child: Builder(
            builder: (context) {
              final user = FirebaseAuth.instance.currentUser;
              final isAdmin = user != null && (user.email == "rajeshkaratapu24@gmail.com" || user.phoneNumber == "+919999999999");
              
              String displayName = "User";
              if (user != null) {
                if (user.email != null && user.email!.isNotEmpty) {
                  displayName = user.email!.split('@')[0];
                } else if (user.phoneNumber != null) {
                  displayName = user.phoneNumber!;
                }
              }

              return Container(
                color: Colors.black, // లోపల కంటైనర్ కూడా బ్లాక్
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 80),
                    if (user == null) ...[
                      _drawerItem("L O G I N", () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                      }),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 30, bottom: 20),
                        child: Text(
                          "Hi, $displayName!",
                          style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
                        ),
                      ),
                      _drawerItem("P R O F I L E", () {}),
                      const SizedBox(height: 20),
                      _drawerItem("B O O K M A R K S", () {}),
                      const SizedBox(height: 20),
                      if (isAdmin) ...[
                        _drawerItem("A D M I N    P A N E L", () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
                        }),
                        const SizedBox(height: 20),
                      ],
                      _drawerItem("L O G O U T", () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pop(context);
                          setState(() {});
                        }
                      }),
                    ],
                    const SizedBox(height: 20),
                    _drawerItem("S E T T I N G S", () {}),
                    const SizedBox(height: 20),
                    _drawerItem("A B O U T", () {}),
                    const SizedBox(height: 100),
                    const Padding(
                      padding: EdgeInsets.only(left: 30, bottom: 40),
                      child: Text(
                        "W  O  G   S  T  U  D  I  O  S",
                        style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 3),
                      ),
                    )
                  ],
                ),
              );
            }
          ),
        ),

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

        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.black, // బాటమ్ బార్ కూడా బ్లాక్ చేసేశాం
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
                icon: Padding(padding: EdgeInsets.only(bottom: 5), child: Icon(Icons.radar_outlined)),
                label: "T R A C K",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
