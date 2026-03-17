import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectHMain extends StatelessWidget {
  const ProjectHMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("P R O J E C T   H", style: TextStyle(color: Colors.white, letterSpacing: 4, fontSize: 18)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          children: [
            _buildHCard(context, "H E A R T", "Thinking as a Christian", Icons.favorite_border, Colors.pinkAccent),
            const SizedBox(height: 25),
            _buildHCard(context, "H E A D", "Notes & Plans", Icons.lightbulb_outline, Colors.blueAccent),
            const SizedBox(height: 25),
            _buildHCard(context, "H A N D S", "Progress & Action Dashboard", Icons.back_hand_outlined, Colors.greenAccent),
          ],
        ),
      ),
    );
  }

  // కార్డ్స్ డిజైన్ కోసం హెల్పర్ విడ్జెట్
  Widget _buildHCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        // ఫ్యూచర్ లో లోపలి పేజీలకి వెళ్ళడానికి కనెక్షన్ ఇక్కడ ఇస్తాం
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$title is coming soon!")));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A), // మనకి ఇష్టమైన ప్యూర్ బ్లాక్ మీద డార్క్ కార్డ్ లుక్
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(width: 25),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 3)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }
}
