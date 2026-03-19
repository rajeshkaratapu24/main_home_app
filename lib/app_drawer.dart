import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0A0A0A), // ప్యూర్ డార్క్ థీమ్
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ------------------------------------
          // DRAWER HEADER (టాప్ లో బ్రాండింగ్)
          // ------------------------------------
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              // బ్యాక్‌గ్రౌండ్ లో చిన్న ఇమేజ్ కావాలంటే ఈ కింద లైన్ వాడొచ్చు (లేదా తీసేయొచ్చు)
              // image: DecorationImage(image: NetworkImage('https://...'), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.church, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  "WORLD OF GOD",
                  style: GoogleFonts.righteous(color: Colors.white, fontSize: 24, letterSpacing: 2),
                ),
                const SizedBox(height: 5),
                Text(
                  "దేవుని వాక్యం - అనుదిన ధ్యానం",
                  style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ),

          // ------------------------------------
          // MAIN MENU ITEMS (మెయిన్ ఆప్షన్స్)
          // ------------------------------------
          _buildMenuItem(context, "L O G I N", Icons.login, Colors.blueAccent, () {
            // లాగిన్ పేజీకి వెళ్ళే కోడ్ ఇక్కడ వస్తుంది
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening Login...")));
          }),
          _buildMenuItem(context, "B O O K S", Icons.menu_book, Colors.purpleAccent, () {
            // బుక్స్ పేజీకి 
          }),
          _buildMenuItem(context, "AUDIO MESSAGES", Icons.headset, Colors.orangeAccent, () {
            // ఆడియో మెసేజెస్ కి
          }),
          _buildMenuItem(context, "Q & A", Icons.question_answer, Colors.greenAccent, () {
            // Q&A సెక్షన్ కి
          }),

          // ------------------------------------
          // DIVIDER (లైన్)
          // ------------------------------------
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Divider(color: Colors.white12, thickness: 1),
          ),

          // ------------------------------------
          // FOOTER ITEMS (కింద ఉండే ఆప్షన్స్)
          // ------------------------------------
          _buildMenuItem(context, "CONTACT US", Icons.contact_mail, Colors.tealAccent, () {
            // కాంటాక్ట్ పేజీకి
          }),
          _buildMenuItem(context, "SHARE THIS APP", Icons.share, Colors.pinkAccent, () {
            // షేర్ బటన్ నొక్కగానే డైరెక్ట్ గా వాట్సాప్/ఇతర యాప్స్ కి షేర్ అవుతుంది
            Share.share(
              "WORLD OF GOD యాప్ ద్వారా దేవుని వాక్యాన్ని, పాటలను వినండి. ఇప్పుడే డౌన్‌లోడ్ చేసుకోండి: https://your-app-link.com"
            );
          }),
          _buildMenuItem(context, "ABOUT US", Icons.info_outline, Colors.amberAccent, () {
            // అబౌట్ పేజీకి
          }),
          _buildMenuItem(context, "CREDENTIALS", Icons.verified_user, Colors.grey, () {
            // క్రెడెన్షియల్స్ / యాప్ క్రియేటర్స్ పేజీకి
          }),

          // యాప్ వెర్షన్
          const SizedBox(height: 30),
          const Center(
            child: Text("App Version 1.0.0", style: TextStyle(color: Colors.white24, fontSize: 12)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // డ్రాయర్ లోని ప్రతి ఆప్షన్ డిజైన్ (లైన్ బై లైన్ కోడ్ తగ్గించడానికి)
  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Color iconColor, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25.0),
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
      onTap: () {
        Navigator.pop(context); // మెనూలో ఆప్షన్ నొక్కగానే ముందు డ్రాయర్ క్లోజ్ అవుతుంది
        onTap(); // ఆ తర్వాత నువ్వు ఇచ్చిన పేజీకి వెళ్తుంది
      },
    );
  }
}
