import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bible/bible_home.dart';
import 'login_page.dart';
import 'admin/admin_dashboard.dart';
import '/songs_page.dart';
import 'project_h/project_h_splash.dart';
import 'main.dart'; // థీమ్ కంట్రోల్ చేయడానికి దీన్ని కొత్తగా యాడ్ చేశాం

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
    } else if (index == 3) { // PROJECT H clicked 
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProjectHSplash()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // యాప్ క్లోజ్ చేసే ముందు అడిగే డైలాగ్ బాక్స్
  Future<bool> _showExitConfirmation() async {
    // డైలాగ్ బాక్స్ కూడా థీమ్ కి తగ్గట్టు మారాలి కదా
    bool isLight = Theme.of(context).brightness == Brightness.light;
    Color cardColor = isLight ? Colors.white : const Color(0xFF1A1A1A);
    Color textColor = isLight ? Colors.black : Colors.white;
    Color subTextColor = isLight ? Colors.black54 : Colors.white70;

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text("Exit App", style: TextStyle(color: textColor)),
        content: Text("Do you want to close WORLD OF GOD?", style: TextStyle(color: subTextColor)),
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

  // Drawer Item Helper Widget (కలర్ డైనమిక్ గా మారేలా చేశాం)
  Widget _drawerItem(String title, VoidCallback onTap, Color tColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Text(
          title,
          style: TextStyle(
            color: tColor,
            fontSize: 16,
            letterSpacing: 2.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ఇక్కడే అసలు మ్యాజిక్ ఉంది: థీమ్ లైట్ ఆ? డార్క్ ఆ? చెక్ చేస్తుంది
    bool isLight = Theme.of(context).brightness == Brightness.light;
    
    // థీమ్ ని బట్టి ఆటోమేటిక్ గా రంగులు సెట్ అవుతాయి
    Color bgColor = isLight ? Colors.white : Colors.black;
    Color textColor = isLight ? Colors.black : Colors.white;
    Color subTextColor = isLight ? Colors.black54 : Colors.white70;

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
        backgroundColor: bgColor, // డైనమిక్ బ్యాక్‌గ్రౌండ్
        appBar: AppBar(
          backgroundColor: bgColor, 
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: textColor),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text(
            "W    O    G",
            style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 4),
          ),
          centerTitle: true,
          actions: [
            // ఇక్కడే నీ సూర్యుడు/చంద్రుడు బటన్ పెట్టాం
            IconButton(
              icon: Icon(isLight ? Icons.nights_stay : Icons.wb_sunny_outlined, color: textColor),
              onPressed: () {
                // నొక్కగానే లైట్/డార్క్ కి మారుతుంది (main.dart లోని themeNotifier కి కనెక్ట్ చేసాం)
                themeNotifier.value = isLight ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ],
        ),

        drawer: Drawer(
          backgroundColor: bgColor, 
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
                color: bgColor, 
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 80),
                    if (user == null) ...[
                      _drawerItem("L O G I N", () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                      }, textColor), // కలర్ కూడా పంపిస్తున్నాం
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 30, bottom: 20),
                        child: Text(
                          "Hi, $displayName!",
                          style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
                        ),
                      ),
                      _drawerItem("P R O F I L E", () {}, textColor),
                      const SizedBox(height: 20),
                      _drawerItem("B O O K M A R K S", () {}, textColor),
                      const SizedBox(height: 20),
                      if (isAdmin) ...[
                        _drawerItem("A D M I N    P A N E L", () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
                        }, textColor),
                        const SizedBox(height: 20),
                      ],
                      _drawerItem("L O G O U T", () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pop(context);
                          setState(() {});
                        }
                      }, textColor),
                    ],
                    const SizedBox(height: 20),
                    _drawerItem("S E T T I N G S", () {}, textColor),
                    const SizedBox(height: 20),
                    _drawerItem("A B O U T", () {}, textColor),
                    const SizedBox(height: 100),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, bottom: 40),
                      child: Text(
                        "W  O  G   S  T  U  D  I  O  S",
                        style: TextStyle(color: subTextColor, fontSize: 12, letterSpacing: 3),
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
              Text(
                "D A I L Y   V E R S E",
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 3),
              ),
              const SizedBox(height: 30),
              Text(
                "నేను నీకు తోడైయున్నాను,\nభయపడకుము. నీ దేవుడనైన\nనేను నిన్ను బలపరతును.",
                style: GoogleFonts.balooTammudu2(color: textColor, fontSize: 22, height: 1.5),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "— యెషయా 41:10",
                  style: TextStyle(color: subTextColor, fontSize: 14),
                ),
              ),
              const SizedBox(height: 40),
              Divider(color: isLight ? Colors.black12 : Colors.white24, thickness: 1),
              const SizedBox(height: 40),
              Text(
                "N O T I F I C A T I O N",
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 3),
              ),
              const SizedBox(height: 25),
              Text(
                "నేటి ధ్యానం",
                style: GoogleFonts.balooTammudu2(color: textColor, fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                "దేవుని వాక్యం నీ పాదములకు దీపము, నీ\nత్రోవకు వెలుగు.",
                style: GoogleFonts.balooTammudu2(color: subTextColor, fontSize: 18, height: 1.5),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {},
                child: Text(
                  "EXPLORE NOW  →",
                  style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
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
            backgroundColor: bgColor, 
            type: BottomNavigationBarType.fixed,
            selectedItemColor: isLight ? Colors.blueAccent : Colors.white,
            unselectedItemColor: isLight ? Colors.black38 : Colors.white38,
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
                icon: Padding(padding: EdgeInsets.only(bottom: 5), child: Icon(Icons.hub_outlined)),
                label: "P R O J E C T  H",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
