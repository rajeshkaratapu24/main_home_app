import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'upload_song.dart'; // మనం కొత్తగా క్రియేట్ చేసిన ఫైల్ ఇక్కడ ఇంపోర్ట్ చేశాం

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _adminCard("పాటలు అప్‌లోడ్", Icons.music_note, Colors.blueAccent, () {
                    // పాటల అప్‌లోడ్ పేజీకి వెళ్లే లింక్
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadSong()));
                  }),
                  _adminCard("ఆడియో సందేశాలు", Icons.mic, Colors.orangeAccent, () {
                    // ఆడియో మెసేజెస్
                  }),
                  _adminCard("నేటి ధ్యానం", Icons.menu_book, Colors.greenAccent, () {
                    // డైలీ వాక్యం అప్‌డేట్
                  }),
                  _adminCard("యూజర్స్", Icons.people, Colors.purpleAccent, () {
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

  // డార్క్ థీమ్ అడ్మిన్ కార్డ్ డిజైన్
  Widget _adminCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
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
