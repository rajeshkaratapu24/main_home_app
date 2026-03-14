import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text("W  O  G", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.light_mode_outlined), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          children: const [
             DrawerHeader(child: Text("W O G Menu", style: TextStyle(color: Colors.white, fontSize: 24))),
             // Ikada nuvvu future lo create chese repo links ki buttons pedadham
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("DAILY VERSE"),
            const SizedBox(height: 20),
            const Text(
              "నేను నీకు తోడైయున్నాను,\nభయపడకుము. నీ దేవుడనైన\nనేను నిన్ను బలపరతును.",
              style: TextStyle(fontSize: 22, height: 1.5, fontWeight: FontWeight.w400),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Text("\n— యెషయా 41:10", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            const Divider(height: 100, color: Colors.white24),
            _buildSectionHeader("NOTIFICATION"),
            const SizedBox(height: 20),
            const Text("నేటి ధ్యానం", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "దేవుని వాక్యం నీ పాదములకు దీపము, నీ త్రోవకు వెలుగు.",
              style: TextStyle(fontSize: 18, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {},
              child: const Text("EXPLORE NOW →", style: TextStyle(color: Colors.white, letterSpacing: 1.2)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: "BIBLE"),
          BottomNavigationBarItem(icon: Icon(Icons.music_note_outlined), label: "SONGS"),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes_outlined), label: "TRACK"),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, letterSpacing: 4, color: Colors.white70),
    );
  }
}
