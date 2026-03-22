import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // 1. టాప్ బార్ (WOG Logo & Menu)
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 30),
          onPressed: () {},
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 10),
            child: Text(
              "WOG",
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 2. DAILY VERSE CARD
            _buildGradientCard(
              title: "DAILY VERSE",
              content: "యెహోవా నా కాపరి",
              subContent: "- కీర్తనలు 1:1",
              icon: Icons.menu_book_rounded,
              colors: [const Color(0xFF1A237E), const Color(0xFF0D47A1)],
            ),
            const SizedBox(height: 20),

            // 3. NOTIFICATIONS CARD
            _buildGradientCard(
              title: "NOTIFICATIONS",
              content: "ఈరోజు లైవ్ లో ప్రార్థనలు జరుగుతాయి.",
              subContent: "",
              icon: Icons.notifications_none_rounded,
              colors: [const Color(0xFF4A0000), const Color(0xFF8B0000)],
            ),
            const SizedBox(height: 20),

            // 4. LIVE SECTION CARD
            _buildLiveCard(),
          ],
        ),
      ),
      // 5. BOTTOM NAVIGATION BAR
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // గ్రేడియంట్ కార్డ్స్ కోసం కామన్ మెథడ్
  Widget _buildGradientCard({
    required String title,
    required String content,
    required String subContent,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.ubuntu(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(icon, color: Colors.white70, size: 24),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: GoogleFonts.balooTammudu2(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (subContent.isNotEmpty)
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                subContent,
                style: GoogleFonts.ubuntu(color: Colors.white60, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  // లైవ్ కార్డ్ డిజైన్
  Widget _buildLiveCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(backgroundColor: Colors.red, radius: 4),
                    const SizedBox(width: 6),
                    Text(
                      "LIVE",
                      style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "Evening Fellowship & Prayer",
            style: GoogleFonts.ubuntu(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Join our daily live session with the community. Connect directly via Jitsi.",
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // బాటమ్ నావిగేషన్ బార్
  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(Icons.library_books_outlined),
          _navIcon(Icons.menu_book_outlined),
          _navIcon(Icons.home_filled, isSelected: true),
          _navIcon(Icons.center_focus_weak_outlined), // ఆడియో ఐకాన్ కోసం
          _navIcon(Icons.person_outline_rounded),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, {bool isSelected = false}) {
    return Icon(
      icon,
      color: isSelected ? Colors.white : Colors.white38,
      size: 28,
    );
  }
}
