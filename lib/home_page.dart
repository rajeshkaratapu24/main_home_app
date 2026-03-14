import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Toggle kosam variable
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        // 1. Side Menu (Drawer) Fix
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: isDarkMode ? Colors.black : Colors.blue),
                child: const Text("W O G Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text("Bible"),
                onTap: () => _openDummyPage(context, "Bible Section"),
              ),
              ListTile(
                leading: const Icon(Icons.music_note),
                title: const Text("Songs"),
                onTap: () => _openDummyPage(context, "Songs Section"),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          elevation: 0,
          title: const Text("W  O  G", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            // 2. Dark/Light Mode Toggle Fix
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("DAILY VERSE", style: TextStyle(letterSpacing: 4, color: Colors.grey)),
              const SizedBox(height: 20),
              const Text(
                "నేను నీకు తోడైయున్నాను,\nభయపడకుము. నీ దేవుడనైన\nనేను నిన్ను బలపరతును.",
                style: TextStyle(fontSize: 22, height: 1.5, fontWeight: FontWeight.bold),
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: Text("\n— యెషయా 41:10", style: TextStyle(color: Colors.grey, fontSize: 16)),
              ),
              const Divider(height: 80, color: Colors.white24),
              const Text("NOTIFICATION", style: TextStyle(letterSpacing: 4, color: Colors.grey)),
              const SizedBox(height: 20),
              const Text("నేటి ధ్యానం", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                "దేవుని వాక్యం నీ పాదములకు దీపము, నీ త్రోవకు వెలుగు.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              // 3. Explore Button Navigation Fix
              ElevatedButton(
                onPressed: () => _openDummyPage(context, "Daily Devotion Details"),
                child: const Text("EXPLORE NOW →"),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          onTap: (index) {
            if (index == 1) _openDummyPage(context, "Bible");
            if (index == 2) _openDummyPage(context, "Songs");
            if (index == 3) _openDummyPage(context, "Track");
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "BIBLE"),
            BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "SONGS"),
            BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: "TRACK"),
          ],
        ),
      ),
    );
  }

  // Dummy Page Function
  void _openDummyPage(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(child: Text("Welcome to $title\n(Coming Soon from another Repo)", textAlign: TextAlign.center)),
        ),
      ),
    );
  }
}
