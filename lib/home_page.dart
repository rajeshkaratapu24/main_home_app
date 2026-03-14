import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Drawer functionality automatic ga open avtundi
          },
        ),
        title: const Text("W  O  G", 
          style: TextStyle(letterSpacing: 6, fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.light_mode_outlined), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Center(child: Text("W O G", style: TextStyle(fontSize: 25, letterSpacing: 5))),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text("Bible"),
              onTap: () {
                // Ikkada inkoka repo connect chestham tharvatha
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
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
            const SizedBox(height: 15),
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
            const SizedBox(height: 40),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text("EXPLORE NOW →", style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 2)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: "BIBLE"),
          BottomNavigationBarItem(icon: Icon(Icons.music_note_outlined), label: "SONGS"),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes_outlined), label: "TRACK"),
        ],
      ),
    );
  }
}
