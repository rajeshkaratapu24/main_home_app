import 'package:flutter/material.dart';
import 'bible/bible_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("W  O  G", style: TextStyle(letterSpacing: 6, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        child: ListView(
          children: [
            const DrawerHeader(child: Center(child: Text("W O G", style: TextStyle(fontSize: 24, letterSpacing: 5)))),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text("Bible"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BibleHome()));
              },
            ),
          ],
        ),
      ),
      body: _buildHomeBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BibleHome()));
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

  Widget _buildHomeBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("DAILY VERSE", style: TextStyle(letterSpacing: 4, color: Colors.grey, fontSize: 12)),
          SizedBox(height: 25),
          Text(
            "నేను నీకు తోడైయున్నాను,\nభయపడకుము. నీ దేవుడనైన\nనేను నిన్ను బలపరతును.",
            style: TextStyle(fontSize: 24, height: 1.6, fontWeight: FontWeight.w500),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text("\n— యెషయా 41:10", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 60.0),
            child: Divider(color: Colors.white24, thickness: 1),
          ),
          Text("NOTIFICATION", style: TextStyle(letterSpacing: 4, color: Colors.grey, fontSize: 12)),
          SizedBox(height: 25),
          Text("నేటి ధ్యానం", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text(
            "దేవుని వాక్యం నీ పాదములకు దీపము, నీ త్రోవకు వెలుగు.",
            style: TextStyle(fontSize: 18, color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}
