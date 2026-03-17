import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HandsDashboard extends StatefulWidget {
  const HandsDashboard({super.key});

  @override
  State<HandsDashboard> createState() => _HandsDashboardState();
}

class _HandsDashboardState extends State<HandsDashboard> {
  String selectedFilter = "Daily";
  final List<String> filters = ["Daily", "Weekly", "Monthly", "Yearly"];

  // ఫ్యూచర్ లో ఈ డేటాని ఫైర్‌బేస్ నుండి తెస్తాం, ప్రస్తుతానికి డమ్మీ డేటా
  Map<String, Map<String, int>> trackingData = {
    "Daily": {"WhatsApp": 12, "Instagram": 5, "Facebook": 3, "Total": 20},
    "Weekly": {"WhatsApp": 85, "Instagram": 40, "Facebook": 25, "Total": 150},
    "Monthly": {"WhatsApp": 320, "Instagram": 150, "Facebook": 90, "Total": 560},
    "Yearly": {"WhatsApp": 1200, "Instagram": 600, "Facebook": 450, "Total": 2250},
  };

  // ఫామ్ కంట్రోలర్స్
  final TextEditingController waController = TextEditingController();
  final TextEditingController instaController = TextEditingController();
  final TextEditingController fbController = TextEditingController();

  // డేటా ఎంట్రీ ఫామ్ (డైలాగ్ బాక్స్)
  void _showAddEntryDialog() {
    waController.clear();
    instaController.clear();
    fbController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Log Today's Work", style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("ఎంత మందికి దేవుని వాక్యం షేర్ చేశావో ఇక్కడ ఎంటర్ చెయ్:", style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 20),
            _buildInputBox("WhatsApp Reach", waController, Icons.chat, Colors.greenAccent),
            const SizedBox(height: 15),
            _buildInputBox("Instagram Reach", instaController, Icons.camera_alt, Colors.pinkAccent),
            const SizedBox(height: 15),
            _buildInputBox("Facebook Reach", fbController, Icons.facebook, Colors.blueAccent),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              // ఎంటర్ చేసిన నంబర్స్ తీసుకుంటున్నాం (ఖాళీగా ఉంటే 0 అనుకుంటుంది)
              int waAdd = int.tryParse(waController.text) ?? 0;
              int instaAdd = int.tryParse(instaController.text) ?? 0;
              int fbAdd = int.tryParse(fbController.text) ?? 0;
              int newTotal = waAdd + instaAdd + fbAdd;

              if (newTotal > 0) {
                setState(() {
                  // డైలీ డేటా కి కొత్త నంబర్స్ యాడ్ చేస్తున్నాం
                  trackingData["Daily"]!["WhatsApp"] = trackingData["Daily"]!["WhatsApp"]! + waAdd;
                  trackingData["Daily"]!["Instagram"] = trackingData["Daily"]!["Instagram"]! + instaAdd;
                  trackingData["Daily"]!["Facebook"] = trackingData["Daily"]!["Facebook"]! + fbAdd;
                  trackingData["Daily"]!["Total"] = trackingData["Daily"]!["Total"]! + newTotal;
                  
                  // వీక్లీ, మంత్లీ కి కూడా యాడ్ అవ్వాలి కదా
                  trackingData["Weekly"]!["Total"] = trackingData["Weekly"]!["Total"]! + newTotal;
                  trackingData["Monthly"]!["Total"] = trackingData["Monthly"]!["Total"]! + newTotal;
                  trackingData["Yearly"]!["Total"] = trackingData["Yearly"]!["Total"]! + newTotal;
                });
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("+$newTotal People Reached Today! Praise God 🙌"), backgroundColor: Colors.green),
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text("SAVE LOG", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // టెక్స్ట్ బాక్స్ డిజైన్
  Widget _buildInputBox(String hint, TextEditingController controller, IconData icon, Color color) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: color, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentData = trackingData[selectedFilter]!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("H A N D S", style: GoogleFonts.ubuntu(color: Colors.white, letterSpacing: 4, fontSize: 18)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text("Your Impact Dashboard", style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 20),
            
            // Daily / Weekly / Monthly / Yearly బటన్స్
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((filter) => _buildFilterChip(filter)).toList(),
              ),
            ),
            const SizedBox(height: 30),

            // మెయిన్ టోటల్ స్కోర్ కార్డ్
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text("People Reached", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    "${currentData['Total']}",
                    style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text("in $selectedFilter timeframe", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ప్లాట్‌ఫామ్ వైజ్ బ్రేకప్
            Text("Platform Breakdown", style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            Expanded(
              child: ListView(
                children: [
                  _buildPlatformRow("WhatsApp", currentData['WhatsApp']!, Colors.greenAccent, Icons.chat),
                  _buildPlatformRow("Instagram", currentData['Instagram']!, Colors.pinkAccent, Icons.camera_alt),
                  _buildPlatformRow("Facebook", currentData['Facebook']!, Colors.blueAccent, Icons.facebook),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // కొత్త డేటా ఎంటర్ చేయడానికి బటన్
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEntryDialog,
        backgroundColor: Colors.white,
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text("ADD LOG", style: GoogleFonts.ubuntu(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ఫిల్టర్ బటన్స్ డిజైన్ (పైన ఉండే ట్యాబ్స్)
  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.white : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ఒక్కో సోషల్ మీడియా ప్లాట్‌ఫామ్ లిస్ట్ డిజైన్
  Widget _buildPlatformRow(String name, int count, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
          const SizedBox(width: 15),
          Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 16))),
          Text("$count", style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
