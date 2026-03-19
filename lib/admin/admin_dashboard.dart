import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart'; // ఫైర్‌బేస్ రియల్ టైమ్ డేటాబేస్ (BGM కోసం)
import 'admin_albums.dart'; 
import 'upload_book.dart'; // మన కొత్త పుస్తకాల అప్‌లోడ్ పేజీ

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  // ---------------------------------------------------------
  // బైబిల్ BGM లింక్ మార్చడానికి పాత డైలాగ్ బాక్స్ లాజిక్
  // ---------------------------------------------------------
  Future<void> _showBgmDialog() async {
    TextEditingController bgmController = TextEditingController();
    final ref = FirebaseDatabase.instance.ref("admin_settings/bible_bgm");
    
    final snapshot = await ref.get();
    if (snapshot.exists) {
      bgmController.text = snapshot.value.toString();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text("బైబిల్ మ్యూజిక్ లింక్", style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 20)),
          content: TextField(
            controller: bgmController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter mp3 URL here...",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () async {
                await ref.set(bgmController.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Music Link Updated Successfully!"), backgroundColor: Colors.green),
                  );
                }
              },
              child: const Text("SAVE", style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("W O G   A D M I N", style: TextStyle(color: Colors.white, letterSpacing: 3, fontSize: 18)),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white24, height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "C O N T R O L   P A N E L", 
              style: TextStyle(color: Colors.white54, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 25),
            
            // ---------------------------------------------------------
            // అడ్మిన్ కార్డుల గ్రిడ్ (ఇప్పుడు 6 కార్డులు ఉంటాయి)
            // ---------------------------------------------------------
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  // 1. ఆల్బమ్స్ & పాటలు
                  _adminCard("ఆల్బమ్స్ & పాటలు", Icons.album, Colors.blueAccent, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminAlbums()));
                  }),
                  
                  // 2. పుస్తకాలు (BOOKS SECTION) - కొత్తగా యాడ్ చేసింది
                  _adminCard("పుస్తకాలు", Icons.menu_book, Colors.purpleAccent, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadBook()));
                  }),

                  // 3. బైబిల్ మ్యూజిక్
                  _adminCard("బైబిల్ మ్యూజిక్", Icons.library_music, Colors.pinkAccent, () {
                    _showBgmDialog();
                  }),

                  // 4. ఆడియో సందేశాలు
                  _adminCard("ఆడియో సందేశాలు", Icons.mic, Colors.orangeAccent, () {
                    // ఆడియో మెసేజెస్ కోసం ఫ్యూచర్ లో ఇక్కడ రాద్దాం
                  }),

                  // 5. నేటి ధ్యానం
                  _adminCard("నేటి ధ్యానం", Icons.wb_sunny_outlined, Colors.greenAccent, () {
                    // డైలీ వాక్యం అప్‌డేట్
                  }),

                  // 6. యూజర్స్
                  _adminCard("యూజర్స్", Icons.people, Colors.tealAccent, () {
                    // రిజిస్టర్ అయిన యూజర్స్ లిస్ట్
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // డార్క్ థీమ్ అడ్మిన్ కార్డ్ డిజైన్ (నీ పాత స్టైల్ లోనే ఉంచాను)
  Widget _adminCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(height: 15),
            Text(
              title,
              style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
