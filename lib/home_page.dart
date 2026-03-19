import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'bible/bible_home.dart';
import '/songs_page.dart';
import 'project_h/project_h_splash.dart';
import 'main.dart'; 
import 'jitsi_live_page.dart';
import 'app_drawer.dart'; // <--- మన కొత్త సైడ్ మెనూ ఫైల్ ని ఇక్కడ ఇంపోర్ట్ చేశాం!

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    if (index == 1) { 
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BibleHome()));
    } else if (index == 2) { 
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SongsPage()));
    } else if (index == 3) { 
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProjectHSplash()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<bool> _showExitConfirmation() async {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    Color cardColor = isLight ? Colors.white : const Color(0xFF1A1A1A);
    Color textColor = isLight ? Colors.black : Colors.white;
    Color subTextColor = isLight ? Colors.black54 : Colors.white70;

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Exit App", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
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

  Widget _buildPremiumCard({required Widget child, required bool isLight}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isLight ? Colors.grey[100] : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  void _joinJitsiLive() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JitsiLivePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    Color bgColor = isLight ? Colors.white : Colors.black;
    Color textColor = isLight ? Colors.black : Colors.white;
    Color subTextColor = isLight ? Colors.black54 : Colors.white70;

    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          Navigator.pop(context);
          return;
        }
        final shouldPop = await _showExitConfirmation();
        if (shouldPop && context.mounted) {
          SystemNavigator.pop(); 
        }
      },
      child: Scaffold(
        key: _scaffoldKey, 
        backgroundColor: bgColor, 
        appBar: AppBar(
          backgroundColor: bgColor, 
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu, color: textColor),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(), 
          ),
          title: Text(
            "W    O    G",
            style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 4),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(isLight ? Icons.nights_stay : Icons.wb_sunny_outlined, color: textColor),
              onPressed: () {
                themeNotifier.value = isLight ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ],
        ),

        // ---------------------------------------------------------
        // మ్యాజిక్ ఇక్కడే! సైడ్ మెనూ మొత్తం ఈ ఒక్క లైన్ తో వస్తుంది
        // ---------------------------------------------------------
        drawer: const AppDrawer(),

        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          children: [
            _buildPremiumCard(
              isLight: isLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("D A I L Y   V E R S E", style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 3)),
                  const SizedBox(height: 20),
                  Text(
                    "నేను నీకు తోడైయున్నాను,\nభయపడకుము. నీ దేవుడనైన\nనేను నిన్ను బలపరతును.",
                    style: GoogleFonts.balooTammudu2(color: textColor, fontSize: 22, height: 1.5),
                  ),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text("— యెషయా 41:10", style: TextStyle(color: subTextColor, fontSize: 14)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            _buildPremiumCard(
              isLight: isLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("N O T I F I C A T I O N", style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 3)),
                  const SizedBox(height: 20),
                  Text("నేటి ధ్యానం", style: GoogleFonts.balooTammudu2(color: textColor, fontSize: 20)),
                  const SizedBox(height: 5),
                  Text(
                    "దేవుని వాక్యం నీ పాదములకు దీపము, నీ త్రోవకు వెలుగు.",
                    style: GoogleFonts.balooTammudu2(color: subTextColor, fontSize: 18, height: 1.5),
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: () {},
                    child: Text("EXPLORE NOW  →", style: TextStyle(color: isLight ? Colors.blueAccent : Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            _buildPremiumCard(
              isLight: isLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sensors, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 10),
                      Text("L I V E   S T R E A M", style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 3)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("Evening Fellowship & Prayer", style: GoogleFonts.ubuntu(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    "Join our daily live session with the community. Connect directly via Jitsi.",
                    style: TextStyle(color: subTextColor, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _joinJitsiLive, 
                      child: const Text("JOIN LIVE NOW", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),

        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: isLight ? Colors.white : const Color(0xFF1A1A1A), 
            type: BottomNavigationBarType.fixed,
            selectedItemColor: isLight ? Colors.blueAccent : Colors.white,
            unselectedItemColor: isLight ? Colors.black38 : Colors.white38,
            elevation: 20,
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
