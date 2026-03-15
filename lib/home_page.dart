import 'package:flutter/material.dart';
// FIX: Ikkada main.dart badulu bible_home.dart ni import cheyyali
import 'package:wog_bible_section/bible_home.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("W  O  G", 
          style: TextStyle(letterSpacing: 6, fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        onTap: (index) {
          if (index == 1) {
            // FIX: Direct ga BibleHome() ni call chestunnam
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BibleHome()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: "BIBLE"),
          BottomNavigationBarItem(icon: Icon(Icons.music_note_outlined), label: "SONGS"),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes_outlined), label: "TRACK"),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("DAILY VERSE", style: TextStyle(letterSpacing: 4, color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 25),
          const Text(
            "నేను నీకు తోడైయున్నాను,\nభయపడకుము. నీ దేవుడనైన\nనేను నిన్ను బలపరతును.",
            style: TextStyle(fontSize: 24, height: 1.6, fontWeight: FontWeight.w500),
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: Text("— యెషయా 41:10", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60.0),
            child: Divider(color: Colors.white24, thickness: 1),
          ),
          const Text("NOTIFICATION", style: TextStyle(letterSpacing: 4, color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 25),
          const Text("నేటి ధ్యానం", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text(
            "దేవుని వాక్యం నీ పాదములకు దీపము, నీ త్రోవకు వెలుగు.",
            style: TextStyle(fontSize: 18, color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: ListView(
        children: [
          const DrawerHeader(child: Center(child: Text("W O G", style: TextStyle(fontSize: 24, letterSpacing: 5)))),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text("Bible"),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BibleHome()));
            },
          ),
        ],
      ),
    );
  }
}
