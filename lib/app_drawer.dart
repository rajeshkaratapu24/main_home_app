import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart'; 
import 'login_page.dart';
import 'admin/admin_dashboard.dart';
import 'books_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // ఐకాన్స్ తో ఉన్న డ్రాయర్ ఆప్షన్ డిజైన్
  Widget _buildDrawerItem(String title, IconData icon, Color iconColor, Color textColor, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 30.0),
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    Color bgColor = isLight ? Colors.white : Colors.black;
    Color textColor = isLight ? Colors.black : Colors.white;
    Color subTextColor = isLight ? Colors.black54 : Colors.white70;

    final user = FirebaseAuth.instance.currentUser;
    // అడ్మిన్ చెక్ లాజిక్
    final isAdmin = user != null && (user.email == "rajeshkaratapu24@gmail.com" || user.phoneNumber == "+919999999999");

    String displayName = "User";
    if (user != null) {
      if (user.email != null && user.email!.isNotEmpty) {
        displayName = user.email!.split('@')[0];
      } else if (user.phoneNumber != null) {
        displayName = user.phoneNumber!;
      }
    }

    return Drawer(
      backgroundColor: bgColor, 
      surfaceTintColor: Colors.transparent,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // --- HEADER (బ్రాండింగ్) ---
          DrawerHeader(
            decoration: BoxDecoration(color: isLight ? Colors.grey[200] : const Color(0xFF1A1A1A)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.church, color: isLight ? Colors.blueAccent : Colors.white, size: 40),
                const SizedBox(height: 10),
                Text("WORLD OF GOD", style: GoogleFonts.righteous(color: textColor, fontSize: 22, letterSpacing: 2)),
                if (user != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text("Welcome, $displayName", style: TextStyle(color: Colors.blueAccent, fontSize: 14)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // --- యూజర్ ఆప్షన్స్ (లాగిన్ అయితేనే ప్రొఫైల్ వస్తుంది) ---
          if (user == null) ...[
            _buildDrawerItem("L O G I N", Icons.login, Colors.blueAccent, textColor, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            }), 
          ] else ...[
            _buildDrawerItem("P R O F I L E", Icons.person, Colors.blueAccent, textColor, () {
              Navigator.pop(context);
            }),
            _buildDrawerItem("B O O K M A R K S", Icons.bookmark, Colors.amber, textColor, () {
              Navigator.pop(context);
            }),
          ],

          const SizedBox(height: 10),

          // app_drawer.dart లో ఈ సెక్షన్ ని అప్‌డేట్ చెయ్

// ... మిగతా కోడ్

// --- MAIN MENU ITEMS ---
_buildDrawerItem("B O O K S", Icons.menu_book, Colors.purpleAccent, textColor, () {
  // డ్రాయర్ ని క్లోజ్ చేసి...
  Navigator.pop(context);
  // సాఫ్ట్ UI ఉన్న కొత్త Books పేజీకి వెళ్తాం
  Navigator.push(context, MaterialPageRoute(builder: (context) => const BooksPage()));
}),

// AUDIO MESSAGES ... మిగతా కోడ్

          
          _buildDrawerItem("AUDIO MESSAGES", Icons.headset, Colors.orangeAccent, textColor, () {
            Navigator.pop(context);
          }),

          _buildDrawerItem("Q & A", Icons.question_answer, Colors.greenAccent, textColor, () {
            Navigator.pop(context);
          }),

          // --- ADMIN ప్యానెల్ ---
          if (isAdmin) ...[
            const SizedBox(height: 10),
            _buildDrawerItem("A D M I N   P A N E L", Icons.admin_panel_settings, Colors.pinkAccent, textColor, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
            }),
          ],

          const SizedBox(height: 10),
          _buildDrawerItem("S E T T I N G S", Icons.settings, Colors.grey, textColor, () {
            Navigator.pop(context);
          }),

          // --- DIVIDER (లైన్) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Divider(color: isLight ? Colors.black12 : Colors.white12, thickness: 1),
          ),

          // --- FOOTER ITEMS ---
          _buildDrawerItem("CONTACT US", Icons.contact_mail, Colors.tealAccent, textColor, () {
            Navigator.pop(context);
          }),

          _buildDrawerItem("SHARE THIS APP", Icons.share, Colors.blue, textColor, () {
            Navigator.pop(context);
            Share.share("WORLD OF GOD యాప్ ద్వారా దేవుని వాక్యాన్ని, పాటలను వినండి. ఇప్పుడే డౌన్‌లోడ్ చేసుకోండి: https://your-app-link.com");
          }),

          _buildDrawerItem("ABOUT US", Icons.info_outline, Colors.amberAccent, textColor, () {
            Navigator.pop(context);
          }),

          _buildDrawerItem("CREDENTIALS", Icons.verified_user, Colors.grey, textColor, () {
            Navigator.pop(context);
          }),

          // లాగౌట్ బటన్
          if (user != null) ...[
            const SizedBox(height: 15),
            _buildDrawerItem("L O G O U T", Icons.logout, Colors.redAccent, textColor, () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pop(context);
                // హోమ్ పేజీ రీఫ్రెష్ అవ్వడానికి ఒక చిన్న ట్రిక్
                Navigator.pushReplacementNamed(context, '/'); 
              }
            }),
          ],

          const SizedBox(height: 50),
          Center(child: Text("W  O  G   S  T  U  D  I  O  S", style: TextStyle(color: subTextColor, fontSize: 12, letterSpacing: 3))),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
